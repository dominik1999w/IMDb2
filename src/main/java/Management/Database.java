package Management;

import java.sql.*;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.sql.Date;
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
        InputStream inputStream;

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

// INSERT -----------------------------------------------------------------------------------------------------------------------------------------

    public void insert(String table, ArrayList<Object> arguments) throws SQLException { //separated by commas

        RegexManager.convertArrayIntoPreparedConsistent(arguments);

        StringBuilder stringBuilder = new StringBuilder("INSERT INTO " + table + " VALUES(");
        switch (table) {
            case "movie":
                stringBuilder.append("DEFAULT,?,?,'").append(arguments.get(2)).append("minutes'::interval,?,?,?,?");
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
            case "review":
                stringBuilder.append("?,?,?");
                break;
            case "production":
                stringBuilder.append("?,?");
                break;
            case "alternative_title":
                stringBuilder.append("?,?");
                break;
            case "movie_language":
                stringBuilder.append("?,?");
                break;
            case "production_company":
                stringBuilder.append("?,?");
                break;
            case "movie_genre":
                stringBuilder.append("?,").append(arguments.get(1));
                break;
            case "movie_awards":
                stringBuilder.append("?,").append(arguments.get(1)).append(",").append(arguments.get(2)).append(",?");
                break;
            case "crew":
                stringBuilder.append("?,?,").append(arguments.get(2)).append(",?");
                break;
            case "similar_movies":
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
                preparedStatement.setDate(2, Date.valueOf( ((String) arguments.get(1)).replaceAll("'","") ));
                if(arguments.get(3) == null) preparedStatement.setNull(3, Types.INTEGER); else preparedStatement.setInt(3, (Integer) arguments.get(3));
                if(arguments.get(4) == null) preparedStatement.setNull(4, Types.INTEGER); else preparedStatement.setInt(4, (Integer) arguments.get(4));
                if(arguments.get(5) == null) preparedStatement.setNull(5, Types.INTEGER); else preparedStatement.setInt(5, (Integer) arguments.get(5));
                preparedStatement.setString(6, (String) arguments.get(6));
                break;
            case "users":
                preparedStatement.setString(1, (String) arguments.get(0));
                preparedStatement.setInt(2, (Integer) arguments.get(1));
                break;
            case "movie_ratings":
                preparedStatement.setInt(1, (Integer) arguments.get(0));
                preparedStatement.setString(2, (String) arguments.get(1));
                preparedStatement.setInt(3, (Integer) arguments.get(2));
                preparedStatement.setString(4, (String) arguments.get(3));
                break;
            case "watchlist":
                preparedStatement.setString(1, (String) arguments.get(0));
                preparedStatement.setInt(2, (Integer) arguments.get(1));
                break;
            case "review":
                preparedStatement.setString(1, (String) arguments.get(0));
                preparedStatement.setInt(2, (Integer) arguments.get(1));
                preparedStatement.setString(3, (String) arguments.get(2));
                break;
            case "production":
                preparedStatement.setInt(1, (Integer) arguments.get(0));
                preparedStatement.setString(2, (String) arguments.get(1));
                break;
            case "movie_language":
                preparedStatement.setInt(1, (Integer) arguments.get(0));
                preparedStatement.setString(2, (String) arguments.get(1));
                break;
            case "production_company":
                preparedStatement.setInt(1, (Integer) arguments.get(0));
                preparedStatement.setString(2, (String) arguments.get(1));
                break;
            case "alternative_title":
                preparedStatement.setInt(1, (Integer) arguments.get(0));
                preparedStatement.setString(2, (String) arguments.get(1));
                break;
            case "movie_genre":
                preparedStatement.setInt(1, (Integer) arguments.get(0));
                break;
            case "movie_awards":
                preparedStatement.setInt(1, (Integer) arguments.get(0));
                preparedStatement.setInt(2, (Integer) arguments.get(3));
                break;
            case "crew":
                preparedStatement.setInt(1, (Integer) arguments.get(0));
                preparedStatement.setInt(2, (Integer) arguments.get(1));
                preparedStatement.setString(3, (String) arguments.get(3));
                break;
            case "similar_movies":
                preparedStatement.setInt(1, (Integer) arguments.get(0));
                preparedStatement.setInt(2, (Integer) arguments.get(1));
                break;
            default:
                System.out.println("ERROR - no such table");
                throw new SQLException();
        }

        System.out.println(preparedStatement.toString());
        preparedStatement.executeUpdate();
    }

// GET DATA ---------------------------------------------------------------------------------------------------------------------------------------

    public HashMap<String, Integer> getUsers() {

        HashMap<String, Integer> users = new HashMap<>();
        try {
            Statement statement = connection.createStatement();
            ResultSet resultSet = statement.executeQuery("SELECT * FROM users;");
            while (resultSet.next()) {
                users.put(myGetString(resultSet, "login"), resultSet.getInt(2) );
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
                names.add(convertRawToMovieType(resultSet));
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
                names.add(convertRawToMovieType(resultSet));
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
                names.add(convertRawToPeopleType(resultSet));
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
                MovieRankingType a = new MovieRankingType(resultSet.getInt("ranking"), resultSet.getInt("movie_id"), myGetString(resultSet, "title" ),
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
                PersonRankingType a = new PersonRankingType(resultSet.getInt("ranking"), resultSet.getInt("person_id"), myGetString(resultSet, "name" ),
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
                names.add(myGetString(resultSet, "unnest") );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return names;
    }

    public Vector<String> getRoles() {
        Vector<String> names = new Vector<>();
        try {
            Statement statement = connection.createStatement();
            ResultSet resultSet = statement.executeQuery("select unnest(enum_range(NULL::role_type));");
            while (resultSet.next()) {
                names.add(myGetString(resultSet, "unnest") );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return names;
    }

    public HashMap<String, String> getAwardsCategories(String mORp) {
        HashMap<String, String> categories = new HashMap<>();
        try {
            Statement statement = connection.createStatement();
            ResultSet resultSet = statement.executeQuery("SELECT category, since, \"to\" FROM categories WHERE movie_or_person = '" + mORp + "';");
            while (resultSet.next()) {
                String tmp = myGetString(resultSet, "category");
                String tmp2 = myGetString(resultSet, "to");
                tmp2 = tmp2 == null ? "now" : tmp2;
                categories.put(tmp + " (" + myGetString(resultSet, "since") + " - " + tmp2 + ")", tmp);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return categories;
    }

    public Vector<MovieType> getWatchList(String login) {
        Vector<MovieType> names = new Vector<>();
        try {
            PreparedStatement preparedStatement = connection.prepareStatement(
                    "select * from movie where movie_id in (select movie_id from watchlist where login = ? );");
            preparedStatement.setString(1, login);
            ResultSet resultSet = preparedStatement.executeQuery();
            while (resultSet.next()) {
                names.add(convertRawToMovieType(resultSet));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return names;
    }

    public Vector<MovieType> getFavourites(String login) {
        Vector<MovieType> names = new Vector<>();
        try {
            PreparedStatement preparedStatement = connection.prepareStatement(
                    "select * from movie where movie_id in (select movie_id from movie_ratings where login = ? AND heart = 'H');");
            preparedStatement.setString(1, login);
            ResultSet resultSet = preparedStatement.executeQuery();
            while (resultSet.next()) {
                names.add(convertRawToMovieType(resultSet));
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
                result.add(myGetString(resultSet, column) );
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
                    String character = myGetString(resultSet, "character" );
                    if (character != null)
                        result.add(myGetString(resultSet, "first_name") + " " + resultSet.getString("last_name") + " (" + resultSet.getString("character") + ")" );
                    else
                        result.add(myGetString(resultSet, "first_name") + " " + resultSet.getString("last_name") );
                } else if (role.equals("Others"))
                    result.add(myGetString(resultSet, "role") + ": " + resultSet.getString("first_name") + " " + resultSet.getString("last_name") );
                else
                    result.add(myGetString(resultSet, "first_name") + " " + resultSet.getString("last_name") );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    public Vector<String> getReviews(int id) {
        Vector<String> result = new Vector<>();
        try {
            PreparedStatement preparedStatement = connection.prepareStatement(
                    "SELECT review, login FROM review WHERE movie_id = " + id + ";"
            );

            ResultSet resultSet = preparedStatement.executeQuery();
            while (resultSet.next()) {
                result.add(myGetString(resultSet, "review") + " ~ " + resultSet.getString("login"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    public String getYourReview(int id, String login) {
        String result = null;
        try {
            PreparedStatement preparedStatement = connection.prepareStatement(
                    "SELECT review, login FROM review WHERE movie_id = " + id + " AND login = ?;"
            );
            preparedStatement.setString(1, login);

            ResultSet resultSet = preparedStatement.executeQuery();
            if (resultSet.next()) {
                result = myGetString(resultSet, "review" );
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
                movieRankingType = new MovieRankingType(resultSet.getInt("ranking"), resultSet.getInt("movie_id"), myGetString(resultSet, "title" ),
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
            if (resultSet.next()) {
                String heart = myGetString(resultSet, "heart" );
                if (heart != null)
                    movieMark = new MovieMarkType(resultSet.getInt("movie_id"), myGetString(resultSet, "login"), resultSet.getInt("mark" ),
                            heart, myGetString(resultSet, "seen"));
                else
                    movieMark = new MovieMarkType(resultSet.getInt("movie_id"), myGetString(resultSet, "login"), resultSet.getInt("mark" ),
                            "N", myGetString(resultSet, "seen"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return movieMark;
    }

    public Vector<MovieType> getSimilar(int id) {
        Vector<MovieType> movies = new Vector<>();
        try {
            PreparedStatement preparedStatement = connection.prepareStatement(
                    "SELECT movie.* FROM show_similar(?) JOIN movie ON m_id = movie_id");
            preparedStatement.setInt(1, id);
            ResultSet resultSet = preparedStatement.executeQuery();
            while (resultSet.next()) {
                movies.add(convertRawToMovieType(resultSet));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return movies;
    }

    public MovieType getMovieByID(int id) {
        MovieType movie = null;
        try {
            PreparedStatement preparedStatement = connection.prepareStatement(
                    "SELECT * FROM movie WHERE movie_id = " + id + ";");
            ResultSet resultSet = preparedStatement.executeQuery();
            resultSet.next();
            movie = convertRawToMovieType(resultSet);
        } catch (SQLException | NullPointerException e) {
            e.printStackTrace();
        }
        return movie;
    }

    public Integer getIdOfMovie() {
        Integer id = null;
        try {
            PreparedStatement preparedStatement = connection.prepareStatement(
                    "SELECT * FROM NEXTVAL(pg_get_serial_sequence('movie','movie_id'));");
            ResultSet resultSet = preparedStatement.executeQuery();
            resultSet.next();
            id = resultSet.getInt("nextval");
        } catch (SQLException | NullPointerException e) {
            e.printStackTrace();
        }
        return id + 1;
    }

    public Vector<String> getAwards(int id, String nORw) {
        Vector<String> awards = new Vector<>();
        try {
            PreparedStatement preparedStatement = connection.prepareStatement(
                    "SELECT category, year FROM movie_awards WHERE movie_id = ? AND nomination_or_win = ?;");
            preparedStatement.setInt(1, id);
            preparedStatement.setString(2, nORw);
            ResultSet resultSet = preparedStatement.executeQuery();
            while (resultSet.next()) {
                awards.add(myGetString(resultSet, "category") + " (" + resultSet.getInt("year") + ")" );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return awards;
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
        try {
            PreparedStatement preparedStatement = connection.prepareStatement(
                    "DELETE FROM movie_ratings WHERE login = ? AND movie_id = ?;");
            preparedStatement.setString(1, login);
            preparedStatement.setInt(2, id);
            preparedStatement.execute();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


// UPDATE ---------------------------------------------------------------------------------------------------------------------------------------

    public void updateFromMovieRatings(MovieMarkType movieMark) {
        try {
            PreparedStatement preparedStatement = connection.prepareStatement(
                    "UPDATE movie_ratings SET mark = ? , heart = ? WHERE login = ? AND movie_id = ?;");
            preparedStatement.setInt(1, movieMark.getMark());
            preparedStatement.setString(2, movieMark.getHeart());
            preparedStatement.setString(3, movieMark.getLogin());
            preparedStatement.setInt(4, movieMark.getMovie_id());
            preparedStatement.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void updateReview(int id, String login, String review) {
        if (getYourReview(id, login) == null && review != null) {
            ArrayList<Object> arguments = new ArrayList<>();
            arguments.add(login);
            arguments.add(id);
            arguments.add(review);
            try {
                insert("review", arguments);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        } else {
            try {
                if (review == null)
                    review = "";
                PreparedStatement preparedStatement = connection.prepareStatement(
                        "UPDATE review SET review = ? WHERE movie_id = ? AND login = ?;");
                preparedStatement.setString(1, review);
                preparedStatement.setInt(2, id);
                preparedStatement.setString(3, login);
                preparedStatement.executeUpdate();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }


// OTHERS ----------------------------------------------------------------------------------------------------------------------------------------

    private MovieType convertRawToMovieType(ResultSet resultSet) {
        try {
            return new MovieType(resultSet.getInt("movie_id"), myGetString(resultSet, "title"), myGetString(resultSet, "release_date"),
                    myGetString(resultSet, "runtime"), resultSet.getInt("budget" ), resultSet.getInt("boxoffice"), resultSet.getInt("opening_weekend_usa"), myGetString(resultSet, "description") );
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private PeopleType convertRawToPeopleType(ResultSet resultSet) {
        try {
            return new PeopleType(resultSet.getInt("person_id"), myGetString(resultSet, "first_name"), resultSet.getString("last_name"),
                    myGetString(resultSet, "born"), resultSet.getString("died"), resultSet.getString("birth_country") );
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private String myGetString(ResultSet resultSet, String column) throws SQLException {
        String result = resultSet.getString(column);
        if(result == null)
            return null;
        return result.replaceAll("'","");
    }

}

















