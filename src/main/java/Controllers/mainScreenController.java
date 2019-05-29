package Controllers;

import Management.Database;
import Management.StageMaster;
import Types.MovieRankingType;
import Types.MovieType;
import Types.PeopleType;
import javafx.fxml.FXML;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.scene.effect.DropShadow;
import javafx.scene.input.KeyCode;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.Pane;
import javafx.scene.text.Text;
import javafx.stage.Stage;
import org.controlsfx.control.textfield.TextFields;

import java.io.File;
import java.net.URL;
import java.util.HashMap;
import java.util.ResourceBundle;
import java.util.Vector;

public class mainScreenController extends Controller {
    mainScreenController(String name, Controller previousController){
        super(name,previousController);
    }
    private Vector<MovieType> movies;
    private Vector<PeopleType> people;
    private Vector<MovieRankingType> movieRanking;
    private HashMap<String,PeopleType> peopleNames;
    private HashMap<String,MovieType> moviesNames;
    String selectedMovie;
    String selectedPerson;
    @FXML
    GridPane rankingGrid;
    @FXML
    Text welcomeText;
    @FXML
    Text movieTitle;
    @FXML
    Text firstTitle;
    @FXML
    TextField movieBrowser;
    @FXML
    TextField personBrowser;
    @Override
    public void initialize(URL url, ResourceBundle resourceBundle) {
        welcomeText.setText("Welcome "+Controller.currentUser+"!");
        movieRanking=Controller.database.getRanking();
        setUpRanking();
        movies=Controller.database.getMovies();
        people=Controller.database.getPeople();
        moviesNames=new HashMap<>();
        peopleNames=new HashMap<>();
        for(MovieType x: movies){
            moviesNames.put(x.getTitle() + " (" + x.getRelease_date().substring(0,4) + ") ",x);
        }
        for(PeopleType x: people){
            peopleNames.put(x.getFirst_name()+" "+x.getLast_name(),x); //might be ambiguous
        }
        TextFields.bindAutoCompletion(movieBrowser,moviesNames.keySet());
        TextFields.bindAutoCompletion(personBrowser,peopleNames.keySet());
    }
    public void findMovie(){
        movieBrowser.setOnKeyPressed(event->{
            if(event.getCode()== KeyCode.ENTER){
                String s=String.valueOf(movieBrowser.getCharacters());
                if(!moviesNames.containsKey(s)) return; //invalid title
                movieBrowser.setText("");
                selectedMovie=s;
                //displayInfo(selectedMovie);
                movieTitle.setText(s);
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

    }
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
            rankingGrid.add(pane, i, 0);
        }
    }
}
