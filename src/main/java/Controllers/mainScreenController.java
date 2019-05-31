package Controllers;

import Management.Database;
import Management.StageMaster;
import Types.MovieRankingType;
import Types.MovieType;
import Types.PeopleType;
import Types.PersonRankingType;
import javafx.animation.KeyFrame;
import javafx.animation.Timeline;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.event.EventType;
import javafx.fxml.FXML;
import javafx.scene.control.*;
import javafx.scene.effect.DropShadow;
import javafx.scene.input.KeyCode;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.Pane;
import javafx.scene.text.Text;
import javafx.stage.Stage;
import javafx.util.Duration;
import org.controlsfx.control.textfield.AutoCompletionBinding;
import org.controlsfx.control.textfield.TextFields;

import java.io.IOException;
import java.lang.reflect.Field;
import java.net.URL;
import java.sql.Date;
import java.util.Calendar;
import java.util.HashMap;
import java.util.ResourceBundle;
import java.util.Vector;

public class mainScreenController extends Controller {
    mainScreenController(String name, Controller previousController){
        super(name,previousController);
    }
    private Vector<MovieType> movies;
    private Vector<String> genre;
    private Vector<PeopleType> people;
    private Vector<MovieRankingType> movieRanking;
    private Vector<PersonRankingType> personRanking;
    private HashMap<String,PeopleType> peopleNames;
    private HashMap<String,MovieType> moviesNames;
    private AutoCompletionBinding<String> movieCompletion;
    String selectedMovie;
    String selectedPerson;
    @FXML
    MenuButton categoryMenu;
    @FXML
    GridPane rankingGrid1;
    @FXML
    GridPane rankingGrid2;
    @FXML
    Text welcomeText;
    @FXML
    TextField movieBrowser;
    @FXML
    TextField personBrowser;
    @FXML
    RadioButton filterButton;
    @FXML
    Slider yearSlider;
    @FXML
    Text yearText;
    @FXML
    Button watchListButton;
    @Override
    public void initialize(URL url, ResourceBundle resourceBundle) {
        welcomeText.setText("Welcome "+Controller.currentUser+"!");
        genre=Controller.database.getGenre();
        movieRanking=Controller.database.getRanking();
        personRanking=Controller.database.getActorsRanking();
        movies=Controller.database.getMovies();
        people=Controller.database.getPeople();
        prepareMenu();
        setUpRanking();
        setUpPersonRanking();
        Tooltip a=new Tooltip("Watch List!");
        setTooltipTimer(a);
        watchListButton.setTooltip(a);
        yearSlider.setMax(Calendar.getInstance().get(Calendar.YEAR));
        yearSlider.valueProperty().addListener(((observable, oldValue, newValue) -> {
            yearText.setText(String.valueOf(newValue.intValue()));
            controllFilterButton();
        }));
        moviesNames=new HashMap<>();
        peopleNames=new HashMap<>();
        for(MovieType x: movies){
            moviesNames.put(x.getTitle() + " (" + x.getRelease_date().substring(0,4) + ") ",x);
        }
        for(PeopleType x: people){
            peopleNames.put(x.getFirst_name()+" "+x.getLast_name(),x); //might be ambiguous
        }
        movieCompletion=TextFields.bindAutoCompletion(movieBrowser,moviesNames.keySet());
        TextFields.bindAutoCompletion(personBrowser,peopleNames.keySet());
    }
    public void findMovie(){
        movieBrowser.setOnKeyPressed(event->{
            if(event.getCode()== KeyCode.ENTER){
                String s=String.valueOf(movieBrowser.getCharacters());
                if(!moviesNames.containsKey(s)) return; //invalid title
                movieBrowser.setText("");
                selectedMovie=s;
                displayInfo(selectedMovie);
                }
        });
    }
    public void findPerson(){
        personBrowser.setOnKeyPressed(event->{
            if(event.getCode()== KeyCode.ENTER){
                String s=String.valueOf(personBrowser.getCharacters());
                if(!peopleNames.containsKey(s)) return; //invalid title
                personBrowser.setText("");
                selectedPerson=s;
                System.out.println(s);
            }
        });
    }
    private void displayInfo(String selectedMovie){
        try {
            Controller.stageMaster.loadNewScene(new movieScreenController("/Scenes/movieScreen.fxml",this));
        } catch (IOException e) {
            System.out.println("FAILED TO LOAD MOVIESCREEN");
        }
    }
    @SuppressWarnings("Duplicates")
    private void setUpRanking(){
        for(int i=0;i<5;i++) {
            Pane pane = new Pane();
            pane.setStyle("-fx-border-color:black;" +
                    "-fx-text-fill:white;");
            pane.setEffect(new DropShadow());
            Label title = new Label(movieRanking.get(i).getTitle());
            Label votes = new Label("(" + movieRanking.get(i).getVotes() + " reviews)");
            Label mark = new Label(String.valueOf(movieRanking.get(i).getAvg_mark()));
            Label ranking=new Label(String.valueOf(movieRanking.get(i).getRanking()));
            title.setStyle("-fx-text-fill:black;" +
                    "-fx-font-size: 17px");
            mark.setStyle("-fx-text-fill:darkred;" +
                    "-fx-font-size: 17px");
            votes.setStyle("-fx-text-fill:black;" +
                    "-fx-font-size: 15px");
            ranking.setStyle("-fx-text-fill:black;" +
                    "-fx-font-size: 13px");
            title.setTranslateX(5);
            title.setMaxWidth(230);
            mark.setTranslateY(100);
            mark.setTranslateX(10);
            votes.setTranslateX(10);
            votes.setTranslateY(120);
            votes.setMaxWidth(200);
            ranking.setTranslateY(133);
            ranking.setTranslateX(230);
            pane.getChildren().addAll(title, mark, votes,ranking);
            rankingGrid1.add(pane, i, 0);
        }
    }
    @SuppressWarnings("Duplicates")
    private void setUpPersonRanking(){
        for(int i=0;i<5;i++) {
            Pane pane = new Pane();
            pane.setStyle("-fx-border-color:black;" +
                    "-fx-text-fill:white;");
            pane.setEffect(new DropShadow());
            Label title = new Label(personRanking.get(i).getName());
            Label votes = new Label("(" + personRanking.get(i).getVotes() + " reviews)");
            Label mark = new Label(String.valueOf(personRanking.get(i).getAvg_mark()));
            Label ranking=new Label(String.valueOf(personRanking.get(i).getRanking()));
            title.setStyle("-fx-text-fill:black;" +
                    "-fx-font-size: 17px");
            mark.setStyle("-fx-text-fill:darkred;" +
                    "-fx-font-size: 17px");
            votes.setStyle("-fx-text-fill:black;" +
                    "-fx-font-size: 15px");
            ranking.setStyle("-fx-text-fill:black;" +
                    "-fx-font-size: 13px");
            title.setTranslateX(5);
            title.setMaxWidth(230);
            mark.setTranslateY(100);
            mark.setTranslateX(10);
            votes.setTranslateX(10);
            votes.setTranslateY(120);
            votes.setMaxWidth(200);
            ranking.setTranslateY(133);
            ranking.setTranslateX(230);
            pane.getChildren().addAll(title, mark, votes,ranking);
            rankingGrid2.add(pane, i, 0);
        }
    }
    private void prepareMenu(){
        for(String x: genre){
            CheckBox tmp=new CheckBox(x);
            CustomMenuItem item=new CustomMenuItem(tmp);
            item.setHideOnClick(false);
            item.setOnAction(t->controllFilterButton());
            categoryMenu.getItems().add(item);
        }
    }
    public void controllFilterButton(){
        if(filterButton.isSelected()){
            filterSearch();
        }
        else{
            removeFilterFun();
        }
    }
    private void filterSearch(){
        Vector<String> filterGenre=new Vector<>();
        for(MenuItem x:categoryMenu.getItems()){
            if(((CheckBox)(((CustomMenuItem) x).getContent())).isSelected()){
                filterGenre.add(((CheckBox)(((CustomMenuItem) x).getContent())).getText());
            }
        }
        //update movieBrowser with new selected genre
        moviesNames.clear();
        for(MovieType x: Controller.database.getMoviesWithOptions(filterGenre,yearText.getText())){
            moviesNames.put(x.getTitle() + " (" + x.getRelease_date().substring(0,4) + ") ",x);
        }
        movieCompletion.dispose();
        movieCompletion=TextFields.bindAutoCompletion(movieBrowser,moviesNames.keySet());

    }
    private void removeFilterFun(){
        moviesNames.clear();
        for(MovieType x: movies){
            moviesNames.put(x.getTitle() + " (" + x.getRelease_date().substring(0,4) + ") ",x);
        }
        movieCompletion.dispose();
        movieCompletion=TextFields.bindAutoCompletion(movieBrowser,moviesNames.keySet());
    }
    public void logOut(){
        try {
            stageMaster.loadPreviousScene();
        } catch (IOException e) {
            System.out.println("FAILED TO LOG OUT");
        }
    }
    public void displayWatchList(){
        Controller controllerWatchList=new watchListController("/Scenes/watchList.fxml",this,this);
        Stage s=new Stage();
        StageMaster stageMaster=new StageMaster(s);
        stageMaster.setResizable(false);
        stageMaster.setName("Watch List!");
        try {
            stageMaster.loadNewScene(controllerWatchList);
        } catch (IOException e) {
            System.out.println("FAILED TO LOAD WATCHLIST!");
        }

    }
    private void setTooltipTimer(Tooltip tooltip) {
        try {
            Field fieldBehavior = tooltip.getClass().getDeclaredField("BEHAVIOR");
            fieldBehavior.setAccessible(true);
            Object objBehavior = fieldBehavior.get(tooltip);
            Field fieldTimer = objBehavior.getClass().getDeclaredField("activationTimer");
            fieldTimer.setAccessible(true);
            Timeline objTimer = (Timeline) fieldTimer.get(objBehavior);
            objTimer.getKeyFrames().clear();
            objTimer.getKeyFrames().add(new KeyFrame(new Duration(200)));
        } catch (Exception e) {//e.printStackTrace();
            System.out.println("NIE WAŻNY WYJĄTEK ;))))))))))))"); }
    }
}
