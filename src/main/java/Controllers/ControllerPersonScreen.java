package Controllers;

import Management.RegexManager;
import Types.*;
import javafx.collections.FXCollections;
import javafx.fxml.FXML;
import javafx.scene.control.*;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.text.Text;
import javafx.util.Pair;

import java.io.IOException;
import java.net.URL;
import java.sql.SQLException;
import java.util.*;

public class ControllerPersonScreen extends Controller {

    ControllerPersonScreen(String name, Controller previousController, PeopleType person) {
        super(name, previousController);
        this.person = person;
    }

    private PeopleType person;
    private boolean isHeart;
    private MovieType selectedMovie;
    private HashMap<String, MovieType> movies;

    @FXML
    Text name;
    @FXML
    Text born;
    @FXML
    Text died;
    @FXML
    Text birthCountry;
    @FXML
    Text nominations;
    @FXML
    Text wins;
    @FXML
    TextArea professions;
    @FXML
    ListView<String> moviesList;
    @FXML
    Button displayMovie;
    @FXML
    Text rank;
    @FXML
    Text votes;
    @FXML
    ToggleButton heart;
    @FXML
    ImageView heartImage;
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
        name.setText(person.getIdentifier());
        born.setText(born.getText() + " " + person.getBorn());
        died.setText(died.getText() + " " + ("".equals(person.getDied()) || person.getDied() == null ? " - " : person.getDied()));
        birthCountry.setText(birthCountry.getText() + " " + ("".equals(person.getBirth_country()) || person.getBirth_country() == null ? " - " : person.getBirth_country()));

        professions.setText(RegexManager.convertIntoListNewLine(
                database.getSomethingForPerson(person.getPerson_id(), "profession", "profession"),false));

        nominations.setText(nominations.getText() + " " + RegexManager.convertIntoList(
                database.getPeopleAwards(person.getPerson_id(), "N")));
        wins.setText(wins.getText() + " " + RegexManager.convertIntoList(
                database.getPeopleAwards(person.getPerson_id(), "W")));

        setUpRadio();
        updatePersonal();

        //MOVIES:
        Vector<Pair<MovieType,String >> moviesP = database.getMoviesForPerson(person.getPerson_id());
        this.movies = new HashMap<>();
        for (Pair p : moviesP) {
            this.movies.put ( ((MovieType) p.getKey()).getIdentifier() + "[" + p.getValue() + "]" , (MovieType) p.getKey());
        }
        List<String> tmp = new LinkedList<>(this.movies.keySet());
        moviesList.setItems(FXCollections.observableList(tmp));
        displayMovie.setDisable(true);
        moviesList.setOnMouseClicked(mouseEvent -> {
            if (moviesList.getSelectionModel().getSelectedItems().size() == 0) return;
            if (moviesList.getSelectionModel().getSelectedItems().get(0) != null) {
                selectedMovie = this.movies.get(moviesList.getSelectionModel().getSelectedItems().get(0));
                displayMovie.setDisable(false);
            } else {
                displayMovie.setDisable(true);
            }
        });
    }
    @FXML
    public void removeData(){
        try {
            Controller.stageMaster.loadNewScene(new ControllerAreYouSure(Controller.scenesLocation + "/areYouSure.fxml", this, person));
        } catch (IOException e) {
            e.printStackTrace();
            System.out.println("FAILED TO LOAD areYouSureScreen");
        }
    }
    private void disableActionsForNoAdmins(){
        if(!Controller.database.isAdmin(Controller.currentUser)){ //not admin
            removeData.setVisible(false);
            removeData.setDisable(true);
            editData.setDisable(true);
            editData.setVisible(false);
        }
    }
    private void updateRankings(){

        PersonRankingType personRanking = database.getPersonRating(person.getPerson_id());
        if(personRanking == null){
            rank.setText("--/10");
            votes.setText("not enough votes");
        } else {
            rank.setText(personRanking.getAvg_mark() + "/10");
            votes.setText("(" + personRanking.getVotes() + " votes)");
        }
    }

    private void updatePersonal(){

        PersonMarkType personMark = database.getPersonMark(Controller.currentUserDBver, person.getPerson_id());
        if(personMark == null){
            updateHeart(false);
            setMark(0);
        } else {
            updateHeart(personMark.getHeart().equals("H"));
            setMark(personMark.getMark());
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
        PersonMarkType personMark = database.getPersonMark(Controller.currentUserDBver, person.getPerson_id());
        try {
            if (isHeart() != null) {
                updateHeart(false);
                database.updateFromPersonRatings(new PersonMarkType(person.getPerson_id(), Controller.currentUserDBver, personMark.getMark(), null));
            } else {
                updateHeart(true);
                database.updateFromPersonRatings(new PersonMarkType(person.getPerson_id(), Controller.currentUserDBver, personMark.getMark(), "H"));
            }
        } catch (NullPointerException e){
            updateHeart(false);
        }
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
            Controller.stageMaster.loadNewScene(new ControllerEditDataPerson(Controller.scenesLocation + "/editDataPerson.fxml", this, person));
        } catch (IOException e) {
            e.printStackTrace();
            System.out.println("FAILED TO LOAD editMovieScreen");
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

        PersonMarkType personMark = database.getPersonMark(Controller.currentUserDBver, person.getPerson_id());
        if(personMark == null && value > 0){
            ArrayList<Object> arguments = new ArrayList<>();
            arguments.add(person.getPerson_id());
            arguments.add(Controller.currentUser);
            arguments.add(value);
            arguments.add(null);
            try {
                database.insert("person_ratings", arguments);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        } else if(personMark != null && value > 0){
            database.updateFromPersonRatings(new PersonMarkType(person.getPerson_id(), Controller.currentUserDBver, value, isHeart()));
        } else if(personMark != null){ //value == 0
            database.deleteFromPersonRatings(person.getPerson_id(), Controller.currentUserDBver);
        }
        updateRankings();
    }
}
