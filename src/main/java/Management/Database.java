package Management;

import java.sql.*;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.Properties;

public class Database {

    private String SERVER_ADDRESS;
    private String PORT;
    private String DATABASE_NAME;
    private String USER_NAME;
    private String PASSWORD;

    public Connection connection;

    public void loadParams()
    {
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

    public Database()
    {
        loadParams();

        try {
            Class.forName("org.postgresql.Driver");
            connection = DriverManager
                    .getConnection("jdbc:postgresql://" + SERVER_ADDRESS + ':' + PORT + '/' + DATABASE_NAME, USER_NAME, PASSWORD);
        } catch(ClassNotFoundException|SQLException e) {
            System.out.println("Connecting FAILED");
        }
    }

}
