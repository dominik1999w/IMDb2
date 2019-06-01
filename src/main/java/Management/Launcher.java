package Management;

import Controllers.Controller;
import Controllers.ControllerPrimary;
import javafx.application.Application;
import javafx.stage.Stage;

public class Launcher extends Application {
    @Override
    public void start(Stage primaryStage) throws Exception {
        System.out.println("START");
        Controller controllerPrimary = new ControllerPrimary( "/Scenes/sample.fxml", primaryStage);
        primaryStage.setResizable(false);
        Controller.stageMaster.loadNewScene(controllerPrimary);
    }


    public static void main(String[] args) {
        launch(args);
    }
}
