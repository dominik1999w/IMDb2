package Controllers;


import Types.PeopleType;
import Types.PersonMarkType;
import javafx.collections.FXCollections;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.ListView;

import java.io.IOException;
import java.net.URL;
import java.util.*;

public class ControllerFavouritePeople extends Controller {

    private PeopleType selectedPerson;
    private HashMap<String, PeopleType> peopleNames;
    @FXML
    ListView<String> favourite;
    @FXML
    Button remove;
    @FXML
    Button displayPerson;

    ControllerFavouritePeople(String name, Controller previousController) {
        super(name, previousController);
    }

    @Override
    public void initialize(URL url, ResourceBundle resourceBundle) {
        Vector<PeopleType> people = Controller.database.getFavouritesP(Controller.currentUserDBver);
        peopleNames = new HashMap<>();
        for (PeopleType p : people) {
            peopleNames.put(p.getIdentifier(), p);
        }
        List<String> tmp = new LinkedList<>(peopleNames.keySet());
        favourite.setItems(FXCollections.observableList(tmp));
        remove.setDisable(true);
        displayPerson.setDisable(true);
        favourite.setOnMouseClicked(mouseEvent -> {
            if (favourite.getSelectionModel().getSelectedItems().size() == 0) return;
            if (favourite.getSelectionModel().getSelectedItems().get(0) != null) {
                selectedPerson = peopleNames.get(favourite.getSelectionModel().getSelectedItems().get(0));
                remove.setDisable(false);
                displayPerson.setDisable(false);
            } else {
                remove.setDisable(true);
                displayPerson.setDisable(true);
            }
        });
    }

    @FXML
    public void remove() {
        if (favourite.getSelectionModel().getSelectedItems().size() == 0) return;
        if (favourite.getSelectionModel().getSelectedItems().get(0) != null) {
            List<String> tmp = new LinkedList<>(peopleNames.keySet());
            PeopleType person = peopleNames.get(favourite.getSelectionModel().getSelectedItems().get(0));
            tmp.remove(favourite.getSelectionModel().getSelectedItems().get(0));
            PersonMarkType personMark = database.getPersonMark(Controller.currentUserDBver, person.getPerson_id());
            database.updateFromPersonRatings(new PersonMarkType(person.getPerson_id(), currentUserDBver, personMark.getMark(), null));
            favourite.setItems(FXCollections.observableList(tmp));
        }
    }

    @FXML
    public void displayPerson() {
        try {
            Controller.stageMaster.loadNewScene(new ControllerPersonScreen(Controller.scenesLocation + "/personScreen.fxml", this, selectedPerson));
        } catch (IOException e) {
            System.out.println("FAILED TO LOAD PERSONSCREEN");
        }
    }
}
