package Management;

import java.sql.*;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.*;
import Types.MovieType;
import Types.PeopleType;
import Types.MovieRankingType;
public class Database {

    private String SERVER_ADDRESS;
    private String PORT;
    private String DATABASE_NAME;
    private String USER_NAME;
    private String PASSWORD;

    private Connection connection;

    public Connection getConnection() {
        return connection;
    }

    private void loadParameters() {
        Properties properties = new Properties();
        InputStream inputStream = null;

        try {
            File file = new File("config.properties");
            inputStream = new FileInputStream(file);
            properties.load(inputStream);
        } catch(Exception e) {
            System.out.println("READING properties FAILED.");
        }

        SERVER_ADDRESS = properties.getProperty("SERVER_ADDRESS");
        PORT = properties.getProperty("PORT");
        DATABASE_NAME = properties.getProperty("DATABASE_NAME");
        USER_NAME = properties.getProperty("USER_NAME");
        PASSWORD = properties.getProperty("PASSWORD");
    }

    public Database() {
        loadParameters();
        try {
            connection = DriverManager
                    .getConnection("jdbc:postgresql://" + SERVER_ADDRESS + ':' + PORT + '/' + DATABASE_NAME, USER_NAME, PASSWORD);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void insert(String table, ArrayList<String> arguments) throws SQLException{ //separated by commas
        Statement statement = connection.createStatement();
        StringBuffer queryBuffer = new StringBuffer("INSERT INTO " + table + " VALUES( ");
        for(String arg : arguments)
            queryBuffer.append(arg).append(",");
        queryBuffer.deleteCharAt(queryBuffer.length() - 1);
        queryBuffer.append(" );");
        String query = queryBuffer.toString();

        statement.executeUpdate(query);
    }

// GET DATA-----------------------------------------------------------------

    public HashMap<String,Integer> getUsers(){
        HashMap<String,Integer> users = new HashMap<>();
        try {
            Statement statement = connection.createStatement();
            ResultSet resultSet =  statement.executeQuery("SELECT * FROM users;");
            while(resultSet.next()){
                users.put(resultSet.getString(1),resultSet.getInt(2));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }
    public Vector<MovieType> getMovies(){
        Vector<MovieType> names= new Vector<>();
        try {
            Statement statement = connection.createStatement();
            ResultSet resultSet =  statement.executeQuery("SELECT * FROM movie;");
            while(resultSet.next()){
                MovieType a=new MovieType(resultSet.getInt("movie_id"),resultSet.getString("title"),resultSet.getString("release_date"),
                        resultSet.getString("runtime"),resultSet.getInt("budget"),resultSet.getInt("boxoffice"),resultSet.getInt("opening_weekend_usa"),resultSet.getString("description"));
                names.add(a);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return names;
    }
    public Vector<PeopleType> getPeople(){
        Vector<PeopleType> names= new Vector<>();
        try {
            Statement statement = connection.createStatement();
            ResultSet resultSet =  statement.executeQuery("SELECT * FROM people;");
            while(resultSet.next()){
                PeopleType a=new PeopleType(resultSet.getInt("person_id"),resultSet.getString("first_name"),resultSet.getString("last_name"),
                        resultSet.getString("born"),resultSet.getString("died"),resultSet.getString("birth_country"));
                names.add(a);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return names;
    }
    public Vector<MovieRankingType> getRanking(){
        Vector<MovieRankingType> names=new Vector<>();
        try {
            Statement statement = connection.createStatement();
            ResultSet resultSet =  statement.executeQuery("SELECT * FROM show_movie_ranking LIMIT 10;");
            while(resultSet.next()){
                MovieRankingType a=new MovieRankingType(resultSet.getInt("ranking"),resultSet.getInt("movie_id"),resultSet.getString("title"),
                        resultSet.getDouble("avg_mark"),resultSet.getInt("votes"));
                names.add(a);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return names;
    }
}
