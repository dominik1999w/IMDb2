package Management;

import java.sql.*;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.sql.Date;
import java.util.*;
import java.util.concurrent.locks.Condition;

import Controllers.Controller;
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
        } catch (Exception e) {
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

    public void insert(String table, ArrayList<Object> arguments) throws SQLException { //separated by commas

        arguments = RegexManager.convertArrayIntoPreparedConsistent(arguments);

        StringBuilder stringBuilder = new StringBuilder("INSERT INTO " + table + " VALUES(");
        switch (table) {
            case "movie":
                stringBuilder.append("DEFAULT,?,?,?,?,?,?,?");
                break;
            case "users":
                stringBuilder.append("?,?");
                break;
            case "movie_ratings":
                stringBuilder.append("?,?,?,?,DEFAULT");
                break;
            case "watchlist":
                stringBuilder.append("?,?");
                break;
            default:
                System.out.println("ERROR - no such table");
                throw new SQLException();
        }

        stringBuilder.append(");");
        String query = stringBuilder.toString();
        PreparedStatement preparedStatement = connection.prepareStatement(query);

        switch (table) {
            case "movie":
                preparedStatement.setString(1, (String) arguments.get(0));
                preparedStatement.setDate(2, (Date) arguments.get(1));
                preparedStatement.setString(3, (String) arguments.get(2));
                preparedStatement.setInt(4, (Integer) arguments.get(3));
                preparedStatement.setInt(5, (Integer) arguments.get(4));
                preparedStatement.setInt(6, (Integer) arguments.get(5));
                preparedStatement.setString(7, (String) arguments.get(6));
                break;
            case "users":
                preparedStatement.setString(1, (String) arguments.get(0));
                preparedStatement.setInt(2, (Integer) arguments.get(1));
                break;
            case "movie_ratings" :
                preparedStatement.setInt(1, (Integer) arguments.get(0));
                preparedStatement.setString(2, (String) arguments.get(1));
                preparedStatement.setInt(3, (Integer) arguments.get(2));
                preparedStatement.setString(4, (String) arguments.get(3));
                break;
            case "watchlist" :
                preparedStatement.setString(1, (String) arguments.get(0));
                preparedStatement.setInt(2, (Integer) arguments.get(1));
                break;
            default:
                System.out.println("ERROR - no such table");
                throw new SQLException();
        }

        preparedStatement.executeUpdate();
    }

// GET DATA-----------------------------------------------------------------

    public HashMap<String, Integer> getUsers() {

        HashMap<String, Integer> users = new HashMap<>();
        try {
            Statement statement = connection.createStatement();
            ResultSet resultSet = statement.executeQuery("SELECT * FROM users;");
            while (resultSet.next()) {
                users.put(resultSet.getString(1).replaceAll("'", ""), resultSet.getInt(2));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }

    public Vector<MovieType> getMovies() {
        Vector<MovieType> names = new Vector<>();
        try {
            Statement statement = connection.createStatement();
            ResultSet resultSet = statement.executeQuery("SELECT * FROM movie;");
            while (resultSet.next()) {
                MovieType a = new MovieType(resultSet.getInt("movie_id"), resultSet.getString("title"), resultSet.getDate("release_date"),
                        resultSet.getString("runtime"), resultSet.getInt("budget"), resultSet.getInt("boxoffice"), resultSet.getInt("opening_weekend_usa"), resultSet.getString("description"));
                names.add(a);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return names;
    }

    public Vector<MovieType> getMoviesWithOptions(Vector<String> genre, String year) {
        Vector<MovieType> names = new Vector<>();
        try {
            Statement statement = connection.createStatement();
            StringBuilder tmp;
            if (genre.isEmpty()) {
                tmp = new StringBuilder("select * from movie where movie_id in (select movie_id from movie_genre");
            } else {
                tmp = new StringBuilder("select * from movie where movie_id in (select movie_id from movie_genre where genre=");
                for (String x : genre) {
                    tmp.append("'").append(x).append("' or genre=");
                }
                tmp.delete(tmp.length() - 10, tmp.length());
            }
            tmp.append(")");
            tmp.append(" AND movie_year(movie_id)>=").append(year);
            tmp.append(";");
            ResultSet resultSet = statement.executeQuery(String.valueOf(tmp));
            while (resultSet.next()) {
                MovieType a = new MovieType(resultSet.getInt("movie_id"), resultSet.getString("title"), resultSet.getDate("release_date"),
                        resultSet.getString("runtime"), resultSet.getInt("budget"), resultSet.getInt("boxoffice"), resultSet.getInt("opening_weekend_usa"), resultSet.getString("description"));
                names.add(a);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return names;
    }

    public Vector<PeopleType> getPeople() {
        Vector<PeopleType> names = new Vector<>();
        try {
            Statement statement = connection.createStatement();
            ResultSet resultSet = statement.executeQuery("SELECT * FROM people;");
            while (resultSet.next()) {
                PeopleType a = new PeopleType(resultSet.getInt("person_id"), resultSet.getString("first_name"), resultSet.getString("last_name"),
                        resultSet.getString("born"), resultSet.getString("died"), resultSet.getString("birth_country"));
                names.add(a);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return names;
    }

    public Vector<MovieRankingType> getRanking() {
        Vector<MovieRankingType> names = new Vector<>();
        try {
            PreparedStatement preparedStatement = connection.prepareStatement(
                    "SELECT * FROM show_movie_ranking LIMIT 5;");
            ResultSet resultSet = preparedStatement.executeQuery();

            while (resultSet.next()) {
                MovieRankingType a = new MovieRankingType(resultSet.getInt("ranking"), resultSet.getInt("movie_id"), resultSet.getString("title"),
                        resultSet.getDouble("avg_mark"), resultSet.getInt("votes"));
                names.add(a);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return names;
    }

    public Vector<PersonRankingType> getActorsRanking() {
        Vector<PersonRankingType> names = new Vector<>();
        try {
            Statement statement = connection.createStatement();
            ResultSet resultSet = statement.executeQuery("SELECT * FROM show_person_ranking LIMIT 5;");
            while (resultSet.next()) {
                PersonRankingType a = new PersonRankingType(resultSet.getInt("ranking"), resultSet.getInt("person_id"), resultSet.getString("name"),
                        resultSet.getDouble("avg_mark"), resultSet.getInt("votes"));
                names.add(a);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return names;
    }

    public Vector<String> getGenre() {
        Vector<String> names = new Vector<>();
        try {
            Statement statement = connection.createStatement();
            ResultSet resultSet = statement.executeQuery("select unnest(enum_range(NULL::genre_type));");
            while (resultSet.next()) {
                names.add(resultSet.getString("unnest"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return names;
    }

    public Vector<MovieType> getWatchList(String login) {
        Vector<MovieType> names = new Vector<>();
        try {
            PreparedStatement preparedStatement = connection.prepareStatement(
                    "select * from movie where movie_id in (select movie_id from watchlist where login = ? );");
            preparedStatement.setString(1, login);
            ResultSet resultSet = preparedStatement.executeQuery();
            while (resultSet.next()) {
                MovieType a = new MovieType(resultSet.getInt("movie_id"), resultSet.getString("title"), resultSet.getDate("release_date"),
                        resultSet.getString("runtime"), resultSet.getInt("budget"), resultSet.getInt("boxoffice"), resultSet.getInt("opening_weekend_usa"), resultSet.getString("description"));
                names.add(a);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return names;
    }

    public Vector<String> getSomethingForMovie(int id, String table, String column) {
        Vector<String> result = new Vector<>();
        try {
            PreparedStatement preparedStatement = connection.prepareStatement(
                    "SELECT " + column + " FROM " + table + " WHERE movie_id = " + id + ";"
            );

            ResultSet resultSet = preparedStatement.executeQuery();
            while (resultSet.next()) {
                result.add(resultSet.getString(column));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    public Vector<String> getPeopleForMovie(int id, String role) {
        Vector<String> result = new Vector<>();
        try {
            PreparedStatement preparedStatement;
            if (role.equals("Actor")) {
                preparedStatement = connection.prepareStatement(
                        "SELECT first_name, last_name, character FROM crew JOIN people USING(person_id) WHERE movie_id = " + id + " AND role = 'Actor';");
            } else if (role.equals("Others")) {
                preparedStatement = connection.prepareStatement(
                        "SELECT role, first_name, last_name FROM crew JOIN people USING(person_id) WHERE movie_id = " + id +
                                " AND role IS DISTINCT FROM 'Director' AND role  IS DISTINCT FROM 'Writer' AND role IS DISTINCT FROM 'Actor';");
            } else {
                preparedStatement = connection.prepareStatement(
                        "SELECT first_name, last_name FROM crew JOIN people USING(person_id) WHERE movie_id = " + id + " AND role = '" + role + "';");
            }

            ResultSet resultSet = preparedStatement.executeQuery();
            while (resultSet.next()) {
                if (role.equals("Actor")) {
                    String character = resultSet.getString("character");
                    if (character != null)
                        result.add(resultSet.getString("first_name") + " " + resultSet.getString("last_name") + " (" + resultSet.getString("character") + ")");
                    else
                        result.add(resultSet.getString("first_name") + " " + resultSet.getString("last_name"));
                } else if (role.equals("Others"))
                    result.add(resultSet.getString("role") + ": " + resultSet.getString("first_name") + " " + resultSet.getString("last_name"));
                else
                    result.add(resultSet.getString("first_name") + " " + resultSet.getString("last_name"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }


    public MovieRankingType getMovieRating(int id) {
        MovieRankingType movieRankingType = null;
        try {
            PreparedStatement preparedStatement = connection.prepareStatement(
                    "SELECT * FROM show_movie_ranking WHERE movie_id = ?;");
            preparedStatement.setInt(1, id);
            ResultSet resultSet = preparedStatement.executeQuery();

            if (resultSet.next())
                movieRankingType = new MovieRankingType(resultSet.getInt("ranking"), resultSet.getInt("movie_id"), resultSet.getString("title"),
                        resultSet.getDouble("avg_mark"), resultSet.getInt("votes"));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return movieRankingType;
    }

    public MovieMarkType getMovieMark(String user, int id) {
        MovieMarkType movieMark = null;
        try {
            PreparedStatement preparedStatement = connection.prepareStatement(
                    "SELECT * FROM movie_ratings WHERE movie_id = ? AND login = ?;");
            preparedStatement.setInt(1, id);
            preparedStatement.setString(2, user);
            ResultSet resultSet = preparedStatement.executeQuery();
            if(resultSet.next()) {
                String heart = resultSet.getString("heart");
                if(heart != null)
                    movieMark = new MovieMarkType(resultSet.getInt("movie_id"), resultSet.getString("login"), resultSet.getInt("mark"),
                            heart, resultSet.getDate("seen"));
                else
                    movieMark = new MovieMarkType(resultSet.getInt("movie_id"), resultSet.getString("login"), resultSet.getInt("mark"),
                            "N", resultSet.getDate("seen"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return movieMark;
    }

// DELETE ---------------------------------------------------------------------------------------------------------------------------------------

    public void deleteFromWatchList(MovieType movieType, String currentUser) {
        try {
            PreparedStatement preparedStatement = connection.prepareStatement(
            "delete from watchlist where login = ? AND movie_id = ? ;");
            preparedStatement.setString(1, currentUser);
            preparedStatement.setInt(2, movieType.getMovie_id());
            preparedStatement.execute();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void deleteFromMovieRatings(int id, String login) {
        try{
            PreparedStatement preparedStatement = connection.prepareStatement(
                    "DELETE FROM movie_ratings WHERE login = ? AND movie_id = ?;");
            preparedStatement.setString(1, login);
            preparedStatement.setInt(2, id);
            preparedStatement.execute();
        } catch (SQLException e){
            e.printStackTrace();
        }
    }


// UPDATE ---------------------------------------------------------------------------------------------------------------------------------------

    public void updateFromMovieRatings(MovieMarkType movieMark) {
        try{
            PreparedStatement preparedStatement = connection.prepareStatement(
                    "UPDATE movie_ratings SET mark = ? , heart = ? WHERE login = ? AND movie_id = ?;");
            preparedStatement.setInt(1, movieMark.getMark());
            preparedStatement.setString(2,  movieMark.getHeart());
            preparedStatement.setString(3, movieMark.getLogin());
            preparedStatement.setInt(4, movieMark.getMovie_id());
            preparedStatement.executeUpdate();
        } catch (SQLException e){
            e.printStackTrace();
        }
    }


}
