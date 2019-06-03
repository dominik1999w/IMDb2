package Controllers;

import Types.MovieMarkType;
import Types.MovieType;
import javafx.collections.FXCollections;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.ListView;

import java.io.IOException;
import java.net.URL;
import java.util.*;

public class ControllerFavouriteMovies extends Controller {

    private MovieType selectedMovie;
    private HashMap<String, MovieType> moviesNames;
    @FXML
    ListView<String> favourite;
    @FXML
    Button remove;
    @FXML
    Button displayMovie;

    ControllerFavouriteMovies(String name, Controller previousController) {
        super(name, previousController);
    }

    @Override
    public void initialize(URL url, ResourceBundle resourceBundle) {
        Vector<MovieType> movies = Controller.database.getFavourites(Controller.currentUserDBver);
        moviesNames = new HashMap<>();
        for (MovieType x : movies) {
            moviesNames.put(x.getTitle() + " (" + x.getRelease_date().substring(0, 4) + ") ", x);
        }
        List<String> tmp = new LinkedList<>(moviesNames.keySet());
        favourite.setItems(FXCollections.observableList(tmp));
        remove.setDisable(true);
        displayMovie.setDisable(true);
        favourite.setOnMouseClicked(mouseEvent -> {
            if (favourite.getSelectionModel().getSelectedItems().size() == 0) return;
            if (favourite.getSelectionModel().getSelectedItems().get(0) != null) {
                selectedMovie = moviesNames.get(favourite.getSelectionModel().getSelectedItems().get(0));
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
        if (favourite.getSelectionModel().getSelectedItems().size() == 0) return;
        if (favourite.getSelectionModel().getSelectedItems().get(0) != null) {
            List<String> tmp = new LinkedList<>(moviesNames.keySet());
            MovieType movie = moviesNames.get(favourite.getSelectionModel().getSelectedItems().get(0));
            tmp.remove(favourite.getSelectionModel().getSelectedItems().get(0));
            MovieMarkType movieMark = database.getMovieMark(Controller.currentUserDBver, movie.getMovie_id());
            database.updateFromMovieRatings(new MovieMarkType(movie.getMovie_id(), currentUserDBver, movieMark.getMark(), null, movieMark.getSeen()));
            favourite.setItems(FXCollections.observableList(tmp));
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
