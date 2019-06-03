package Controllers;

import Management.RegexManager;
import Types.*;
import javafx.collections.FXCollections;
import javafx.fxml.FXML;
import javafx.scene.control.*;
import javafx.scene.text.Text;
import org.controlsfx.control.textfield.TextFields;

import java.io.IOException;
import java.net.URL;
import java.sql.SQLException;
import java.util.*;

public class ControllerEditDataPerson extends Controller {

    ControllerEditDataPerson(String name, Controller previousController, PeopleType person) {
        super(name, previousController);
        this.person = person;
    }

    private PeopleType person;

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
    public void goBack(){
        try {
            Controller.stageMaster.loadNewScene(new ControllerPersonScreen(Controller.scenesLocation + "/personScreen.fxml", previousController.previousController, database.getPersonByID(person.getPerson_id())));
        } catch (IOException e) {
            System.out.println("FAILED TO LOAD PERSONSCREEN");
        }
    }

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

        getData();
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
            int id = person.getPerson_id();

            arguments.add(died.getText());
            arguments.add(birthCountry.getText());
            database.updatePeople(id, arguments);

            database.deleteForPeople("profession", id);
            database.deleteForPeople("people_awards", id);
            database.deleteForPeople("crew", id);


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

    private void getData() {
        firstName.setText(person.getFirst_name());
        lastName.setText(person.getLast_name());
        born.setText(person.getBorn());
        firstName.setDisable(true);
        lastName.setDisable(true);
        born.setDisable(true);

        died.setText(person.getDied());
        birthCountry.setText(person.getBirth_country());

        professions.setText(RegexManager.convertIntoListNewLine(
                database.getSomethingForPerson(person.getPerson_id(), "profession", "profession"),false));

        Vector<String> movieNominations = database.getAwards(person.getPerson_id(), "N");
        for (MenuItem x : nominationsMenu.getItems()) {
            if (movieNominations.contains(((CheckBox) (((CustomMenuItem) x).getContent())).getText())){
                ((CheckBox) (((CustomMenuItem) x).getContent())).setSelected(true);
            }
        }

        Vector<String> movieWins = database.getAwards(person.getPerson_id(), "W");
        for (MenuItem x : winsMenu.getItems()) {
            if (movieWins.contains(((CheckBox) (((CustomMenuItem) x).getContent())).getText())) {
                ((CheckBox) (((CustomMenuItem) x).getContent())).setSelected(true);
            }
        }

        Vector<CrewTypeUpdate> movieCrew = database.getCrewP(person.getPerson_id());
        for (CrewTypeUpdate ctu : movieCrew){
            findMovie.setText(ctu.getIdentifier2());
            findRole.setText(ctu.getRole());
            findCharacter.setText(ctu.getCharacter());
            add();
        }
    }
}
