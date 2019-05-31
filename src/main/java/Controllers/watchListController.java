package Controllers;

import Types.MovieType;
import javafx.collections.FXCollections;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.ListView;

import java.io.IOException;
import java.net.URL;
import java.util.*;

public class watchListController extends Controller {
    private final mainScreenController currmainscreen;
    private HashMap<String, MovieType> moviesNames;
    private Vector<MovieType> movies;
    @FXML
    ListView watchList;
    @FXML
    Button remove;
    @FXML
    Button displayMovie;
    watchListController(String name, Controller previousController,mainScreenController mainController) {
        super(name,previousController);
        currmainscreen=mainController;
    }
    @Override
    public void initialize(URL url, ResourceBundle resourceBundle) {
        movies=Controller.database.getWatchList(Controller.currentUser);
        moviesNames=new HashMap<>();
        for(MovieType x: movies){
            moviesNames.put(x.getTitle() + " (" + x.getRelease_date().substring(0,4) + ") ",x);
        }
        List<String> tmp=new LinkedList<>();
        tmp.addAll(moviesNames.keySet());
        watchList.setItems(FXCollections.observableList(tmp));
        remove.setDisable(true);
        displayMovie.setDisable(true);
        watchList.setOnMouseClicked(mouseEvent->{
            if(watchList.getSelectionModel().getSelectedItems().size()==0) return;
            if(watchList.getSelectionModel().getSelectedItems().get(0)!=null){
                remove.setDisable(false);
                displayMovie.setDisable(false);
            }else{
                remove.setDisable(true);
                displayMovie.setDisable(true);
            }
        });
    }
    public void remove() {
        if (watchList.getSelectionModel().getSelectedItems().size() == 0) return;
        if (watchList.getSelectionModel().getSelectedItems().get(0) != null) {
            List<String> tmp = new LinkedList<>();
            tmp.addAll(moviesNames.keySet());
            tmp.remove(watchList.getSelectionModel().getSelectedItems().get(0));
            Controller.database.deleteFromWatchList(moviesNames.get(watchList.getSelectionModel()
                    .getSelectedItems().get(0)),Controller.currentUser);
            watchList.setItems(FXCollections.observableList(tmp));
        }
    }
    public void displayMovie(){
        // TODO
            try {
                Controller.stageMaster.loadNewScene(new movieScreenController("/Scenes/movieScreen.fxml",this));
            } catch (IOException e) {
                System.out.println("FAILED TO LOAD MOVIESCREEN");
            }
    }
}
