package Controllers;

import Management.StageMaster;
import javafx.fxml.Initializable;
import javafx.stage.Stage;

import java.net.URL;
import java.util.ResourceBundle;

public class ControllerPrimary extends Controller implements Initializable {
    public ControllerPrimary(String name, Stage stage) {
        this.name = name;
        this.previousController = this;
        Controller.stageMaster = new StageMaster(stage); //One and only stageMaster
    }

    @Override
    public void initialize(URL url, ResourceBundle resourceBundle) {
    }
}
