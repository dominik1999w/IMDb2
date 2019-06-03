package Controllers;

import Management.Database;
import Types.MovieType;
import javafx.collections.FXCollections;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.ListView;

import java.io.IOException;
import java.net.URL;
import java.util.*;

public class ControllerWatchList extends Controller {

    private MovieType selectedMovie;
    private HashMap<String, MovieType> moviesNames;
    @FXML
    ListView<String> watchList;
    @FXML
    Button remove;
    @FXML
    Button displayMovie;

    ControllerWatchList(String name, Controller previousController) {
        super(name, previousController);
    }

    @Override
    public void initialize(URL url, ResourceBundle resourceBundle) {
        Vector<MovieType> movies = Controller.database.getWatchList(Controller.currentUserDBver);
        moviesNames = new HashMap<>();
        for (MovieType x : movies) {
            moviesNames.put(x.getIdentifier(), x);
        }
        List<String> tmp = new LinkedList<>(moviesNames.keySet());
        watchList.setItems(FXCollections.observableList(tmp));
        remove.setDisable(true);
        displayMovie.setDisable(true);
        watchList.setOnMouseClicked(mouseEvent -> {
            if (watchList.getSelectionModel().getSelectedItems().size() == 0) return;
            if (watchList.getSelectionModel().getSelectedItems().get(0) != null) {
                selectedMovie = moviesNames.get(watchList.getSelectionModel().getSelectedItems().get(0));
                remove.setDisable(false);
                displayMovie.setDisable(false);
            } else {
                remove.setDisable(true);
                displayMovie.setDisable(true);
            }
        });
    }

    @FXML
    public void remove() {
        if (watchList.getSelectionModel().getSelectedItems().size() == 0) return;
        if (watchList.getSelectionModel().getSelectedItems().get(0) != null) {
            List<String> tmp = new LinkedList<>(moviesNames.keySet());
            tmp.remove(watchList.getSelectionModel().getSelectedItems().get(0));
            Controller.database.deleteFromWatchList(moviesNames.get(watchList.getSelectionModel()
                    .getSelectedItems().get(0)), Controller.currentUserDBver);
            watchList.setItems(FXCollections.observableList(tmp));
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
}
