package Controllers;

import Management.Database;
import Management.MurmurHash;
import Management.RegexManager;
import Management.StageMaster;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.Button;
import javafx.scene.control.TextField;
import javafx.scene.text.Text;
import javafx.stage.Stage;

import java.io.IOException;
import java.net.URL;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.ResourceBundle;

public class ControllerPrimary extends Controller implements Initializable {

    public ControllerPrimary(String name, Stage stage) {
        this.name = name;
        this.previousController = this;
        Controller.stageMaster = new StageMaster(stage); //One and only stageMaster
        Controller.database = new Database(); //First set-up : see type of constructors
    }

    ControllerPrimary(String name) {
        this.name = name;
        this.previousController = null;
    }

    @FXML
    TextField signInLoginField;
    @FXML
    TextField signInPasswordField;
    @FXML
    TextField signUpLoginField;
    @FXML
    TextField signUpPasswordField;
    @FXML
    TextField signUpPasswordFieldConfirm;
    @FXML
    Text signInError;
    @FXML
    Text signUpError;
    @FXML
    Text signUpSuccess;
    @FXML
    Button confirmSignIn;
    @FXML
    Button confirmSignUp;

    @Override
    public void initialize(URL url, ResourceBundle resourceBundle) {
        zeroAnnotations();
    }

    private void zeroAnnotations() {
        signInError.setText("");
        signUpError.setText("");
        signUpSuccess.setText("");
    }

    //LOGIN+REGISTRATION----------------------------------------------------
    @FXML
    public void signIn() {
        zeroAnnotations();
        String login = signInLoginField.getText();
        Integer password = MurmurHash.hash64(signInPasswordField.getText());
        HashMap<String, Integer> users = database.getUsers();

        if (!RegexManager.isSafe(login)) {
            signInError.setText("Error: only safe characters!");
            return;
        }

        if (!users.containsKey(login)) {
            signInError.setText("Error: such user doesn't exist!");
            return;
        }

        Integer realHashedPassword = users.get(login);
        if (!password.equals(realHashedPassword)) {
            signInError.setText("Error: wrong password!");
            return;
        }

        signInError.setText("");
        currentUser = login;
        currentUserDBver = RegexManager.convertIntoPreparedConsistent(currentUser);
        System.out.println(currentUser + " is logged in.");
        signInLoginField.setText("");
        signInPasswordField.setText("");
        //open mainScreen
        try {
            Controller.stageMaster.loadNewScene(new ControllerMainScreen("/Scenes/mainScreen.fxml", this));
        } catch (IOException e) {
            e.printStackTrace();
            System.out.println("FAILED TO LOAD mainScreen.fxml");
        }

    }

    @FXML
    public void signUp() {
        zeroAnnotations();
        String login = signUpLoginField.getText();
        Integer password = MurmurHash.hash64(signUpPasswordField.getText());
        Integer passwordConfirm = MurmurHash.hash64(signUpPasswordFieldConfirm.getText());

        HashMap<String, Integer> users = database.getUsers();

        if (!RegexManager.isSafe(login)) {
            signUpError.setText("Error: only safe characters!");
            return;
        }

        if (users.containsKey(login)) {
            signUpError.setText("Error: such user already exists!");
            return;
        }

        if (!password.equals(passwordConfirm)) {
            signUpError.setText("Error: passwords don't match!");
            return;
        }

        ArrayList<Object> arguments = new ArrayList<>();
        arguments.add("'" + login + "'");
        arguments.add(password);
        arguments.add(false);

        try {
            database.insert("users", arguments);
        } catch (SQLException e) {
            signUpError.setText("Error: something wrong with database...");
            e.printStackTrace();
            return;
        }

        signUpSuccess.setText("You can now log in :)");
        signUpLoginField.setText("");
        signUpPasswordField.setText("");
        signUpPasswordFieldConfirm.setText("");
    }
//----------------------------------------------------------------------------


}
