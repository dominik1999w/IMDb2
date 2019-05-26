package Controllers;

import Management.Database;
import Management.StageMaster;
import javafx.fxml.FXML;
import javafx.scene.control.TextField;
import javafx.scene.input.KeyCode;
import javafx.scene.text.Text;
import javafx.stage.Stage;
import org.controlsfx.control.textfield.TextFields;

import java.io.File;
import java.net.URL;
import java.util.ResourceBundle;
import java.util.Vector;

public class mainScreenController extends Controller {
    mainScreenController(String name, Controller previousController){
        super(name,previousController);
    }
    private Vector<String> moviesNames;
    String selectedMovie;
    @FXML
    Text welcomeText;
    @FXML
    Text movieTitle;
    @FXML
    TextField movieBrowser;
    @Override
    public void initialize(URL url, ResourceBundle resourceBundle) {
        welcomeText.setText("Welcome "+Controller.currentUser+"!");
        moviesNames=Controller.database.getMovies();
        TextFields.bindAutoCompletion(movieBrowser,moviesNames);
    }
    public void findMovie(){
        movieBrowser.setOnKeyPressed(event->{
            if(event.getCode()== KeyCode.ENTER){
                String s=String.valueOf(movieBrowser.getCharacters());
                if(!moviesNames.contains(s)) return; //invalid title
                movieBrowser.setText("");
                selectedMovie=s;
                displayInfo(selectedMovie);
                movieTitle.setText(s);
            }
        });
    }
    private void displayInfo(String selectedMovie){

    }
}
