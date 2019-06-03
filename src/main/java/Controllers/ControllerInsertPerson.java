package Controllers;

import Management.RegexManager;
import Types.CrewType;
import Types.MovieType;
import Types.PeopleType;
import javafx.collections.FXCollections;
import javafx.fxml.FXML;
import javafx.scene.control.*;
import javafx.scene.text.Text;
import org.controlsfx.control.textfield.TextFields;

import java.net.URL;
import java.sql.SQLException;
import java.util.*;

public class ControllerInsertPerson extends Controller {

    ControllerInsertPerson(String name, Controller previousController) {
        super(name, previousController);
    }

    @FXML
    TextField firstName;
    @FXML
    TextField lastName;
    @FXML
    TextField born;
    @FXML
    TextField died;
    @FXML
    TextField birthCountry;
    @FXML
    TextArea professions;

    @FXML
    MenuButton nominationsMenu;
    @FXML
    MenuButton winsMenu;

    @FXML
    TextField findMovie;
    @FXML
    TextField findRole;
    @FXML
    TextField findCharacter;
    @FXML
    Button add;
    @FXML
    Button remove;
    @FXML
    ListView<String> movieList;

    @FXML
    Button submit;
    @FXML
    Text error;
    @FXML
    Text errorCrew;

    private HashMap<String, MovieType> movieMap = new HashMap<>();
    private Vector<String> rolesMap = new Vector<>();
    private HashMap<String, CrewType> newCrew = new HashMap<>();


    @Override
    public void initialize(URL url, ResourceBundle resourceBundle) {
        error.setVisible(false);
        errorCrew.setVisible(false);
        remove.setDisable(true);
        prepareMenu();

        for(MovieType movie : database.getMovies())
            movieMap.put(movie.getIdentifier(), movie);
        TextFields.bindAutoCompletion(findMovie, movieMap.keySet());

        rolesMap = database.getRoles();
        TextFields.bindAutoCompletion(findRole, database.getRoles());

        findRole.setOnKeyReleased(event -> {
            if ("Actor".equals(findRole.getText())) {
                findCharacter.setDisable(false);
            } else {
                findCharacter.setText("");
                findCharacter.setDisable(true);
            }
        });

        movieList.setOnMouseClicked(mouseEvent -> {
            if (movieList.getSelectionModel().getSelectedItems().size() == 0) return;
            if (movieList.getSelectionModel().getSelectedItems().get(0) != null) {
                remove.setDisable(false);
            } else {
                remove.setDisable(true);
            }
        });
    }

    private void prepareMenu() {
        for (String x : database.getAwardsCategories("P").values()) {
            CheckBox tmp = new CheckBox(x);
            CustomMenuItem item = new CustomMenuItem(tmp);
            item.setHideOnClick(false);
            nominationsMenu.getItems().add(item);
        }
        for (String x : database.getAwardsCategories("P").values()) {
            CheckBox tmp = new CheckBox(x);
            CustomMenuItem item = new CustomMenuItem(tmp);
            item.setHideOnClick(false);
            winsMenu.getItems().add(item);
        }
    }

    @FXML
    public void add() {
        if (movieMap.keySet().contains(findMovie.getText()) && rolesMap.contains(findRole.getText())) {
            errorCrew.setVisible(false);
            int movie_id = movieMap.get(findMovie.getText()).getMovie_id();
            if ("Actor".equals(findRole.getText()))
                newCrew.put(findMovie.getText() + " -- " + findRole.getText() + " -- " + findCharacter.getText(),
                        new CrewType(findRole.getText(), movie_id, findCharacter.getText()));
            else
                newCrew.put(findMovie.getText() + " -- " + findRole.getText(),
                        new CrewType(findRole.getText(), movie_id, null));
            movieList.setItems(FXCollections.observableList(new LinkedList<>(newCrew.keySet())));
            findMovie.setText("");
            findRole.setText("");
            findCharacter.setText("");
            findCharacter.setDisable(true);
        } else {
            errorCrew.setVisible(true);
        }
    }

    @FXML
    public void remove() {
        if (movieList.getSelectionModel().getSelectedItems().size() == 0) return;
        if (movieList.getSelectionModel().getSelectedItems().get(0) != null) {
            newCrew.remove(movieList.getSelectionModel().getSelectedItems().get(0));
            movieList.setItems(FXCollections.observableList(new LinkedList<>(newCrew.keySet())));
        }
    }

    @FXML
    public void submitMovie() {
        try {
            database.getConnection().setAutoCommit(false);
            ArrayList<Object> arguments = new ArrayList<>();
            int id = database.getIdOfPerson();

            arguments.add(firstName.getText());
            arguments.add(lastName.getText());
            arguments.add(born.getText());
            arguments.add(died.getText());
            arguments.add(birthCountry.getText());
            database.insert("people", arguments);


            Vector<String> newProfessions = RegexManager.convertStringToVector(professions.getText());
            for (String s : newProfessions) {
                arguments.clear();
                arguments.add(id);
                arguments.add(s);
                database.insert("profession", arguments);
            }

            Vector<String> newNominations = new Vector<>();
            for (MenuItem x : nominationsMenu.getItems()) {
                if ( ((CheckBox) (((CustomMenuItem) x).getContent())) .isSelected()) {
                    newNominations.add(((CheckBox) (((CustomMenuItem) x).getContent())).getText());
                }
            }
            for (String s : newNominations) {
                arguments.clear();
                arguments.add(id);
                arguments.add(s);
                arguments.add("N");
                database.insert("people_awards", arguments);
            }

            Vector<String> newWins = new Vector<>();
            for (MenuItem x : winsMenu.getItems()) {
                if (((CheckBox) (((CustomMenuItem) x).getContent())).isSelected()) {
                    newWins.add(((CheckBox) (((CustomMenuItem) x).getContent())).getText());
                }
            }
            for (String s : newWins) {
                arguments.clear();
                arguments.add(id);
                arguments.add(s);
                arguments.add("W");
                database.insert("people_awards", arguments);
            }

            for (CrewType member : newCrew.values()) {
                arguments.clear();
                arguments.add(id);
                arguments.add(member.getMovie_id());
                arguments.add(member.getRole());
                if ("Actor".equals(member.getRole()))
                    arguments.add(member.getCharacter());
                else
                    arguments.add(null);
                database.insert("crew", arguments);
            }

            goBack();
        } catch (Exception e) {
            try {
                database.getConnection().rollback();
            } catch (SQLException e1) {
                e1.printStackTrace();
            }
            error.setVisible(true);
        } finally {
            try {
                database.getConnection().setAutoCommit(true);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

    }

}
