IMDb2 (using PostgreSQL) 

Download diagram.pdf to display created database.
Download imdb2.zip to open up appliaction. 

INSTALL:

0. Preffered java version: java 11 (11.0.2) -> https://gluonhq.com/products/javafx/ 

1. open attached file start.sh (guarantee access if needed: chmod u+x start.sh). Substitute [JAVAFX_PATH] with a path to javafx/lib. By default: 
/usr/lib/jvm/java-11-openjdk-am64/javafx-sdk-11.0.2/lib/

2. Edit config.properties (add own database_name, user_name, password)

3. Load up imdb2 database from create.sql

4. run start.sh script.

--------------------------------------------------------------------
To access every operation, log in into admin (login: admin password: admin). Otherwise, create a new user and enjoy a streamlined IMDb. 
--------------------------------------------------------------------




--------------------imdb2 functionality----------------------------

User is allowed to:
1. register new users

2. search for movies/ people connected with movies

3. search with specific filters (on the left-hand side select preferred criteria then accept your constraints by clicking on the switch)

4. check the current ranking of movies and people (movie or person is required to have at least 5 votes to be considered in the ranking)

5. add vote or comment to selected movie/ person

6. add movie/ person to favorites

7. Access favorites movies/ watchlist etc.

Additionally, admin is allowed to:

1. add, edit and/or delete movies/ people to the database

--------------------------------------------------------------------


