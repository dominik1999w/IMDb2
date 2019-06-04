package Controllers;

import Types.MovieRankingType;
import Types.MovieType;
import Types.PeopleType;
import Types.PersonRankingType;
import javafx.animation.KeyFrame;
import javafx.animation.Timeline;
import javafx.fxml.FXML;
import javafx.scene.control.*;
import javafx.scene.effect.DropShadow;
import javafx.scene.input.KeyCode;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.Pane;
import javafx.scene.text.Text;
import javafx.util.Duration;
import org.controlsfx.control.textfield.AutoCompletionBinding;
import org.controlsfx.control.textfield.TextFields;

import java.io.IOException;
import java.lang.reflect.Field;
import java.net.URL;
import java.util.Calendar;
import java.util.HashMap;
import java.util.ResourceBundle;
import java.util.Vector;

public class ControllerMainScreen extends Controller {
    ControllerMainScreen(String name, Controller previousController) {
        super(name, previousController);
    }

    private Vector<MovieType> movies;
    private Vector<PeopleType> people;
    private Vector<String> genre;
    private Vector<String> professions;
    private Vector<MovieRankingType> movieRanking;
    private Vector<PersonRankingType> personRanking;
    private HashMap<String, PeopleType> peopleNames;
    private HashMap<String, MovieType> moviesNames;
    private AutoCompletionBinding<String> movieCompletion;
    private AutoCompletionBinding<String> peopleCompletion;
    private String selectedMovie;
    private String selectedPerson;
    @FXML
    MenuButton categoryMenu;
    @FXML
    MenuButton professionMenu;
    @FXML
    GridPane rankingGrid1;
    @FXML
    GridPane rankingGrid2;
    @FXML
    Text welcomeText;
    @FXML
    TextField movieBrowser;
    @FXML
    TextField personBrowser;
    @FXML
    RadioButton filterButton;
    @FXML
    RadioButton filterButton2;
    @FXML
    Slider yearSlider;
    @FXML
    Text yearText;
    @FXML
    Button watchListButton;
    @FXML
    Button insertMovie;
    @FXML
    Button insertPerson;
    @FXML
    Text adminText;

    @Override
    public void initialize(URL url, ResourceBundle resourceBundle) {
        disableActionsForNoAdmins();
        welcomeText.setText("Welcome " + Controller.currentUser + "!");
        genre = Controller.database.getGenre();
        professions = Controller.database.getRoles();
        movieRanking = Controller.database.getRanking();
        personRanking = Controller.database.getActorsRanking();
        movies = Controller.database.getMovies();
        people = Controller.database.getPeople();
        Vector<PeopleType> people = Controller.database.getPeople();
        prepareMenu();
        setUpRanking();
        setUpPersonRanking();
        Tooltip a = new Tooltip("Watch List!");
        setTooltipTimer(a);
        watchListButton.setTooltip(a);
        yearSlider.setMax(Calendar.getInstance().get(Calendar.YEAR));
        yearSlider.valueProperty().addListener(((observable, oldValue, newValue) -> {
            yearText.setText(String.valueOf(newValue.intValue()));
            controlFilterButton();
        }));
        moviesNames = new HashMap<>();
        peopleNames = new HashMap<>();
        for (MovieType x : movies) {
            moviesNames.put(x.getTitle() + " (" + x.getRelease_date().substring(0, 4) + ") ", x);
        }
        for (PeopleType x : people) {
            peopleNames.put(x.getFirst_name() + " " + x.getLast_name() + "(" + x.getBorn().substring(0, 4) + ")", x);
        }
        movieCompletion = TextFields.bindAutoCompletion(movieBrowser, moviesNames.keySet());
        peopleCompletion = TextFields.bindAutoCompletion(personBrowser, peopleNames.keySet());
    }

    @FXML
    public void findMovie() {
        movieBrowser.setOnKeyPressed(event -> {
            if (event.getCode() == KeyCode.ENTER) {
                String s = String.valueOf(movieBrowser.getCharacters());
                if (!moviesNames.containsKey(s)) return; //invalid title
                movieBrowser.setText("");
                selectedMovie = s;
                displayInfo(moviesNames.get(selectedMovie));
            }
        });
    }

    @FXML
    public void findPerson() {
        personBrowser.setOnKeyPressed(event -> {
            if (event.getCode() == KeyCode.ENTER) {
                String s = String.valueOf(personBrowser.getCharacters());
                if (!peopleNames.containsKey(s)) return; //invalid title
                personBrowser.setText("");
                selectedPerson = s;
                displayInfo(peopleNames.get(selectedPerson));
            }
        });
    }

    private void displayInfo(MovieType movie) {
        try {
            Controller.stageMaster.loadNewScene(new ControllerMovieScreen(Controller.scenesLocation + "/movieScreen.fxml", this, movie));
        } catch (IOException e) {
            e.printStackTrace();
            System.out.println("FAILED TO LOAD MOVIESCREEN");
        }
    }

    private void displayInfo(PeopleType person) {
        try {
            Controller.stageMaster.loadNewScene(new ControllerPersonScreen(Controller.scenesLocation + "/personScreen.fxml", this, person));
        } catch (IOException e) {
            e.printStackTrace();
            System.out.println("FAILED TO LOAD MOVIESCREEN");
        }
    }

    @SuppressWarnings("Duplicates")
    private void setUpRanking() {
        for (int i = 0; i < 5; i++) {
            Pane pane = new Pane();
            pane.setStyle("-fx-border-color:black;" +
                    "-fx-text-fill:white;");
            pane.setEffect(new DropShadow());
            Label title = new Label(movieRanking.get(i).getTitle());
            Label votes = new Label("(" + movieRanking.get(i).getVotes() + " votes)");
            Label mark = new Label(String.valueOf(movieRanking.get(i).getAvg_mark()));
            Label ranking = new Label(String.valueOf(movieRanking.get(i).getRanking()));
            title.setStyle("-fx-text-fill:black;" +
                    "-fx-font-size: 17px");
            mark.setStyle("-fx-text-fill:darkred;" +
                    "-fx-font-size: 17px");
            votes.setStyle("-fx-text-fill:black;" +
                    "-fx-font-size: 15px");
            ranking.setStyle("-fx-text-fill:black;" +
                    "-fx-font-size: 13px");
            title.setTranslateX(5);
            title.setMaxWidth(230);
            mark.setTranslateY(100);
            mark.setTranslateX(10);
            votes.setTranslateX(10);
            votes.setTranslateY(120);
            votes.setMaxWidth(200);
            ranking.setTranslateY(133);
            ranking.setTranslateX(230);
            pane.getChildren().addAll(title, mark, votes, ranking);

            final int j = i;
            pane.setOnMouseClicked(event -> displayInfo(database.getMovieByID(movieRanking.get(j).getMovie_id())));
            rankingGrid1.add(pane, i, 0);
        }
    }

    private void disableActionsForNoAdmins() {
        if (!Controller.database.isAdmin(Controller.currentUser)) { //not admin
            adminText.setVisible(false);
            insertPerson.setDisable(true);
            insertPerson.setVisible(false);
            insertMovie.setDisable(true);
            insertMovie.setVisible(false);
        }
    }

    @SuppressWarnings("Duplicates")
    private void setUpPersonRanking() {
        for (int i = 0; i < 5; i++) {
            Pane pane = new Pane();
            pane.setStyle("-fx-border-color:black;" +
                    "-fx-text-fill:white;");
            pane.setEffect(new DropShadow());
            Label title = new Label(personRanking.get(i).getName());
            Label votes = new Label("(" + personRanking.get(i).getVotes() + " votes)");
            Label mark = new Label(String.valueOf(personRanking.get(i).getAvg_mark()));
            Label ranking = new Label(String.valueOf(personRanking.get(i).getRanking()));
            title.setStyle("-fx-text-fill:black;" +
                    "-fx-font-size: 17px");
            mark.setStyle("-fx-text-fill:darkred;" +
                    "-fx-font-size: 17px");
            votes.setStyle("-fx-text-fill:black;" +
                    "-fx-font-size: 15px");
            ranking.setStyle("-fx-text-fill:black;" +
                    "-fx-font-size: 13px");
            title.setTranslateX(5);
            title.setMaxWidth(230);
            mark.setTranslateY(100);
            mark.setTranslateX(10);
            votes.setTranslateX(10);
            votes.setTranslateY(120);
            votes.setMaxWidth(200);
            ranking.setTranslateY(133);
            ranking.setTranslateX(230);
            pane.getChildren().addAll(title, mark, votes, ranking);

            final int j = i;
            pane.setOnMouseClicked(event -> displayInfo(database.getPersonByID(personRanking.get(j).getPerson_id())));

            rankingGrid2.add(pane, i, 0);
        }
    }

    private void prepareMenu() {
        for (String x : genre) {
            CheckBox tmp = new CheckBox(x);
            CustomMenuItem item = new CustomMenuItem(tmp);
            item.setHideOnClick(false);
            item.setOnAction(t -> controlFilterButton());
            categoryMenu.getItems().add(item);
        }
        for (String x : professions) {
            CheckBox tmp = new CheckBox(x);
            CustomMenuItem item = new CustomMenuItem(tmp);
            item.setHideOnClick(false);
            item.setOnAction(t -> controlFilterButton2());
            professionMenu.getItems().add(item);
        }
    }

    @FXML
    public void controlFilterButton2() {
        if (filterButton2.isSelected()) {
            filterSearch2();
        } else {
            removeFilterFun2();
        }
    }

    private void filterSearch2() {
        Vector<String> filterProfessions = new Vector<>();
        for (MenuItem x : professionMenu.getItems()) {
            if (((CheckBox) (((CustomMenuItem) x).getContent())).isSelected()) {
                filterProfessions.add(((CheckBox) (((CustomMenuItem) x).getContent())).getText());
            }
        }
        if (filterProfessions.isEmpty()) return;
        peopleNames.clear();
        for (PeopleType x : Controller.database.getPeopleWithOptions(filterProfessions)) {
            peopleNames.put(x.getFirst_name() + " " + x.getLast_name() + "(" + x.getBorn().substring(0, 4) + ")", x);
        }
        peopleCompletion.dispose();
        peopleCompletion = TextFields.bindAutoCompletion(personBrowser, peopleNames.keySet());
    }

    private void removeFilterFun2() {
        peopleNames.clear();
        for (PeopleType x : people) {
            peopleNames.put(x.getFirst_name() + " " + x.getLast_name() + "(" + x.getBorn().substring(0, 4) + ")", x);
        }
        peopleCompletion.dispose();
        peopleCompletion = TextFields.bindAutoCompletion(personBrowser, peopleNames.keySet());
    }
    @FXML
    public void controlFilterButton() {
        if (filterButton.isSelected()) {
            filterSearch();
        } else {
            removeFilterFun();
        }
    }

    private void filterSearch() {
        Vector<String> filterGenre = new Vector<>();
        for (MenuItem x : categoryMenu.getItems()) {
            if (((CheckBox) (((CustomMenuItem) x).getContent())).isSelected()) {
                filterGenre.add(((CheckBox) (((CustomMenuItem) x).getContent())).getText());
            }
        }
        //update movieBrowser with new selected genre
        moviesNames.clear();
        for (MovieType x : Controller.database.getMoviesWithOptions(filterGenre, yearText.getText())) {
            moviesNames.put(x.getIdentifier(), x);
        }
        movieCompletion.dispose();
        movieCompletion = TextFields.bindAutoCompletion(movieBrowser, moviesNames.keySet());

    }

    private void removeFilterFun() {
        moviesNames.clear();
        for (MovieType x : movies) {
            moviesNames.put(x.getIdentifier(), x);
        }
        movieCompletion.dispose();
        movieCompletion = TextFields.bindAutoCompletion(movieBrowser, moviesNames.keySet());
    }

    @FXML
    public void logOut() {
        try {
            stageMaster.loadNewScene(new ControllerPrimary(scenesLocation + "/sample.fxml"));
            System.out.println(currentUser + " logged out.");
        } catch (IOException e) {
            System.out.println("FAILED TO LOG OUT");
        }
    }

    @FXML
    public void displayWatchList() {
        Controller controllerWatchList = new ControllerWatchList(Controller.scenesLocation + "/watchList.fxml", this);
        try {
            Controller.stageMaster.loadNewScene(controllerWatchList);
        } catch (IOException e) {
            e.printStackTrace();
        }
        /*Stage s = new Stage();
        StageMaster stageMaster = new StageMaster(s);
        stageMaster.setResizable(false);
        stageMaster.setName("Watch List!");
        try {
            stageMaster.loadNewScene(controllerWatchList);
        } catch (IOException e) {
            System.out.println("FAILED TO LOAD WATCHLIST!");
        }*/

    }

    @FXML
    public void displayFavouriteMovies() {
        Controller controllerWatchList = new ControllerFavouriteMovies(Controller.scenesLocation + "/favourite.fxml", this);
        try {
            Controller.stageMaster.loadNewScene(controllerWatchList);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @FXML
    public void displayFavouritePeople() {
        Controller controllerWatchList = new ControllerFavouritePeople(Controller.scenesLocation + "/favouriteP.fxml", this);
        try {
            Controller.stageMaster.loadNewScene(controllerWatchList);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void setTooltipTimer(Tooltip tooltip) {
        try {
            Field fieldBehavior = tooltip.getClass().getDeclaredField("BEHAVIOR");
            fieldBehavior.setAccessible(true);
            Object objBehavior = fieldBehavior.get(tooltip);
            Field fieldTimer = objBehavior.getClass().getDeclaredField("activationTimer");
            fieldTimer.setAccessible(true);
            Timeline objTimer = (Timeline) fieldTimer.get(objBehavior);
            objTimer.getKeyFrames().clear();
            objTimer.getKeyFrames().add(new KeyFrame(new Duration(200)));
        } catch (Exception e) {//e.printStackTrace();
            //System.out.println("NIE WAŻNY WYJĄTEK ;))))))))))))");
        }
    }

    @FXML
    public void insertMovie() {
        try {
            Controller.stageMaster.loadNewScene(new ControllerInsertMovie(Controller.scenesLocation + "/movieInsertScreen.fxml", this));
        } catch (IOException e) {
            e.printStackTrace();
            System.out.println("FAILED TO LOAD MOVIESCREEN");
        }
    }

    @FXML
    public void insertPerson() {
        try {
            Controller.stageMaster.loadNewScene(new ControllerInsertPerson(Controller.scenesLocation + "/personInsertScreen.fxml", this));
        } catch (IOException e) {
            e.printStackTrace();
            System.out.println("FAILED TO LOAD MOVIESCREEN");
        }
    }
}
