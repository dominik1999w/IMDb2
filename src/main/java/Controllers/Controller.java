package Controllers;

import Management.Database;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import Management.StageMaster;
import java.io.IOException;
import java.net.URL;
import java.util.ResourceBundle;

public abstract class Controller implements Initializable {

    public static StageMaster stageMaster;
    static Database database;
    static String currentUser;
    static String currentUserDBver;
    static final String scenesLocation = "/Scenes";
    static final String imagesLocation = "/Images";

    String name;
    Controller previousController;


    public String getName() {
        return this.name;
    }

    public Controller getPreviousController() {
        return this.previousController;
    }

    public void setPreviousScene(Controller controller) {
        this.previousController = controller;
    }


    public Controller() {}

    public Controller(String name) {
        this.name = name;
    }

    public Controller(String name, Controller previousController) {
        this.name = name;
        this.previousController = previousController;
    }

    @Override
    public abstract void initialize(URL url, ResourceBundle resourceBundle);

    @FXML
    public void goBack() throws IOException {
        Controller.stageMaster.loadPreviousScene();
    }
}