package Controllers;

import Management.RegexManager;
import Types.MovieMarkType;
import Types.MovieRankingType;
import Types.MovieType;
import javafx.collections.FXCollections;
import javafx.fxml.FXML;
import javafx.scene.control.*;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.text.Text;

import java.io.IOException;
import java.net.URL;
import java.sql.SQLException;
import java.util.*;

public class ControllerMovieScreen extends Controller {

    ControllerMovieScreen(String name, Controller previousController, MovieType movie) {
        super(name, previousController);
        this.movie = movie;
    }

    private MovieType movie;
    private boolean isHeart;
    private boolean isWatchlist;
    private MovieType selectedMovie;
    private HashMap<String, MovieType> similarMovies;

    @FXML
    Text title;
    @FXML
    Text alternative;
    @FXML
    Text runtime;
    @FXML
    Text release;
    @FXML
    Text directors;
    @FXML
    Text writers;
    @FXML
    Text genre;
    @FXML
    Text languages;
    @FXML
    Text countries;
    @FXML
    Text production;
    @FXML
    Text budget;
    @FXML
    Text boxoffice;
    @FXML
    Text weekend;
    @FXML
    Text nominations;
    @FXML
    Text wins;
    @FXML
    TextArea stars;
    @FXML
    TextArea description;
    @FXML
    TextArea reviews;
    @FXML
    TextArea yourReview;
    @FXML
    Button submitReview;
    @FXML
    ListView<String> similar;
    @FXML
    Button displayMovie;
    @FXML
    TextArea others;
    @FXML
    Text rank;
    @FXML
    Text votes;
    @FXML
    ToggleButton heart;
    @FXML
    ImageView heartImage;
    @FXML
    ToggleButton watchlist;
    @FXML
    ImageView watchlistImage;
    @FXML
    Button editData;
    @FXML
    Button removeData;

    @Override
    public void goBack(){
        try {
            Controller.stageMaster.loadNewScene(new ControllerMainScreen("/Scenes/mainScreen.fxml", this));
        } catch (IOException e) {
            e.printStackTrace();
            System.out.println("FAILED TO LOAD mainScreen.fxml");
        }
    }

    @Override
    public void initialize(URL url, ResourceBundle resourceBundle) {
        disableActionsForNoAdmins();
        title.setText(movie.getTitle());
        runtime.setText(runtime.getText() + " " + movie.getRuntime());
        release.setText(release.getText() + " " + movie.getRelease_date());
        budget.setText(budget.getText() + " " + (movie.getBudget() == 0 ? " - " : movie.getBudget() + "k$"));
        boxoffice.setText(boxoffice.getText() + " " + (movie.getBoxoffice() == 0 ? " - " : movie.getBoxoffice() + "k$"));
        weekend.setText(weekend.getText() + " " + (movie.getOpening_weekend_usa() == 0 ? " - " : movie.getOpening_weekend_usa() + "k$"));
        description.setText(movie.getDescription());

        genre.setText(genre.getText() + " " + RegexManager.convertIntoList(
                database.getSomethingForMovie(movie.getMovie_id(), "movie_genre", "genre")));
        languages.setText(languages.getText() + " " + RegexManager.convertIntoList(
                database.getSomethingForMovie(movie.getMovie_id(), "movie_language", "language")));
        countries.setText(countries.getText() + " " + RegexManager.convertIntoList(
                database.getSomethingForMovie(movie.getMovie_id(), "production", "country")));
        production.setText(production.getText() + " " + RegexManager.convertIntoList(
                database.getSomethingForMovie(movie.getMovie_id(), "production_company", "company")));
        alternative.setText(alternative.getText() + " " + RegexManager.convertIntoList(
                database.getSomethingForMovie(movie.getMovie_id(), "alternative_title", "movie_title")));

        nominations.setText(nominations.getText() + " " + RegexManager.convertIntoList(
                database.getAwards(movie.getMovie_id(), "N")));
        wins.setText(wins.getText() + " " + RegexManager.convertIntoList(
                database.getAwards(movie.getMovie_id(), "W")));

        directors.setText(directors.getText() + " " + RegexManager.convertIntoList(
                database.getPeopleForMovie(movie.getMovie_id(), "Director")));
        writers.setText(writers.getText() + " " + RegexManager.convertIntoList(
                database.getPeopleForMovie(movie.getMovie_id(), "Writer")));

        Vector<String> actors = database.getPeopleForMovie(movie.getMovie_id(), "Actor");
        StringBuilder stringBuilder = new StringBuilder();
        for(int i = 0; i < actors.size(); i++){
            stringBuilder.append(actors.get(i));
            if(i < actors.size() - 1) stringBuilder.append("\n");
        } stars.setText(stringBuilder.toString());

        Vector<String> othersList = database.getPeopleForMovie(movie.getMovie_id(), "Others");
        stringBuilder = new StringBuilder();
        for(int i = 0; i < othersList.size(); i++){
            stringBuilder.append(othersList.get(i));
            if(i < othersList.size() - 1) stringBuilder.append("\n");
        } others.setText(stringBuilder.toString());

        yourReview.setText(database.getYourReview(movie.getMovie_id(), currentUserDBver));

        updateRankings();
        setUpRadio();
        updatePersonal();
        submitReview();

        //SIMILAR:
        Vector<MovieType> movies = database.getSimilar(movie.getMovie_id());
        similarMovies = new HashMap<>();
        for (MovieType x : movies) {
            similarMovies.put(x.getIdentifier(), x);
        }
        List<String> tmp = new LinkedList<>(similarMovies.keySet());
        similar.setItems(FXCollections.observableList(tmp));
        displayMovie.setDisable(true);
        similar.setOnMouseClicked(mouseEvent -> {
            if (similar.getSelectionModel().getSelectedItems().size() == 0) return;
            if (similar.getSelectionModel().getSelectedItems().get(0) != null) {
                selectedMovie = similarMovies.get(similar.getSelectionModel().getSelectedItems().get(0));
                displayMovie.setDisable(false);
            } else {
                displayMovie.setDisable(true);
            }
        });
    }
    private void disableActionsForNoAdmins(){
        if(!Controller.database.isAdmin(Controller.currentUser)){ //not admin
            removeData.setDisable(true);
            removeData.setVisible(false);
            editData.setDisable(true);
            editData.setVisible(false);
            }
    }
    private void updateRankings(){
        MovieRankingType movieRanking = database.getMovieRating(movie.getMovie_id());
        if(movieRanking == null){
            rank.setText("--/10");
            votes.setText("not enough votes");
        } else {
            rank.setText(movieRanking.getAvg_mark() + "/10");
            votes.setText("(" + movieRanking.getVotes() + " votes)");
        }
    }

    private void updatePersonal(){
        Vector<MovieType> v = database.getWatchList(Controller.currentUserDBver);
        Vector<Integer> ids = new Vector<>();
        for(MovieType mt : v){
            ids.add(mt.getMovie_id());
        }
        isWatchlist = ids.contains(movie.getMovie_id());
        updateWatchlist(isWatchlist);

        MovieMarkType movieMark = database.getMovieMark(Controller.currentUserDBver, movie.getMovie_id());
        if(movieMark == null){
            updateHeart(false);
            setMark(0);
        } else {
            updateHeart(movieMark.getHeart().equals("H"));
            setMark(movieMark.getMark());
        }
    }

    private void updateWatchlist(boolean is){
        watchlist.setSelected(isWatchlist);
        if(is) {
            isWatchlist = true;
            watchlistImage.setImage(new Image(getClass().getResourceAsStream(Controller.imagesLocation + "/watchlistYes.png")));
        } else {
            isWatchlist = false;
            watchlistImage.setImage(new Image(getClass().getResourceAsStream(Controller.imagesLocation + "/watchlistNo.png")));
        }
    }

    private void updateHeart(boolean is){
        heart.setSelected(isHeart);
        if(is) {
            isHeart = true;
            heartImage.setImage(new Image(getClass().getResourceAsStream(Controller.imagesLocation + "/heartYes.png")));
        } else {
            isHeart = false;
            heartImage.setImage(new Image(getClass().getResourceAsStream(Controller.imagesLocation + "/heartNo.png")));
        }
    }

    private String isHeart(){
        if(isHeart)
            return "H";
        return null;
    }

    @FXML
    public void heartButton(){
        MovieMarkType movieMark = database.getMovieMark(Controller.currentUserDBver, movie.getMovie_id());
        try {
            if (isHeart() != null) {
                updateHeart(false);
                database.updateFromMovieRatings(new MovieMarkType(movie.getMovie_id(), Controller.currentUserDBver, movieMark.getMark(), null, movieMark.getSeen()));
            } else {
                updateHeart(true);
                database.updateFromMovieRatings(new MovieMarkType(movie.getMovie_id(), Controller.currentUserDBver, movieMark.getMark(), "H", movieMark.getSeen()));
            }
        } catch (NullPointerException e){
            updateHeart(false);
        }
    }

    @FXML
    public void watchlistButton() {
        if(isWatchlist){
            updateWatchlist(false);
            database.deleteFromWatchList(movie, Controller.currentUserDBver);
        } else {
            updateWatchlist(true);
            ArrayList<Object> arguments = new ArrayList<>();
            arguments.add(Controller.currentUser);
            arguments.add(movie.getMovie_id());
            try {
                database.insert("watchlist", arguments);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    @FXML
    public void submitReview(){
        database.updateReview(movie.getMovie_id(), currentUserDBver, yourReview.getText());
        reviews.setText(RegexManager.convertIntoListNewLine(
                database.getReviews(movie.getMovie_id()), true));
    }

    @FXML
    public void displayMovie() {
        try {
            Controller.stageMaster.loadNewScene(new ControllerMovieScreen(Controller.scenesLocation + "/movieScreen.fxml", this, selectedMovie));
        } catch (IOException e) {
            System.out.println("FAILED TO LOAD MOVIESCREEN");
        }
    }

    @FXML
    public void editData(){
        try {
            Controller.stageMaster.loadNewScene(new ControllerEditDataMovie(Controller.scenesLocation + "/editDataMovie.fxml", this, movie));
        } catch (IOException e) {
            e.printStackTrace();
            System.out.println("FAILED TO LOAD editMovieScreen");
        }
    }
    @FXML
    public void removeData(){
        try {
            Controller.stageMaster.loadNewScene(new ControllerAreYouSure(Controller.scenesLocation + "/areYouSure.fxml", this, movie));
        } catch (IOException e) {
            e.printStackTrace();
            System.out.println("FAILED TO LOAD areYouSureScreen");
        }
    }


//RANKS    ------------------------------------------------------------------

    @FXML
    RadioButton radio1;
    @FXML
    RadioButton radio2;
    @FXML
    RadioButton radio3;
    @FXML
    RadioButton radio4;
    @FXML
    RadioButton radio5;
    @FXML
    RadioButton radio6;
    @FXML
    RadioButton radio7;
    @FXML
    RadioButton radio8;
    @FXML
    RadioButton radio9;
    @FXML
    RadioButton radio10;
    @FXML
    RadioButton radioNone;
    private ArrayList<RadioButton> radioButtons = new ArrayList<>();

    private void setUpRadio(){
        radioButtons.add(radioNone);
        radioButtons.add(radio1);
        radioButtons.add(radio2);
        radioButtons.add(radio3);
        radioButtons.add(radio4);
        radioButtons.add(radio5);
        radioButtons.add(radio6);
        radioButtons.add(radio7);
        radioButtons.add(radio8);
        radioButtons.add(radio9);
        radioButtons.add(radio10);

        for(int i = 0; i < 11; i++){
            final int j = i;
            radioButtons.get(i).setOnAction(event -> setMark(j));
        }
    }

    @FXML
    public void setMark(int value){
        radioButtons.get(value).setSelected(true);
        for(int i = 0; i < 11; i++){
            if(i != value)
                radioButtons.get(i).setSelected(false);
        }

        MovieMarkType movieMark = database.getMovieMark(Controller.currentUserDBver, movie.getMovie_id());
        if(movieMark == null && value > 0){
            ArrayList<Object> arguments = new ArrayList<>();
            arguments.add(movie.getMovie_id());
            arguments.add(Controller.currentUser);
            arguments.add(value);
            arguments.add(null);
            arguments.add(null);
            try {
                database.insert("movie_ratings", arguments);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        } else if(movieMark != null && value > 0){
            database.updateFromMovieRatings(new MovieMarkType(movie.getMovie_id(), Controller.currentUserDBver, value, isHeart(), null));
        } else if(movieMark != null){ //value == 0
            database.deleteFromMovieRatings(movie.getMovie_id(), Controller.currentUserDBver);
        }
        updateRankings();
    }
}
