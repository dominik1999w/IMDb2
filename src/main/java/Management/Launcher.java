package Management;

import Controllers.Controller;
import Controllers.ControllerPrimary;
import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.stage.Stage;

public class Launcher extends Application {

    @Override
    public void start(Stage primaryStage) throws Exception{
        Controller controllerPrimary=new ControllerPrimary("/Scenes/sample.fxml",primaryStage);
        Controller.stageMaster.loadNewScene(controllerPrimary);
    }


    public static void main(String[] args) {
        launch(args);
    }
}
