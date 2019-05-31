package Management;

import java.sql.*;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.*;
import Types.*;
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
    public Vector<MovieType> getMoviesWithOptions(Vector<String> genre, String year){
        Vector<MovieType> names= new Vector<>();
        try {
            Statement statement = connection.createStatement();
            StringBuilder tmp;
            if(genre.isEmpty()){
                tmp=new StringBuilder("select * from movie where movie_id in (select movie_id from movie_genre");
            }
            else {
                tmp = new StringBuilder("select * from movie where movie_id in (select movie_id from movie_genre where genre=");
                for (String x : genre) {
                    tmp.append("'").append(x).append("' or genre=");
                }
                tmp.delete(tmp.length() - 10, tmp.length());
            }
            tmp.append(")");
            tmp.append(" AND movie_year(movie_id)>=").append(year);
            tmp.append(";");
            ResultSet resultSet =  statement.executeQuery(String.valueOf(tmp));
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
            ResultSet resultSet =  statement.executeQuery("SELECT * FROM show_movie_ranking LIMIT 5;");
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
    public Vector<PersonRankingType> getActorsRanking(){
        Vector<PersonRankingType> names=new Vector<>();
        try {
            Statement statement = connection.createStatement();
            ResultSet resultSet =  statement.executeQuery("SELECT * FROM show_person_ranking LIMIT 5;");
            while(resultSet.next()){
                PersonRankingType a=new PersonRankingType(resultSet.getInt("ranking"),resultSet.getInt("person_id"),resultSet.getString("name"),
                        resultSet.getDouble("avg_mark"),resultSet.getInt("votes"));
                names.add(a);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return names;
    }
    public Vector<String> getGenre(){
        Vector<String> names=new Vector<>();
        try {
            Statement statement = connection.createStatement();
            ResultSet resultSet =  statement.executeQuery("select unnest(enum_range(NULL::genre_type));");
            while(resultSet.next()){
                names.add(resultSet.getString("unnest"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return names;
    }
    public Vector<MovieType> getWatchList(String login){
        Vector<MovieType> names= new Vector<>();
        try {
            Statement statement = connection.createStatement();
            StringBuilder tmp=new StringBuilder("select * from movie where movie_id in (select movie_id from watchlist where login='");
            tmp.append(login);
            tmp.append("');");
            ResultSet resultSet =  statement.executeQuery(String.valueOf(tmp));
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
    public void deleteFromWatchList(MovieType movieType, String currentUser) {
        try {
            Statement statement = connection.createStatement();
            StringBuilder tmp=new StringBuilder("delete from watchlist where login='");
            tmp.append(currentUser).append("' AND movie_id='").append(movieType.getMovie_id()).append("';");
            statement.executeUpdate(String.valueOf(tmp));
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


}
