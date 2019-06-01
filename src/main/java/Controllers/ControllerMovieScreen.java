package Controllers;

import Management.RegexManager;
import Types.MovieMarkType;
import Types.MovieRankingType;
import Types.MovieType;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.fxml.FXML;
import javafx.scene.control.*;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.text.Text;

import java.net.URL;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.ResourceBundle;
import java.util.Vector;

public class ControllerMovieScreen extends Controller {

    ControllerMovieScreen(String name, Controller previousController) {
        super(name, previousController);
        System.out.println("NOT POSSIBLE");
    }

    ControllerMovieScreen(String name, Controller previousController, MovieType movie) {
        super(name, previousController);
        this.movie = movie;
    }

    private MovieType movie;
    private boolean isHeart;
    private boolean isWatchlist;

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
    TextArea stars;
    @FXML
    TextArea description;
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

    @Override
    public void initialize(URL url, ResourceBundle resourceBundle) {
        title.setText(movie.getTitle());
        runtime.setText(runtime.getText() + " " + movie.getRuntime());
        release.setText(release.getText() + " " + movie.getRelease_date());
        budget.setText(budget.getText() + " " + movie.getBudget());
        boxoffice.setText(boxoffice.getText() + " " + movie.getBoxoffice());
        weekend.setText(weekend.getText() + " " + movie.getOpening_weekend_usa());
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

        others.setEditable(false);
        stars.setEditable(false);
        description.setEditable(false);

        updateRankings();
        setUpRadio();
        updatePersonal();
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
        if(isHeart() != null){
            updateHeart(false);
            database.updateFromMovieRatings(new MovieMarkType(movie.getMovie_id(), Controller.currentUserDBver, movieMark.getMark(), null, movieMark.getSeen()));
        } else {
            updateHeart(true);
            database.updateFromMovieRatings(new MovieMarkType(movie.getMovie_id(), Controller.currentUserDBver, movieMark.getMark(), "H", movieMark.getSeen()));
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
