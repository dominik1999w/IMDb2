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

public class ControllerInsertMovie extends Controller {

    ControllerInsertMovie(String name, Controller previousController) {
        super(name, previousController);
    }

    @FXML
    TextField title;
    @FXML
    TextArea alternative;
    @FXML
    TextField runtime;
    @FXML
    TextField release;
    @FXML
    TextArea languages;
    @FXML
    TextArea countries;
    @FXML
    TextArea production;
    @FXML
    TextField budget;
    @FXML
    TextField boxoffice;
    @FXML
    TextField weekend;
    @FXML
    TextArea description;

    @FXML
    MenuButton genreMenu;
    @FXML
    MenuButton nominationsMenu;
    @FXML
    MenuButton winsMenu;

    @FXML
    TextField findPerson;
    @FXML
    TextField findRole;
    @FXML
    TextField findCharacter;
    @FXML
    Button add;
    @FXML
    Button remove;
    @FXML
    ListView<String> crewList;

    @FXML
    TextField findSimilar;
    @FXML
    ListView<String> similarList;
    @FXML
    Button add1;
    @FXML
    Button remove1;

    @FXML
    Button submit;
    @FXML
    Text error;
    @FXML
    Text errorCrew;
    @FXML
    Text errorSimilar;

    private HashMap<String, PeopleType> peopleMap = new HashMap<>();
    private HashMap<String, MovieType> movieMap = new HashMap<>();
    private Vector<String> rolesMap = new Vector<>();
    private HashMap<String, CrewType> newCrew = new HashMap<>();
    private HashMap<String, MovieType> newSimilar = new HashMap<>();


    @Override
    public void initialize(URL url, ResourceBundle resourceBundle) {
        error.setVisible(false);
        errorCrew.setVisible(false);
        errorSimilar.setVisible(false);
        remove.setDisable(true);
        prepareMenu();

        for (PeopleType person : database.getPeople())
            peopleMap.put(person.getIdentifier(), person);
        TextFields.bindAutoCompletion(findPerson, peopleMap.keySet());

        for(MovieType movie : database.getMovies())
            movieMap.put(movie.getIdentifier(), movie);
        TextFields.bindAutoCompletion(findSimilar, movieMap.keySet());

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

        crewList.setOnMouseClicked(mouseEvent -> {
            if (crewList.getSelectionModel().getSelectedItems().size() == 0) return;
            if (crewList.getSelectionModel().getSelectedItems().get(0) != null) {
                remove.setDisable(false);
            } else {
                remove.setDisable(true);
            }
        });
    }

    private void prepareMenu() {
        for (String x : database.getGenre()) {
            CheckBox tmp = new CheckBox(x);
            CustomMenuItem item = new CustomMenuItem(tmp);
            item.setHideOnClick(false);
            genreMenu.getItems().add(item);
        }
        for (String x : database.getAwardsCategories("M").keySet()) {
            CheckBox tmp = new CheckBox(x);
            CustomMenuItem item = new CustomMenuItem(tmp);
            item.setHideOnClick(false);
            nominationsMenu.getItems().add(item);
        }
        for (String x : database.getAwardsCategories("M").keySet()) {
            CheckBox tmp = new CheckBox(x);
            CustomMenuItem item = new CustomMenuItem(tmp);
            item.setHideOnClick(false);
            winsMenu.getItems().add(item);
        }
    }

    @FXML
    public void add() {
        if (peopleMap.keySet().contains(findPerson.getText()) && rolesMap.contains(findRole.getText())) {
            errorCrew.setVisible(false);
            if ("Actor".equals(findRole.getText()))
                newCrew.put(findPerson.getText() + " -- " + findRole.getText() + " -- " + findCharacter.getText(),
                        new CrewType(peopleMap.get(findPerson.getText()).getPerson_id(), findRole.getText(), findCharacter.getText()));
            else
                newCrew.put(findPerson.getText() + " -- " + findRole.getText(),
                        new CrewType(peopleMap.get(findPerson.getText()).getPerson_id(), findRole.getText(), null));
            crewList.setItems(FXCollections.observableList(new LinkedList<>(newCrew.keySet())));
            findPerson.setText("");
            findRole.setText("");
            findCharacter.setText("");
            findCharacter.setDisable(true);
        } else {
            errorCrew.setVisible(true);
        }
    }

    @FXML
    public void remove() {
        if (crewList.getSelectionModel().getSelectedItems().size() == 0) return;
        if (crewList.getSelectionModel().getSelectedItems().get(0) != null) {
            newCrew.remove(crewList.getSelectionModel().getSelectedItems().get(0));
            crewList.setItems(FXCollections.observableList(new LinkedList<>(newCrew.keySet())));
        }
    }

    @FXML
    public void add1() {
        if (movieMap.keySet().contains(findSimilar.getText())) {
            errorSimilar.setVisible(false);
            newSimilar.put(findSimilar.getText(), movieMap.get(findSimilar.getText()));
            similarList.setItems(FXCollections.observableList(new LinkedList<>(newSimilar.keySet())));
            findSimilar.setText("");
        } else {
            errorSimilar.setVisible(true);
        }
    }

    @FXML
    public void remove1() {
        if (similarList.getSelectionModel().getSelectedItems().size() == 0) return;
        if (similarList.getSelectionModel().getSelectedItems().get(0) != null) {
            newSimilar.remove(similarList.getSelectionModel().getSelectedItems().get(0));
            similarList.setItems(FXCollections.observableList(new LinkedList<>(newSimilar.keySet())));
        }
    }

    @FXML
    public void submitMovie() {
        try {
            database.getConnection().setAutoCommit(false);
            ArrayList<Object> arguments = new ArrayList<>();
            int id = database.getIdOfMovie();

            arguments.add(title.getText());
            arguments.add(release.getText());
            arguments.add("".equals(runtime.getText()) ? null : Integer.valueOf(runtime.getText()));
            arguments.add("".equals(budget.getText()) ? null : Integer.valueOf(budget.getText()));
            arguments.add("".equals(boxoffice.getText()) ? null : Integer.valueOf(boxoffice.getText()));
            arguments.add("".equals(weekend.getText()) ? null : Integer.valueOf(weekend.getText()));
            arguments.add(description.getText());
            database.insert("movie", arguments);


            Vector<String> newCountries = RegexManager.convertStringToVector(countries.getText());
            for (String s : newCountries) {
                arguments.clear();
                arguments.add(id);
                arguments.add(s);
                database.insert("production", arguments);
            }

            Vector<String> newLanguages = RegexManager.convertStringToVector(languages.getText());
            for (String s : newLanguages) {
                arguments.clear();
                arguments.add(id);
                arguments.add(s);
                database.insert("movie_language", arguments);
            }

            Vector<String> newCompanies = RegexManager.convertStringToVector(production.getText());
            for (String s : newCompanies) {
                arguments.clear();
                arguments.add(id);
                arguments.add(s);
                database.insert("production_company", arguments);
            }

            Vector<String> newAlternative = RegexManager.convertStringToVector(alternative.getText());
            for (String s : newAlternative) {
                arguments.clear();
                arguments.add(id);
                arguments.add(s);
                database.insert("alternative_title", arguments);
            }

            Vector<String> newGenre = new Vector<>();
            for (MenuItem x : genreMenu.getItems()) {
                if (((CheckBox) (((CustomMenuItem) x).getContent())).isSelected()) {
                    //newGenre.add(x.getText());
                    newGenre.add(((CheckBox) (((CustomMenuItem) x).getContent())).getText());
                }
            }
            for (String s : newGenre) {
                arguments.clear();
                arguments.add(id);
                arguments.add(s);
                database.insert("movie_genre", arguments);
            }

            Vector<String> newNominations = new Vector<>();
            for (MenuItem x : nominationsMenu.getItems()) {
                if ( ((CheckBox) (((CustomMenuItem) x).getContent())) .isSelected()) {
                    //newNominations.add(x.getText());
                    newNominations.add(database.getAwardsCategories("M").get(((CheckBox) (((CustomMenuItem) x).getContent())).getText()));
                }
            }
            for (String s : newNominations) {
                arguments.clear();
                arguments.add(id);
                arguments.add(s);
                arguments.add("N");
                arguments.add(Integer.valueOf(release.getText().substring(0, 4)));
                database.insert("movie_awards", arguments);
            }

            Vector<String> newWins = new Vector<>();
            for (MenuItem x : winsMenu.getItems()) {
                if (((CheckBox) (((CustomMenuItem) x).getContent())).isSelected()) {
                    //newWins.add(x.getText());
                    newWins.add(database.getAwardsCategories("M").get(((CheckBox) (((CustomMenuItem) x).getContent())).getText()));
                }
            }
            for (String s : newWins) {
                arguments.clear();
                arguments.add(id);
                arguments.add(s);
                arguments.add("W");
                arguments.add(Integer.valueOf(release.getText().substring(0, 4)));
                database.insert("movie_awards", arguments);
            }

            for (CrewType member : newCrew.values()) {
                arguments.clear();
                arguments.add(member.getPerson_id());
                arguments.add(id);
                arguments.add(member.getRole());
                if ("Actor".equals(member.getRole()))
                    arguments.add(member.getCharacter());
                else
                    arguments.add(null);
                database.insert("crew", arguments);
            }

            for (MovieType mt : newSimilar.values()) {
                arguments.clear();
                arguments.add(id);
                arguments.add(mt.getMovie_id());
                database.insert("similar_movies", arguments);
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
