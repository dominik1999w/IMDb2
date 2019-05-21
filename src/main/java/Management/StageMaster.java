package Management;

import Controllers.Controller;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.scene.layout.Pane;
import javafx.stage.Stage;

import java.io.IOException;

public class StageMaster {

    private Controller currentController;
    private Stage stage;

    public StageMaster(Stage stage) {
        this.stage = stage;
    }

    //While pressing buttons those methods should be applied:

    public void loadNewScene(Controller controller) throws IOException {
        //Controller should be created while pressing button.
        this.currentController = controller;
        loadScene(currentController.getName());
    }

    public void loadPreviousScene() throws IOException {
        loadNewScene(currentController.getPreviousController());
    }

    private void loadScene(String name) throws IOException {
        boolean wasMaximized = false;
        if(stage.isMaximized()) {
            stage.setMaximized(false);
            wasMaximized = true;
        }
        System.out.println("LOADING: " + name);
        FXMLLoader loader = new FXMLLoader(currentController.getClass().getResource(name));
        loader.setController(currentController);
        Pane myPane = loader.load();
        this.stage.setScene(new Scene(myPane));
        stage.show();
        if(wasMaximized){
            stage.setMaximized(true);
        }
    }
    public void setName(String name){
        stage.setTitle(name);
    }
    public void setResizable(boolean resizable){
        stage.setResizable(resizable);
    }
    public void refresh(Controller controller) throws IOException {
        Controller.stageMaster.loadNewScene(controller);
    }


}
