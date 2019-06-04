package Controllers;

import Types.MovieType;
import Types.PeopleType;
import javafx.fxml.FXML;
import javafx.scene.text.Text;

import java.io.IOException;
import java.net.URL;
import java.sql.SQLException;
import java.util.ResourceBundle;

public class ControllerAreYouSure extends Controller {
    private MovieType movie;
    private PeopleType person;
    private Boolean isMovie;
    @FXML
    Text toRemove;

    ControllerAreYouSure(String name, Controller previousController, MovieType movie) {
        super(name, previousController);
        this.movie = movie;
        isMovie = true;
    }

    ControllerAreYouSure(String name, Controller previousController, PeopleType person) {
        super(name, previousController);
        this.person = person;
        isMovie = false;
    }

    @Override
    public void initialize(URL url, ResourceBundle resourceBundle) {
        if (isMovie) {
            toRemove.setText(movie.getIdentifier() + "?");
            toRemove.setWrappingWidth(800);
        } else {
            toRemove.setText(person.getIdentifier() + "?");
            toRemove.setWrappingWidth(800);
        }

    }

    @FXML
    public void yes() {
        if (isMovie) {
            removeMovie();
        } else {
            removePerson();
        }
    }

    @FXML
    public void no() {
        try {
            super.goBack();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void removeMovie() {
        try {
            Controller.database.deleteForMovie("MOVIE", movie.getMovie_id());
            super.previousController.goBack();
        } catch (SQLException | IOException e) {
            System.out.println("FAILED TO DELETE MOVIE");
        }
    }

    private void removePerson() {
        try {
            Controller.database.deleteForPeople("PEOPLE", person.getPerson_id());
            super.previousController.goBack();
        } catch (SQLException | IOException e) {
            System.out.println("FAILED TO DELETE PERSON");
        }
    }
}
