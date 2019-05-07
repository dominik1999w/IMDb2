--DROP SCHEMA
DROP SCHEMA IF EXISTS imdb2 CASCADE;

--DROP TYPES
DROP TYPE IF EXISTS role_type CASCADE;
DROP TYPE IF EXISTS genre_type CASCADE;

--DROP TABLES IF EXIST
DROP TABLE IF EXISTS movie CASCADE;
DROP TABLE IF EXISTS movie_awards CASCADE;
DROP TABLE IF EXISTS movie_genre CASCADE;
DROP TABLE IF EXISTS people CASCADE;
DROP TABLE IF EXISTS people_awards CASCADE;
DROP TABLE IF EXISTS production CASCADE;
DROP TABLE IF EXISTS movie_language CASCADE;
DROP TABLE IF EXISTS production_company CASCADE;
DROP TABLE IF EXISTS similar_movies CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS watchlist CASCADE;
DROP TABLE IF EXISTS alternative_title CASCADE;
DROP TABLE IF EXISTS crew CASCADE;
DROP TABLE IF EXISTS movie_ratings CASCADE;
DROP TABLE IF EXISTS person_ratings CASCADE;
DROP TABLE IF EXISTS profession CASCADE;
DROP TABLE IF EXISTS review CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
----------------------------------------------
--DROP TRIGGERS IF EXIST

DROP TRIGGER IF EXISTS is_alive ON people;
DROP TRIGGER IF EXISTS movie_awards_trig ON people;
DROP TRIGGER IF EXISTS people_awards_trig ON people;
DROP TRIGGER IF EXISTS before_born ON crew;
DROP TRIGGER IF EXISTS symmetric_rows ON similar_movies;
----------------------------------------------

--DROP INDECIES IF EXIST
DROP INDEX IF EXISTS idx_awards_movie_id;
DROP INDEX IF EXISTS idx_movie_awards_category;
DROP INDEX IF EXISTS idx_production_1_movie_id;
DROP INDEX IF EXISTS idx_movie_genre_genre_id;
DROP INDEX IF EXISTS idx_movie_language_movie_id;
DROP INDEX IF EXISTS idx_people_birth_country;
DROP INDEX IF EXISTS idx_people_awards_person_id;
DROP INDEX IF EXISTS idx_people_awards_movie_id;
DROP INDEX IF EXISTS idx_people_awards_category;
DROP INDEX IF EXISTS idx_production_movie_id;
DROP INDEX IF EXISTS idx_production_country_id;
DROP INDEX IF EXISTS idx_production_company_movie_id;
DROP INDEX IF EXISTS idx_production_company_company_id;
DROP INDEX IF EXISTS idx_similar_movie_movie_id1;
DROP INDEX IF EXISTS idx_similar_movie_movie_id2;
DROP INDEX IF EXISTS idx_watchlist_movie_id;
DROP INDEX IF EXISTS idx_watchlist_user_id;
DROP INDEX IF EXISTS idx_alternative_title_movie_id;
DROP INDEX IF EXISTS idx_awards_categories_award_id;
DROP INDEX IF EXISTS idx_awards_categories_category_id;
DROP INDEX IF EXISTS idx_citizenship_person_id;
DROP INDEX IF EXISTS idx_citizenship_country_id;
DROP INDEX IF EXISTS idx_crew_person_id;
DROP INDEX IF EXISTS idx_crew_movie_id;
DROP INDEX IF EXISTS idx_movie_ratings_user_id;
DROP INDEX IF EXISTS idx_movie_ratings_movie_id;
DROP INDEX IF EXISTS idx_person_ratings_user_id;
DROP INDEX IF EXISTS idx_person_ratings_person_id;
DROP INDEX IF EXISTS idx_profession_person_id;
DROP INDEX IF EXISTS idx_review_user_id;
DROP INDEX IF EXISTS idx_review_movie_id;
----------------------------------------------


CREATE SCHEMA imdb2;


CREATE OR REPLACE FUNCTION to_year(d date) RETURNS double precision AS $$
BEGIN
	RETURN EXTRACT(year FROM d);
END;
$$ LANGUAGE plpgsql;


--MOVIE TABLES

CREATE TABLE movie ( 
	movie_id             SERIAL PRIMARY KEY,
	title                varchar  NOT NULL ,
	release_date         date   NOT NULL ,
	runtime              interval  NOT NULL ,
	budget               integer   ,
	boxoffice     		 integer   ,
	opening_weekend_usa  integer   ,
	description          text      ,

	CHECK (release_date > '1888-01-01' AND release_date <= current_date) ,
	CHECK (boxoffice >= opening_weekend_usa)
 );

CREATE TYPE genre_type AS ENUM('Action','Adventure','Animation','Biography','Comedy',
	'Crime','Documentary','Drama','Family','Fantasy','Film Noir','History','Horror',
	'Music','Musical','Mystery','Romance','Sci-fi','Short','Sport','Superhero','Thriller',
	'War','Western','Other'); /*enum for genres*/

CREATE TABLE movie_genre ( 
	movie_id             integer  NOT NULL /*REFERENCES movie*/,
	genre                genre_type  NOT NULL ,

	CONSTRAINT unique_genre_type UNIQUE(movie_id,genre)
 );

CREATE TABLE movie_language ( 
	movie_id             integer  NOT NULL /*REFERENCES movie*/,
	"language"           varchar(512)  NOT NULL ,

	CONSTRAINT unique_movie_language UNIQUE(movie_id,"language")
);
CREATE TABLE similar_movies ( 
	movie_id1            integer  NOT NULL /*REFERENCES movie*/,
	movie_id2            integer  NOT NULL /*REFERENCES movie*/ ,

	CONSTRAINT unique_similar_movies UNIQUE(movie_id1,movie_id2)
 );

CREATE TABLE alternative_title ( 
	movie_id             integer  NOT NULL /*REFERENCES movie*/,
	movie_title          varchar(512)  NOT NULL ,

	CONSTRAINT unique_alternative_title UNIQUE(movie_id,movie_title)
);

CREATE TABLE movie_ratings ( 
	movie_id             integer  /*REFERENCES movie*/,
	login                varchar(17)  /*REFERENCES users*/,
	mark                 numeric(2)  NOT NULL ,
	heart                char(1)  , 

	PRIMARY KEY(movie_id,login),
	CHECK(heart = 'H' OR heart IS NULL) ,
	CHECK(mark > 0 AND mark <= 10) 
 );

CREATE TABLE review ( 
	login                varchar(17)  NOT NULL /*REFERENCES users*/,
	movie_id             integer  NOT NULL /*REFERENCES movie*/,
	review               text  NOT NULL ,

	PRIMARY KEY(movie_id,login) 
 );

----------------------------------------------
--TECHNICAL TABLES
CREATE TABLE production ( 
	movie_id             integer  NOT NULL /*REFERENCES movie*/,
	country              varchar(512)  NOT NULL  ,

	CONSTRAINT unique_production UNIQUE(movie_id,country)
 );

CREATE TABLE production_company ( 
	movie_id             integer  NOT NULL /*REFERENCES movie*/,
	company              varchar(512)  NOT NULL  ,

	CONSTRAINT unique_production_company UNIQUE(movie_id,company)
 );

----------------------------------------------
--AWARDS TABLES

CREATE TABLE categories ( 
	category             varchar(512)  PRIMARY KEY ,
	since                date  NOT NULL ,
	"to"                 date DEFAULT current_date  ,
	movie_or_person      char(1)   ,

	CHECK (movie_or_person = 'M' OR movie_or_person = 'P')
 );

CREATE TABLE movie_awards ( 
	movie_id             integer  NOT NULL /*REFERENCES movie*/,
	category             varchar(512)  NOT NULL /*REFERENCES categories*/,
	nomination_or_win    char(1)  NOT NULL ,
	"year"               double precision  NOT NULL ,

	CHECK (nomination_or_win = 'N' OR nomination_or_win = 'W') ,
	CHECK ("year" >= 1927 AND "year" <= to_year(current_date)) ,

	CONSTRAINT unique_movie_awards UNIQUE(movie_id, category, nomination_or_win, "year")
 );

CREATE TABLE people_awards ( 
	person_id            integer NOT NULL /*REFERENCES people*/,
	movie_id             integer   /*REFERENCES movie*/,
	category             varchar(512)   NOT NULL/*REFERENCES categories*/,
	nomination_or_win    char(1)  NOT NULL ,
	"year"               double precision  NOT NULL , 

	CHECK (nomination_or_win = 'N' OR nomination_or_win = 'W') /* N-nomination, W-win*/,
	CHECK ("year" >= 1927 AND "year" <= to_year(current_date)) ,

	CONSTRAINT unique_people_awards UNIQUE(person_id, movie_id, category, nomination_or_win, "year")
 );

--PEOPLE TABLES
CREATE TABLE people ( 
	person_id            SERIAL PRIMARY KEY,
	first_name           varchar(512)  NOT NULL ,
	last_name            varchar(512)   ,
	age                  numeric(3)   ,
	born                 date   ,
	died                 date   ,
	alive                char(1)   ,
	birth_country        varchar(512)   , 

	CHECK (alive = 'Y' OR alive = 'N' OR alive ='U') , /*Y-Yes, N-No, U-unknown */
	CHECK (age >= 0) ,
	CHECK (died < NOW()) ,
	CHECK (born < NOW()) ,
	CHECK (born < died)
 );
CREATE TABLE users ( 
	login                varchar(17)  PRIMARY KEY ,
	"password"           varchar(512)  NOT NULL ,
	CONSTRAINT safety UNIQUE(login)
 );

CREATE TABLE watchlist ( 
	login                varchar(17)  NOT NULL /*REFERENCES users*/,
	movie_id             integer  NOT NULL /*REFERENCES movie*/,

	CONSTRAINT unique_watchlist UNIQUE(login,movie_id)
);

CREATE TABLE person_ratings ( 
	person_id            integer  /*REFERENCES people*/,
	login                varchar(17)  /*REFERENCES users*/,
	mark                 numeric(2)  NOT NULL ,
	heart                char(1)  , 

	PRIMARY KEY(person_id,login),
	CHECK(heart = 'H' OR heart IS NULL) ,
	CHECK(mark > 0 AND mark <= 10) 
);

CREATE TABLE profession ( 
	person_id            integer  NOT NULL /*REFERENCES people*/,
	profession           varchar(512)  NOT NULL,

	CONSTRAINT unique_profession UNIQUE(person_id,profession)
);

CREATE TYPE role_type AS ENUM ('Director','Editor','Music','Cameraworker','Writer','Actor','Others'); /*ENUM FOR CREW*/

CREATE TABLE crew ( 
	person_id            integer  NOT NULL /*REFERENCES people*/,
	movie_id             integer  NOT NULL /*REFERENCES movie*/,
	"role"               role_type  NOT NULL ,
	"character/s"          varchar(512)    ,

	CONSTRAINT unique_crew UNIQUE(person_id,movie_id,"role","character/s")
 );

----------------------------------------------

--FUNCTIONS

--delete duplicates
create or replace function remove_duplicates(a text) returns void as
$$
begin
      EXECUTE concat('DELETE FROM ',a,' WHERE ctid NOT IN (SELECT min(ctid) FROM ',a, ' GROUP BY ',a,'.*)');
end;
$$
language plpgsql;
----------------------------------------------

--delete symmetric rows
CREATE OR REPLACE FUNCTION delete_symmetric_rows() RETURNS trigger AS $$
BEGIN
    IF (SELECT EXISTS( SELECT 1 FROM similar_movies WHERE NEW.movie_id1=movie_id2 AND NEW.movie_id2=movie_id1))
        THEN RAISE EXCEPTION 'Symmetric record already exists!';
    END IF;
    RETURN NEW; 
    
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER symmetric_rows BEFORE INSERT OR UPDATE ON similar_movies
FOR EACH ROW EXECUTE PROCEDURE delete_symmetric_rows();
----------------------------------------------


--movie_year
CREATE OR REPLACE FUNCTION movie_year(id int) RETURNS double precision AS $$
BEGIN
	RETURN EXTRACT(year FROM (SELECT release_date FROM movie WHERE movie_id = id));
END;
$$ LANGUAGE plpgsql;

----------------------------------------------

--peoples' age
CREATE OR REPLACE FUNCTION is_alive_trig() RETURNS trigger AS $$
BEGIN
    IF NEW.died IS NOT NULL THEN
        NEW.age = NULL;
        NEW.alive = 'N';
    ELSE
	    IF NEW.born IS NOT NULL THEN
	    	NEW.age = EXTRACT(year FROM age(current_date,NEW.born));
	    	NEW.alive = 'Y';
	    END IF;
	END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER is_alive BEFORE INSERT OR UPDATE ON people
FOR EACH ROW EXECUTE PROCEDURE is_alive_trig();

----------------------------------------------

--awards movies
CREATE OR REPLACE FUNCTION movie_awards_trig() RETURNS trigger AS $$
BEGIN
	IF (SELECT SUM(1) FROM categories WHERE category = NEW.category AND movie_or_person = 'M')
		= 0 THEN
		RAISE EXCEPTION 'Wrong category';
	END IF;

	IF movie_year(NEW.movie_id) > NEW.year OR movie_year(NEW.movie_id) + 2 < NEW.year THEN
		RAISE EXCEPTION 'Wrong year';
	END IF;

	IF NEW.year < (SELECT to_year(since) FROM categories WHERE category = NEW.category)
		OR 
	   NEW.year > COALESCE((SELECT to_year("to") FROM categories WHERE category = NEW.category),
	   	to_year(current_date)) THEN
		RAISE EXCEPTION 'Wrong year';
	END IF;

	--categories constraints

	IF 
		NEW.category = 'Animated Feature Film' OR
		NEW.category = 'Animated Short Film'
		THEN
		IF (SELECT movie_id FROM movie JOIN movie_genre USING(movie_id) 
			WHERE movie_id = NEW.movie_id AND genre = 'Animation') IS NULL
			THEN
				RAISE EXCEPTION 'Wrong genere!';
		END IF;
	END IF;
	IF
		NEW.category = 'Animated Short Film' OR
		NEW.category = 'Documentary Short Subject' OR
		NEW.category = 'Live Action Short Film' OR
		NEW.category = 'Short Subject – Color' OR
		NEW.category = 'Short Subject – Comedy'
		THEN
			IF (SELECT runtime FROM movie WHERE movie_id = NEW.movie_id) > INTERVAL '40 minutes'
			THEN
				RAISE EXCEPTION 'Not short film';
			END IF;
	END IF;
	IF
		NEW.category = 'Documentary Feature' OR
		NEW.category = 'Documentary Short Subject'
		THEN
		IF (SELECT movie_id FROM movie JOIN movie_genre USING(movie_id) 
			WHERE movie_id = NEW.movie_id AND genre = 'Documentary') IS NULL
			THEN
				RAISE EXCEPTION 'Wrong genere!';
		END IF;
	END IF;
	IF
		NEW.category = 'Original Musical or Comedy Score' OR
		NEW.category = 'Short Subject – Comedy'
		THEN
		IF (SELECT movie_id FROM movie JOIN movie_genre USING(movie_id) 
			WHERE movie_id = NEW.movie_id AND genre = 'Comedy') IS NULL
			THEN 
				RAISE EXCEPTION 'Wrong genere!';
		END IF;
	END IF;
	IF
		NEW.category = 'Original Musical or Comedy Score' OR
		NEW.category = 'Original Musical'
		THEN
		IF (SELECT movie_id FROM movie JOIN movie_genre USING(movie_id) 
			WHERE movie_id = NEW.movie_id AND genre = 'Music') IS NULL
			THEN
				RAISE EXCEPTION 'Wrong genere!';
		END IF;
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER movie_awards_trig BEFORE INSERT OR UPDATE ON movie_awards
FOR EACH ROW EXECUTE PROCEDURE movie_awards_trig();

----------------------------------------------

--awards people
CREATE OR REPLACE FUNCTION people_awards_trig() RETURNS trigger AS $$
BEGIN

	IF NEW.movie_id IS NOT NULL THEN
		IF movie_year(NEW.movie_id) > NEW.year OR movie_year(NEW.movie_id) + 2 < NEW.year THEN
			RAISE EXCEPTION 'Wrong year';
		END IF;
	END IF;

	IF (SELECT SUM(1) FROM categories WHERE category = NEW.category AND movie_or_person = 'P')
		= 0 THEN
		RAISE EXCEPTION 'Wrong category';
	END IF;

	IF to_year((SELECT born FROM people WHERE person_id = NEW.person_id)) > NEW.year THEN
		RAISE EXCEPTION 'Wrong year';
	END IF;

	IF NEW.year < (SELECT to_year(since) FROM categories WHERE category = NEW.category)
		OR 
	   NEW.year > COALESCE((SELECT to_year("to") FROM categories WHERE category = NEW.category),
	   	to_year(current_date)) THEN
		RAISE EXCEPTION 'Wrong year';
	END IF;

	--categories constraints

	IF  NEW.category = 'Director' OR 
		NEW.category = 'Assistant Director' OR 
		NEW.category = 'Director - Comedy' OR 
		NEW.category = 'Director - Dramatic'
		THEN
			IF (SELECT person_id FROM crew c JOIN movie m USING(movie_id) 
				WHERE c.movie_id = NEW.movie_id AND c.person_id = NEW.person_id AND role = 'Director') IS NULL
				THEN
					RAISE EXCEPTION 'This person did not directed this film!';
			END IF;
	END IF;
	IF
		NEW.category = 'Actor' OR
		NEW.category = 'Actress' OR
		NEW.category = 'Supporting Actor' OR
		NEW.category = 'Supporting Actress' 
		THEN
			IF (SELECT person_id FROM crew c JOIN movie m USING(movie_id) 
				WHERE c.movie_id = NEW.movie_id AND c.person_id = NEW.person_id AND role = 'Actor') IS NULL
				THEN
					RAISE EXCEPTION 'This person did not stare at this film!';
			END IF;
	END IF;
	IF
		NEW.category = 'Director - Comedy'
		THEN
		IF (SELECT movie_id FROM movie JOIN movie_genre USING(movie_id) 
			WHERE movie_id = NEW.movie_id AND genre = 'Comedy') IS NULL
			THEN
				RAISE EXCEPTION 'Wrong genere!';
		END IF;
	END IF;
	IF
		NEW.category = 'Director - Dramatic'
		THEN
		IF (SELECT movie_id FROM movie JOIN movie_genre USING(movie_id) 
			WHERE movie_id = NEW.movie_id AND genre = 'Dramatic') IS NULL
			THEN
				RAISE EXCEPTION 'Wrong genere!';
		END IF;
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER people_awards_trig BEFORE INSERT OR UPDATE ON people_awards
FOR EACH ROW EXECUTE PROCEDURE people_awards_trig();

--person can't work on the movie before he/she was born

CREATE OR REPLACE FUNCTION before_born() RETURNS trigger AS $$
BEGIN
	IF (SELECT release_date FROM movie WHERE movie_id = NEW.movie_id) < 
		COALESCE((SELECT born FROM people WHERE person_id = NEW.person_id),'1888-01-01')
		THEN
			RAISE EXCEPTION 'Person can not work on the movie before he/she was born!';
			RETURN NULL;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_born BEFORE INSERT OR UPDATE ON crew
FOR EACH ROW EXECUTE PROCEDURE before_born();
----------------------------------------------

--how many awards for a movie
CREATE OR REPLACE FUNCTION awards_amount(movieIn varchar,c char) RETURNS integer AS $$
BEGIN
    IF(c='W' OR c='N') THEN
        RETURN (SELECT count(*) FROM movie_awards ma WHERE movie_id IN (SELECT movie_id FROM movie WHERE title=movieIn) AND nomination_or_win=c);
    END IF;
    IF(c='B') THEN /* B for both */
        RETURN (SELECT count(*) FROM movie_awards ma WHERE movie_id IN (SELECT movie_id FROM movie WHERE title=movieIn));
    END IF;
    RAISE EXCEPTION 'Invalid input';
END;
$$ LANGUAGE plpgsql;

--VIEWS

--movie ranking
CREATE OR REPLACE VIEW show_movie_ranking AS 
SELECT
    RANK() OVER(ORDER BY SUM(mark)/COUNT(mark) DESC) AS "ranking", 
    movie_id,
    (SELECT title FROM movie WHERE movie_id=mr.movie_id),
    ROUND(SUM(mark)/COUNT(mark),1) AS avg_mark, COUNT(*) AS votes 
FROM movie_ratings mr GROUP BY movie_id HAVING(COUNT(mark)>=5) ORDER BY avg_mark desc;
/*required to have at least 5 votes to be considered in the movie ranking*/
----------------------------------------------

--heart-movie-ranking
CREATE OR REPLACE VIEW show_heart_movie_ranking AS 
SELECT
    RANK() OVER( ORDER BY count(heart) DESC) AS "ranking", 
    movie_id,
    (SELECT title FROM movie WHERE movie_id=mr.movie_id),
    count(heart) AS hearts
FROM movie_ratings mr WHERE heart='H' GROUP BY movie_id HAVING(COUNT(heart)>=5) ORDER BY hearts desc;
/*required to have at least 5 votes to be considered in the heart-movie ranking*/
----------------------------------------------

--person-ranking
CREATE OR REPLACE VIEW show_person_ranking AS 
SELECT
    RANK() OVER(ORDER BY SUM(mark)/COUNT(mark) DESC) AS "ranking", 
    person_id,
    (SELECT first_name||' '||last_name FROM people WHERE person_id=pr.person_id) as name,
    ROUND(SUM(mark)/COUNT(mark),1) AS avg_mark, COUNT(*) AS votes 
FROM person_ratings pr GROUP BY person_id HAVING(COUNT(mark)>=5) ORDER BY avg_mark desc;
/*required to have at least 5 votes to be considered in the person ranking*/
----------------------------------------------

--heart-person-ranking
CREATE OR REPLACE VIEW show_heart_person_ranking AS 
SELECT
    RANK() OVER(ORDER BY count(heart) DESC) AS "ranking", 
    person_id,
    (SELECT first_name||' '||last_name FROM people WHERE person_id=pr.person_id) as name,
    count(heart) AS hearts
FROM person_ratings pr WHERE heart='H' GROUP BY person_id HAVING(COUNT(heart)>=5) ORDER BY hearts desc;
/*required to have at least 5 votes to be considered in the person ranking*/
----------------------------------------------

--watchlist view
CREATE OR REPLACE VIEW watchlist_info AS
SELECT 
    login, 
    (SELECT title FROM movie WHERE movie_id=w.movie_id) as movie,
    (SELECT mark FROM movie_ratings WHERE login=w.login AND movie_id=w.movie_id),
    (SELECT heart FROM movie_ratings WHERE login=w.login AND movie_id=w.movie_id)
FROM watchlist w ORDER BY login,mark DESC NULLS LAST, heart  NULLS LAST;
----------------------------------------------

--similar_movies view
CREATE OR REPLACE VIEW show_similar_movies AS
SELECT
    (SELECT title FROM movie WHERE movie_id=movie_id1) as "movie1",
    (SELECT title FROM movie WHERE movie_id=movie_id2) as "movie2"
FROM similar_movies;
----------------------------------------------    




----------------------------------------------
--CONSTRAINTS - FOREIGN KEYS
ALTER TABLE movie_genre ADD CONSTRAINT fk_production_1_movie FOREIGN KEY ( movie_id ) REFERENCES movie( movie_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE movie_language ADD CONSTRAINT fk_movie_language_movie FOREIGN KEY ( movie_id ) REFERENCES movie( movie_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE similar_movies ADD CONSTRAINT fk_similar_movies_movie FOREIGN KEY ( movie_id1 ) REFERENCES movie( movie_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE similar_movies ADD CONSTRAINT fk_similar_movies_movie_0 FOREIGN KEY ( movie_id2 ) REFERENCES movie( movie_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE alternative_title ADD CONSTRAINT fk_alternative_title_movie FOREIGN KEY ( movie_id ) REFERENCES movie( movie_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE movie_ratings ADD CONSTRAINT fk_movie_ratings_users FOREIGN KEY ( login ) REFERENCES users( login ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE movie_ratings ADD CONSTRAINT fk_movie_ratings_movie FOREIGN KEY ( movie_id ) REFERENCES movie( movie_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE review ADD CONSTRAINT fk_review_users FOREIGN KEY ( login ) REFERENCES users( login ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE review ADD CONSTRAINT fk_review_movie FOREIGN KEY ( movie_id ) REFERENCES movie( movie_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE production ADD CONSTRAINT fk_production_movie FOREIGN KEY ( movie_id ) REFERENCES movie( movie_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE production_company ADD CONSTRAINT fk_production_company_movie FOREIGN KEY ( movie_id ) REFERENCES movie( movie_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE movie_awards ADD CONSTRAINT fk_movie_awards_categories FOREIGN KEY ( category ) REFERENCES categories( category )  ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE people_awards ADD CONSTRAINT fk_people_awards_categories FOREIGN KEY ( category ) REFERENCES categories( category )  ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE movie_awards ADD CONSTRAINT fk_awards_movie FOREIGN KEY ( movie_id ) REFERENCES movie( movie_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE people_awards ADD CONSTRAINT fk_people_awards_people FOREIGN KEY ( person_id ) REFERENCES people( person_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE people_awards ADD CONSTRAINT fk_people_awards_movie FOREIGN KEY ( movie_id ) REFERENCES movie( movie_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE watchlist ADD CONSTRAINT fk_watchlist_movie FOREIGN KEY ( movie_id ) REFERENCES movie( movie_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE watchlist ADD CONSTRAINT fk_watchlist_users FOREIGN KEY ( login ) REFERENCES users( login ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE person_ratings ADD CONSTRAINT fk_person_ratings_users FOREIGN KEY ( login ) REFERENCES users( login ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE person_ratings ADD CONSTRAINT fk_person_ratings_people FOREIGN KEY ( person_id ) REFERENCES people( person_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE profession ADD CONSTRAINT fk_profession_people FOREIGN KEY ( person_id ) REFERENCES people( person_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE crew ADD CONSTRAINT fk_crew_people FOREIGN KEY ( person_id ) REFERENCES people( person_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE crew ADD CONSTRAINT fk_crew_movie FOREIGN KEY ( movie_id ) REFERENCES movie( movie_id ) ON UPDATE CASCADE ON DELETE CASCADE;
----------------------------------------------





--SAMPLE DATA
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Blacksmith Of The World' , '1891-09-24' , INTERVAL '29 minutes' , 21000000 , 74000000 , 420000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Tree Of Freedom' , '1896-10-18' , INTERVAL '181 minutes' , 32000000 , 73000000 , 220000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Children With Strength' , '1903-11-07' , INTERVAL '75 minutes' , 45000000 , 99000000 , 630000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Pilots Of Reality' , '1908-02-10' , INTERVAL '131 minutes' , 65000000 , 96000000 , 230000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Viva Nollywood' , '1919-09-05' , INTERVAL '23 minutes' , 93000000 , 53000000 , 870000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Foreigners And Friends' , '1928-10-14' , INTERVAL '29 minutes' , 50000000 , 71000000 , 460000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Tower Of Reality' , '1929-12-25' , INTERVAL '26 minutes' , 82000000 , 10000000 , 540000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Strife Of Glory' , '1932-01-14' , INTERVAL '85 minutes' , 92000000 , 36000000 , 300000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Hurt By The City' , '1935-06-19' , INTERVAL '191 minutes' , 1000000 , 20000000 , 530000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Welcome To The City' , '1936-07-20' , INTERVAL '145 minutes' , 31000000 , 12000000 , 60000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Slave Of Reality' , '1941-02-03' , INTERVAL '129 minutes' , 75000000 , 30000000 , 340000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Warrior Of Perfection' , '1943-02-02' , INTERVAL '199 minutes' , 1000000 , 46000000 , 740000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Horses Of Fortune' , '1956-05-24' , INTERVAL '179 minutes' , 18000000 , 11000000 , 90000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Butchers Of Perfection' , '1959-01-08' , INTERVAL '103 minutes' , 90000000 , 21000000 , 740000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Foes And Defenders' , '1965-05-26' , INTERVAL '170 minutes' , 28000000 , 38000000 , 30000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Blacksmiths And Slaves' , '1971-12-20' , INTERVAL '69 minutes' , 31000000 , 17000000 , 160000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Unity Of The Frontline' , '1972-05-31' , INTERVAL '123 minutes' , 29000000 , 82000000 , 710000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Culling Of Gold' , '1983-04-14' , INTERVAL '180 minutes' , 49000000 , 97000000 , 170000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Losing Eternity' , '1983-06-15' , INTERVAL '98 minutes' , 44000000 , 87000000 , 490000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Searching In My End' , '1992-04-28' , INTERVAL '27 minutes' , 96000000 , 7000000 , 360000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Owl Of The End' , '1996-03-20' , INTERVAL '119 minutes' , 76000000 , 75000000 , 330000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Soldier With Gold' , '2001-05-18' , INTERVAL '115 minutes' , 12000000 , 38000000 , 350000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Agents Of Fire' , '2004-10-02' , INTERVAL '24 minutes' , 47000000 , 78000000 , 260000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Boys Of The North' , '2012-10-05' , INTERVAL '38 minutes' , 16000000 , 43000000 , 150000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Boys And Gods' , '2017-09-10' , INTERVAL '20 minutes' , 52000000 , 66000000 , 530000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Owls And Invaders' , '1989-06-23' , INTERVAL '85 minutes' , 64000000 , 48000000 , 410000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Star With Silver' , '1990-01-23' , INTERVAL '94 minutes' , 46000000 , 79000000 , 10000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Family Without Faith' , '1993-04-24' , INTERVAL '114 minutes' , 28000000 , 31000000 , 970000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Travel To The World' , '1993-05-17' , INTERVAL '67 minutes' , 8000000 , 59000000 , 540000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Taste Of My Nightmares' , '1994-01-06' , INTERVAL '174 minutes' , 79000000 , 95000000 , 170000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Nymph Of Dreams' , '1994-07-31' , INTERVAL '71 minutes' , 99000000 , 63000000 , 240000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Defender Without Hope' , '1997-09-28' , INTERVAL '196 minutes' , 49000000 , 97000000 , 680000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Foes Of Joy' , '2000-06-03' , INTERVAL '76 minutes' , 63000000 , 83000000 , 270000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Fish With Money' , '2003-01-14' , INTERVAL '192 minutes' , 22000000 , 16000000 , 560000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Pirates And Foes' , '2003-11-24' , INTERVAL '92 minutes' , 28000000 , 53000000 , 260000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Witches And Hunters' , '2007-05-16' , INTERVAL '53 minutes' , 37000000 , 2000000 , 850000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Bane Of Power' , '2009-01-01' , INTERVAL '144 minutes' , 8000000 , 90000000 , 130000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Fruit Without Sin' , '2012-06-02' , INTERVAL '83 minutes' , 49000000 , 980000 , 380000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Amusing My Home' , '2012-06-04' , INTERVAL '79 minutes' , 7000000 , 27000000 , 80000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Breaking The Graveyard' , '2014-02-01' , INTERVAL '44 minutes' , 32000000 , 41000000 , 290000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Bandit Of Destruction' , '2014-05-08' , INTERVAL '146 minutes' , 60000000 , 94000000 , 440000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Snake Of The Sea' , '2014-11-15' , INTERVAL '30 minutes' , 12000000 , 47000000 , 410000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Pilots Without A Goal' , '2015-01-11' , INTERVAL '34 minutes' , 3000000 , 9000000 , 270000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Wolves Of History' , '2015-01-15' , INTERVAL '39 minutes' , 32000000 , 7000000 , 130000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Descendants And Snakes' , '2015-06-27' , INTERVAL '48 minutes' , 51000000 , 29000000 , 340000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Lords And Spies' , '2015-07-20' , INTERVAL '159 minutes' , 21000000 , 41000000 , 710000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Edge Of Insanity' , '2016-07-30' , INTERVAL '164 minutes' , 11000000 , 76000000 , 680000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Intention Of The North' , '2017-02-11' , INTERVAL '198 minutes' , 50000000 , 93000000 , 880000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Separated By The Dungeons' , '2017-12-20' , INTERVAL '62 minutes' , 59000000 , 65000000 , 170000);
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) 
VALUES( 'Wspomnienia moich koszmarów' , '2018-12-26' , INTERVAL '79 minutes' , 70000000 , 23000000 , 520000);

INSERT INTO similar_movies VALUES(1,2);
INSERT INTO similar_movies VALUES(19,2);
INSERT INTO similar_movies VALUES(18,2);
INSERT INTO similar_movies VALUES(15,7);
INSERT INTO similar_movies VALUES(9,4);
INSERT INTO similar_movies VALUES(5,2);
INSERT INTO similar_movies VALUES(3,12);
INSERT INTO similar_movies VALUES(2,12);
INSERT INTO similar_movies VALUES(1,34);
INSERT INTO similar_movies VALUES(1,42);
INSERT INTO similar_movies VALUES(2,10);

INSERT INTO alternative_title VALUES(2,'Tree');
INSERT INTO alternative_title VALUES(2,'Freedom');
INSERT INTO alternative_title VALUES(3,'Chistengens');

INSERT INTO production VALUES(1,'United Kingdom');
INSERT INTO production VALUES(1,'China');
INSERT INTO production VALUES(1,'Australia');
INSERT INTO production VALUES(2 , 'United States');
INSERT INTO production VALUES(3 , 'United States');
INSERT INTO production VALUES(4 , 'United States');
INSERT INTO production VALUES(5,'Nigeria');
INSERT INTO production VALUES(6 , 'United States');
INSERT INTO production VALUES(7 , 'United States');
INSERT INTO production VALUES(8 , 'United States');
INSERT INTO production VALUES(9 , 'United States');
INSERT INTO production VALUES(10 , 'United States');
INSERT INTO production VALUES(11 , 'United States');
INSERT INTO production VALUES(12 , 'United States');
INSERT INTO production VALUES(13 , 'United States');
INSERT INTO production VALUES(14 , 'United States');
INSERT INTO production VALUES(15 , 'United States');
INSERT INTO production VALUES(16 , 'United States');
INSERT INTO production VALUES(17 , 'United States');
INSERT INTO production VALUES(18 , 'United States');
INSERT INTO production VALUES(19 , 'United States');
INSERT INTO production VALUES(20 , 'United States');
INSERT INTO production VALUES(21 , 'United States');
INSERT INTO production VALUES(22 , 'United States');
INSERT INTO production VALUES(23 , 'United States');
INSERT INTO production VALUES(24 , 'United States');
INSERT INTO production VALUES(25 , 'United States');
INSERT INTO production VALUES(26 , 'United States');
INSERT INTO production VALUES(27 , 'United States');
INSERT INTO production VALUES(28 , 'United States');
INSERT INTO production VALUES(29 , 'United States');
INSERT INTO production VALUES(30 , 'United States');
INSERT INTO production VALUES(31 , 'United States');
INSERT INTO production VALUES(32 , 'United States');
INSERT INTO production VALUES(33 , 'United States');
INSERT INTO production VALUES(34 , 'United States');
INSERT INTO production VALUES(35 , 'Sweden');
INSERT INTO production VALUES(36 , 'United States');
INSERT INTO production VALUES(37 , 'United States');
INSERT INTO production VALUES(38 , 'United States');
INSERT INTO production VALUES(39 , 'United States');
INSERT INTO production VALUES(40 , 'United States');
INSERT INTO production VALUES(41 , 'United States');
INSERT INTO production VALUES(42 , 'United States');
INSERT INTO production VALUES(43 , 'United States');
INSERT INTO production VALUES(44 , 'United States');
INSERT INTO production VALUES(45 , 'United States');
INSERT INTO production VALUES(46 , 'United States');
INSERT INTO production VALUES(47 , 'United States');
INSERT INTO production VALUES(48 , 'United States');
INSERT INTO production VALUES(49 , 'United States');
INSERT INTO production VALUES(50,'Poland');

INSERT INTO movie_language VALUES(1 , 'English');
INSERT INTO movie_language VALUES(1 , 'Chinesee');
INSERT INTO movie_language VALUES(1 , 'Arabic');
INSERT INTO movie_language VALUES(2 , 'English');
INSERT INTO movie_language VALUES(3 , 'English');
INSERT INTO movie_language VALUES(4 , 'English');
INSERT INTO movie_language VALUES(5 , 'English');
INSERT INTO movie_language VALUES(5 , 'Afrikanaas');
INSERT INTO movie_language VALUES(6 , 'English');
INSERT INTO movie_language VALUES(7 , 'English');
INSERT INTO movie_language VALUES(8 , 'English');
INSERT INTO movie_language VALUES(9 , 'English');
INSERT INTO movie_language VALUES(10 , 'English');
INSERT INTO movie_language VALUES(11 , 'English');
INSERT INTO movie_language VALUES(11 , 'Arabic');
INSERT INTO movie_language VALUES(12 , 'English');
INSERT INTO movie_language VALUES(13 , 'English');
INSERT INTO movie_language VALUES(14 , 'English');
INSERT INTO movie_language VALUES(15 , 'English');
INSERT INTO movie_language VALUES(16 , 'English');
INSERT INTO movie_language VALUES(17 , 'English');
INSERT INTO movie_language VALUES(18 , 'English');
INSERT INTO movie_language VALUES(19 , 'English');
INSERT INTO movie_language VALUES(20 , 'English');
INSERT INTO movie_language VALUES(21 , 'English');
INSERT INTO movie_language VALUES(22 , 'English');
INSERT INTO movie_language VALUES(23 , 'English');
INSERT INTO movie_language VALUES(24 , 'English');
INSERT INTO movie_language VALUES(25 , 'English');
INSERT INTO movie_language VALUES(26 , 'English');
INSERT INTO movie_language VALUES(27 , 'English');
INSERT INTO movie_language VALUES(28 , 'English');
INSERT INTO movie_language VALUES(29 , 'English');
INSERT INTO movie_language VALUES(30 , 'English');
INSERT INTO movie_language VALUES(31 , 'English');
INSERT INTO movie_language VALUES(32 , 'English');
INSERT INTO movie_language VALUES(33 , 'English');
INSERT INTO movie_language VALUES(34 , 'English');
INSERT INTO movie_language VALUES(35 , 'Swedish');
INSERT INTO movie_language VALUES(35 , 'English');
INSERT INTO movie_language VALUES(36 , 'English');
INSERT INTO movie_language VALUES(37 , 'English');
INSERT INTO movie_language VALUES(38 , 'English');
INSERT INTO movie_language VALUES(39 , 'English');
INSERT INTO movie_language VALUES(40 , 'English');
INSERT INTO movie_language VALUES(41 , 'English');
INSERT INTO movie_language VALUES(42 , 'English');
INSERT INTO movie_language VALUES(43 , 'English');
INSERT INTO movie_language VALUES(44 , 'English');
INSERT INTO movie_language VALUES(45 , 'English');
INSERT INTO movie_language VALUES(46 , 'English');
INSERT INTO movie_language VALUES(47 , 'English');
INSERT INTO movie_language VALUES(48 , 'English');
INSERT INTO movie_language VALUES(49 , 'English');
INSERT INTO movie_language VALUES(50 , 'Polish');

INSERT INTO movie_genre VALUES(1 , 'Drama');
INSERT INTO movie_genre VALUES(2 , 'Drama');
INSERT INTO movie_genre VALUES(3 , 'Drama');
INSERT INTO movie_genre VALUES(4 , 'Drama');
INSERT INTO movie_genre VALUES(5 , 'Drama');
INSERT INTO movie_genre VALUES(6 , 'Drama');
INSERT INTO movie_genre VALUES(7 , 'Drama');
INSERT INTO movie_genre VALUES(8 , 'Drama');
INSERT INTO movie_genre VALUES(9 , 'Drama');
INSERT INTO movie_genre VALUES(10 , 'Drama');
INSERT INTO movie_genre VALUES(11 , 'Drama');
INSERT INTO movie_genre VALUES(12 , 'Drama');
INSERT INTO movie_genre VALUES(13 , 'Drama');
INSERT INTO movie_genre VALUES(31 , 'Drama');
INSERT INTO movie_genre VALUES(32 , 'Drama');
INSERT INTO movie_genre VALUES(33 , 'Drama');
INSERT INTO movie_genre VALUES(34 , 'Drama');
INSERT INTO movie_genre VALUES(35 , 'Drama');
INSERT INTO movie_genre VALUES(36 , 'Drama');
INSERT INTO movie_genre VALUES(37 , 'Drama');
INSERT INTO movie_genre VALUES(38 , 'Drama');
INSERT INTO movie_genre VALUES(39 , 'Drama');
INSERT INTO movie_genre VALUES(40 , 'Drama');
INSERT INTO movie_genre VALUES(41 , 'Drama');
INSERT INTO movie_genre VALUES(42 , 'Drama');
INSERT INTO movie_genre VALUES(43 , 'Drama');
INSERT INTO movie_genre VALUES(44 , 'Drama');
INSERT INTO movie_genre VALUES(45 , 'Drama');
INSERT INTO movie_genre VALUES(46 , 'Drama');
INSERT INTO movie_genre VALUES(47 , 'Drama');
INSERT INTO movie_genre VALUES(48 , 'Drama');
INSERT INTO movie_genre VALUES(49 , 'Drama');
INSERT INTO movie_genre VALUES(50 , 'Drama');
INSERT INTO movie_genre VALUES(2 , 'Action');
INSERT INTO movie_genre VALUES(3 , 'Action');
INSERT INTO movie_genre VALUES(4 , 'Action');
INSERT INTO movie_genre VALUES(5 , 'Action');
INSERT INTO movie_genre VALUES(6 , 'Action');
INSERT INTO movie_genre VALUES(7 , 'Action');
INSERT INTO movie_genre VALUES(8 , 'Action');
INSERT INTO movie_genre VALUES(9 , 'Action');
INSERT INTO movie_genre VALUES(10 , 'Action');
INSERT INTO movie_genre VALUES(11 , 'Action');
INSERT INTO movie_genre VALUES(12 , 'Action');
INSERT INTO movie_genre VALUES(13 , 'Action');
INSERT INTO movie_genre VALUES(14 , 'Action');
INSERT INTO movie_genre VALUES(15 , 'Action');
INSERT INTO movie_genre VALUES(16 , 'Action');
INSERT INTO movie_genre VALUES(17 , 'Action');
INSERT INTO movie_genre VALUES(18 , 'Action');
INSERT INTO movie_genre VALUES(19 , 'Action');
INSERT INTO movie_genre VALUES(20 , 'Action');
INSERT INTO movie_genre VALUES(21 , 'Action');
INSERT INTO movie_genre VALUES(22 , 'Action');
INSERT INTO movie_genre VALUES(23 , 'Action');
INSERT INTO movie_genre VALUES(24 , 'Action');
INSERT INTO movie_genre VALUES(25 , 'Action');
INSERT INTO movie_genre VALUES(26 , 'Action');
INSERT INTO movie_genre VALUES(27 , 'Action');
INSERT INTO movie_genre VALUES(28 , 'Action');
INSERT INTO movie_genre VALUES(29 , 'Action');
INSERT INTO movie_genre VALUES(30 , 'Action');
INSERT INTO movie_genre VALUES(42 , 'Action');
INSERT INTO movie_genre VALUES(43 , 'Action');
INSERT INTO movie_genre VALUES(44 , 'Action');
INSERT INTO movie_genre VALUES(45 , 'Action');
INSERT INTO movie_genre VALUES(46 , 'Action');
INSERT INTO movie_genre VALUES(47 , 'Action');
INSERT INTO movie_genre VALUES(48 , 'Action');
INSERT INTO movie_genre VALUES(49 , 'Action');
INSERT INTO movie_genre VALUES(50 , 'Action');
INSERT INTO movie_genre VALUES(11 , 'Documentary');
INSERT INTO movie_genre VALUES(12 , 'Documentary');
INSERT INTO movie_genre VALUES(15 , 'Documentary');
INSERT INTO movie_genre VALUES(16 , 'Documentary');
INSERT INTO movie_genre VALUES(17 , 'Documentary');
INSERT INTO movie_genre VALUES(18 , 'Documentary');
INSERT INTO movie_genre VALUES(19 , 'Documentary');
INSERT INTO movie_genre VALUES(34 , 'Documentary');
INSERT INTO movie_genre VALUES(35 , 'Documentary');
INSERT INTO movie_genre VALUES(38 , 'Documentary');
INSERT INTO movie_genre VALUES(13 , 'Animation');
INSERT INTO movie_genre VALUES(14 , 'Animation');
INSERT INTO movie_genre VALUES(15 , 'Animation');
INSERT INTO movie_genre VALUES(16 , 'Animation');
INSERT INTO movie_genre VALUES(17 , 'Animation');
INSERT INTO movie_genre VALUES(43 , 'Animation');
INSERT INTO movie_genre VALUES(45 , 'Animation');
INSERT INTO movie_genre VALUES(49 , 'Animation');
INSERT INTO movie_genre VALUES(6 , 'Comedy');
INSERT INTO movie_genre VALUES(7 , 'Comedy');
INSERT INTO movie_genre VALUES(8 , 'Comedy');
INSERT INTO movie_genre VALUES(9 , 'Comedy');
INSERT INTO movie_genre VALUES(10 , 'Comedy');
INSERT INTO movie_genre VALUES(16 , 'Comedy');
INSERT INTO movie_genre VALUES(17 , 'Comedy');
INSERT INTO movie_genre VALUES(25 , 'Comedy');
INSERT INTO movie_genre VALUES(26 , 'Comedy');
INSERT INTO movie_genre VALUES(27 , 'Comedy');
INSERT INTO movie_genre VALUES(28 , 'Comedy');
INSERT INTO movie_genre VALUES(29 , 'Comedy');
INSERT INTO movie_genre VALUES(30 , 'Comedy');
INSERT INTO movie_genre VALUES(34 , 'Comedy');
INSERT INTO movie_genre VALUES(35 , 'Comedy');
INSERT INTO movie_genre VALUES(38 , 'Comedy');
INSERT INTO movie_genre VALUES(2 , 'Sci-fi');
INSERT INTO movie_genre VALUES(3 , 'Sci-fi');
INSERT INTO movie_genre VALUES(4 , 'Sci-fi');
INSERT INTO movie_genre VALUES(7 , 'Sci-fi');
INSERT INTO movie_genre VALUES(8 , 'Sci-fi');
INSERT INTO movie_genre VALUES(9 , 'Sci-fi');
INSERT INTO movie_genre VALUES(10 , 'Sci-fi');
INSERT INTO movie_genre VALUES(11 , 'Sci-fi');
INSERT INTO movie_genre VALUES(12 , 'Sci-fi');
INSERT INTO movie_genre VALUES(13 , 'Sci-fi');
INSERT INTO movie_genre VALUES(14 , 'Sci-fi');
INSERT INTO movie_genre VALUES(15 , 'Sci-fi');
INSERT INTO movie_genre VALUES(19 , 'Sci-fi');
INSERT INTO movie_genre VALUES(20 , 'Sci-fi');
INSERT INTO movie_genre VALUES(24 , 'Sci-fi');
INSERT INTO movie_genre VALUES(25 , 'Sci-fi');
INSERT INTO movie_genre VALUES(26 , 'Sci-fi');
INSERT INTO movie_genre VALUES(27 , 'Sci-fi');
INSERT INTO movie_genre VALUES(28 , 'Sci-fi');
INSERT INTO movie_genre VALUES(29 , 'Sci-fi');
INSERT INTO movie_genre VALUES(30 , 'Sci-fi');
INSERT INTO movie_genre VALUES(31 , 'Sci-fi');
INSERT INTO movie_genre VALUES(42 , 'Sci-fi');
INSERT INTO movie_genre VALUES(43 , 'Sci-fi');


INSERT INTO production_company VALUES(2 , 'Disney');
INSERT INTO production_company VALUES(3 , 'Disney');
INSERT INTO production_company VALUES(4 , 'Disney');
INSERT INTO production_company VALUES(11 , 'Disney');
INSERT INTO production_company VALUES(12 , 'Disney');
INSERT INTO production_company VALUES(13 , 'Disney');
INSERT INTO production_company VALUES(14 , 'Disney');
INSERT INTO production_company VALUES(15 , 'Disney');
INSERT INTO production_company VALUES(25 , 'Disney');
INSERT INTO production_company VALUES(26 , 'Disney');
INSERT INTO production_company VALUES(27 , 'Disney');
INSERT INTO production_company VALUES(28 , 'Disney');
INSERT INTO production_company VALUES(29 , 'Disney');
INSERT INTO production_company VALUES(30 , 'Disney');
INSERT INTO production_company VALUES(31 , 'Disney');
INSERT INTO production_company VALUES(32 , 'Disney');
INSERT INTO production_company VALUES(33 , 'Disney');
INSERT INTO production_company VALUES(34 , 'Disney');
INSERT INTO production_company VALUES(1 , 'Warner Bros');
INSERT INTO production_company VALUES(1 , 'China movies');
INSERT INTO production_company VALUES(5 , 'Warner Bros');
INSERT INTO production_company VALUES(6 , 'Warner Bros');
INSERT INTO production_company VALUES(7 , 'Warner Bros');
INSERT INTO production_company VALUES(8 , 'Warner Bros');
INSERT INTO production_company VALUES(9 , 'Warner Bros');
INSERT INTO production_company VALUES(10 , 'Warner Bros');
INSERT INTO production_company VALUES(16 , 'Warner Bros');
INSERT INTO production_company VALUES(17 , 'Warner Bros');
INSERT INTO production_company VALUES(18 , 'Warner Bros');
INSERT INTO production_company VALUES(19 , 'Warner Bros');
INSERT INTO production_company VALUES(20 , 'Warner Bros');
INSERT INTO production_company VALUES(21 , 'Warner Bros');
INSERT INTO production_company VALUES(22 , 'Warner Bros');
INSERT INTO production_company VALUES(23 , 'Warner Bros');
INSERT INTO production_company VALUES(24 , 'Warner Bros');
INSERT INTO production_company VALUES(35 , 'Warner Bros');
INSERT INTO production_company VALUES(36 , 'Warner Bros');
INSERT INTO production_company VALUES(37 , 'Warner Bros');
INSERT INTO production_company VALUES(38 , 'Warner Bros');
INSERT INTO production_company VALUES(39 , 'Warner Bros');
INSERT INTO production_company VALUES(40 , 'Warner Bros');
INSERT INTO production_company VALUES(41 , 'Warner Bros');
INSERT INTO production_company VALUES(42 , 'Warner Bros');
INSERT INTO production_company VALUES(43 , 'Warner Bros');
INSERT INTO production_company VALUES(44 , 'Warner Bros');
INSERT INTO production_company VALUES(45 , 'Warner Bros');
INSERT INTO production_company VALUES(46 , 'Warner Bros');
INSERT INTO production_company VALUES(47 , 'Warner Bros');
INSERT INTO production_company VALUES(48 , 'Warner Bros');
INSERT INTO production_company VALUES(49 , 'Warner Bros');
INSERT INTO production_company VALUES(50 , 'Polski Instytut Filmowy');

INSERT INTO users(login,password)
SELECT
names,
md5(random()::text)
FROM unnest(
ARRAY [
'achana6',
'Wayna31',
'Enosh2',
'Govinda2',
'Jagdishyi',
'Reynard',
'Sabah7',
'Sinta5',
'Kadek78',
'Srinivas4368',
'Morpheus2',
'Murtada3',
'Ruaraidh',
'Shota34',
'Loke2',
'Drest36423',
'Silvia',
'Elon3',
'Tabatha',
'Michal42',
'Chiyembekezo',
'Dag',
'Arie',
'Fulgenzio5',
'Audhild2',
'Montana',
'Minos',
'Arnulf',
'Giselmund',
'Mercedes5456',
'Alban',
'Octavius',
'Aurelius4',
'Kip',
'EvyDinesh',
'Arie50',
'Raj1',
'Enric8',
'Nereus3',
'Imogen29',
'Iracema',
'Tanja643',
'Ratnaq8',
'Dharma36',
'Kaija',
'Thancmar53',
'Valentin3',
'Sergius',
'Philippos2',
'Belshatzzar3'
]) names;


INSERT INTO review VALUES('Imogen29',1,'goooood');
INSERT INTO review VALUES('Raj1',14,'so so');
INSERT INTO review VALUES('Audhild2',43,'How do you follow the pop culture event of the decade?
That’s the question that Avengers: 
Endgame was faced with in the wake of its hugely successful predecessor 
Infinity War, while also juggling its own story, huge (despite Thanos’s best efforts) 
cast and an incredibly twisted continuity after over a decade of superhero movies.');
INSERT INTO review VALUES('Kaija',4,'not bad');
INSERT INTO review VALUES('Imogen29',34,'goooood');
INSERT INTO review VALUES('Loke2',1,'a bit too long');
INSERT INTO review VALUES('Imogen29',15,'goooood');

INSERT INTO watchlist VALUES('Imogen29',6);
INSERT INTO watchlist VALUES('Imogen29',16);
INSERT INTO watchlist VALUES('Imogen29',4);
INSERT INTO watchlist VALUES('Imogen29',34);
INSERT INTO watchlist VALUES('Imogen29',42);
INSERT INTO watchlist VALUES('Imogen29',3);
INSERT INTO watchlist VALUES('Imogen29',1);
INSERT INTO watchlist VALUES('Imogen29',2);
INSERT INTO watchlist VALUES('Audhild2',6);
INSERT INTO watchlist VALUES('Audhild2',1);
INSERT INTO watchlist VALUES('Audhild2',4);
INSERT INTO watchlist VALUES('Audhild2',34);
INSERT INTO watchlist VALUES('Audhild2',42);
INSERT INTO watchlist VALUES('Audhild2',41);
INSERT INTO watchlist VALUES('Audhild2',12);
INSERT INTO watchlist VALUES('Audhild2',7);

INSERT INTO categories VALUES('Picture', '1927-01-01', NULL, 'M');
INSERT INTO categories VALUES('Director', '1927-01-01', NULL, 'P');
INSERT INTO categories VALUES('Actor', '1927-01-01', NULL, 'P');
INSERT INTO categories VALUES('Actress', '1927-01-01', NULL, 'P');
INSERT INTO categories VALUES('Supporting Actor', '1936-01-01', NULL, 'P');
INSERT INTO categories VALUES('Supporting Actress', '1936-01-01', NULL, 'P');
INSERT INTO categories VALUES('Animated Feature Film', '2001-01-01', NULL, 'M');
INSERT INTO categories VALUES('Animated Short Film', '1930-01-01', NULL, 'M');
INSERT INTO categories VALUES('Cinematography', '1927-01-01', NULL, 'M');
INSERT INTO categories VALUES('Costume Design', '1948-01-01', NULL, 'M');
INSERT INTO categories VALUES('Documentary Feature', '1943-01-01', NULL, 'M');
INSERT INTO categories VALUES('Documentary Short Subject', '1941-01-01', NULL, 'M');
INSERT INTO categories VALUES('Film Editing', '1934-01-01', NULL, 'M');
INSERT INTO categories VALUES('International Feature Film', '1947-01-01', NULL, 'M');
INSERT INTO categories VALUES('Live Action Short Film', '1931-01-01', NULL, 'M');
INSERT INTO categories VALUES('Makeup and Hairstyling', '1981-01-01', NULL, 'M');
INSERT INTO categories VALUES('Original Score', '1934-01-01', NULL, 'M');
INSERT INTO categories VALUES('Original Song', '1934-01-01', NULL, 'M');
INSERT INTO categories VALUES('Production Design', '1927-01-01', NULL, 'M');
INSERT INTO categories VALUES('Sound Editing', '1963-01-01', NULL, 'M');
INSERT INTO categories VALUES('Sound Mixing', '1929-01-01', NULL, 'M');
INSERT INTO categories VALUES('Visual Effects', '1939-01-01', NULL, 'M');
INSERT INTO categories VALUES('Adapted Screenplay', '1927-01-01', NULL, 'M');
INSERT INTO categories VALUES('Original Screenplay', '1940-01-01', NULL, 'M');
INSERT INTO categories VALUES('Assistant Director', '1932-01-01', '1937-12-31', 'P');
INSERT INTO categories VALUES('Director - Comedy', '1927-01-01', '1928-12-31', 'P');
INSERT INTO categories VALUES('Director - Dramatic', '1927-01-01', '1928-12-31', 'P');
INSERT INTO categories VALUES('Dance Direction', '1935-01-01', '1937-12-31', 'M');
INSERT INTO categories VALUES('Engineering Effects', '1927-01-01', '1928-12-31', 'M');
INSERT INTO categories VALUES('Original Musical or Comedy Score', '1995-01-01', '1998-12-31', 'M');
INSERT INTO categories VALUES('Original Musical', '1984-01-01', '1984-12-31', 'M');
INSERT INTO categories VALUES('Original Story', '1927-01-01', '1956-12-31', 'M');
INSERT INTO categories VALUES('Short Subject – Color', '1936-01-01', '1937-12-31', 'M');
INSERT INTO categories VALUES('Short Subject – Comedy', '1931-01-01', '1935-12-31', 'M');
INSERT INTO categories VALUES('Title Writing', '1927-01-01', '1928-12-31', 'M');
INSERT INTO categories VALUES('Unique and Artistic Production', '1927-01-01', '1928-12-31', 'M');

--categories are constant
CREATE OR REPLACE RULE const_categories AS ON INSERT TO categories DO INSTEAD NOTHING;
CREATE OR REPLACE RULE const_categories AS ON UPDATE TO categories DO INSTEAD NOTHING;
CREATE OR REPLACE RULE const_categories AS ON DELETE TO categories DO INSTEAD NOTHING;

INSERT INTO movie_ratings VALUES( 20 , 'achana6' , 10 );
INSERT INTO movie_ratings VALUES( 11 , 'Wayna31' , 7 );
INSERT INTO movie_ratings VALUES( 44 , 'Enosh2' , 9 );
INSERT INTO movie_ratings VALUES( 41 , 'Govinda2' , 9 );
INSERT INTO movie_ratings VALUES( 31 , 'Jagdishyi' , 10 );
INSERT INTO movie_ratings VALUES( 45 , 'Reynard' , 9 );
INSERT INTO movie_ratings VALUES( 33 , 'Sabah7' , 4 );
INSERT INTO movie_ratings VALUES( 36 , 'Sinta5' , 4 );
INSERT INTO movie_ratings VALUES( 39 , 'Kadek78' , 1 );
INSERT INTO movie_ratings VALUES( 3 , 'Srinivas4368' , 9 );
INSERT INTO movie_ratings VALUES( 12 , 'Morpheus2' , 2 );
INSERT INTO movie_ratings VALUES( 42 , 'Murtada3' , 3 );
INSERT INTO movie_ratings VALUES( 18 , 'Ruaraidh' , 10 );
INSERT INTO movie_ratings VALUES( 39 , 'Shota34' , 3 );
INSERT INTO movie_ratings VALUES( 46 , 'Loke2' , 10 );
INSERT INTO movie_ratings VALUES( 35 , 'Drest36423' , 4 );
INSERT INTO movie_ratings VALUES( 50 , 'Silvia' , 6 );
INSERT INTO movie_ratings VALUES( 17 , 'Elon3' , 7 );
INSERT INTO movie_ratings VALUES( 6 , 'Tabatha' , 1 );
INSERT INTO movie_ratings VALUES( 19 , 'Michal42' , 10 );
INSERT INTO movie_ratings VALUES( 24 , 'Chiyembekezo' , 7 );
INSERT INTO movie_ratings VALUES( 7 , 'Dag' , 9 );
INSERT INTO movie_ratings VALUES( 19 , 'Arie' , 8 );
INSERT INTO movie_ratings VALUES( 40 , 'Fulgenzio5' , 5 );
INSERT INTO movie_ratings VALUES( 17 , 'Montana' , 4 );
INSERT INTO movie_ratings VALUES( 24 , 'Minos' , 1 );
INSERT INTO movie_ratings VALUES( 34 , 'Arnulf' , 1 );
INSERT INTO movie_ratings VALUES( 6 , 'Giselmund' , 9 );
INSERT INTO movie_ratings VALUES( 39 , 'Mercedes5456' , 10 );
INSERT INTO movie_ratings VALUES( 4 , 'Alban' , 7 );
INSERT INTO movie_ratings VALUES( 20 , 'Aurelius4' , 10 );
INSERT INTO movie_ratings VALUES( 44 , 'Kip' , 3 );
INSERT INTO movie_ratings VALUES( 37 , 'EvyDinesh' , 3 );
INSERT INTO movie_ratings VALUES( 47 , 'Arie50' , 10 );
INSERT INTO movie_ratings VALUES( 6 , 'Raj1' , 1 );
INSERT INTO movie_ratings VALUES( 7 , 'Enric8' , 8 );
INSERT INTO movie_ratings VALUES( 30 , 'Nereus3' , 9 );
INSERT INTO movie_ratings VALUES( 6 , 'Imogen29' , 2 );
INSERT INTO movie_ratings VALUES( 31 , 'Iracema' , 4 );
INSERT INTO movie_ratings VALUES( 30 , 'Tanja643' , 5 );
INSERT INTO movie_ratings VALUES( 29 , 'Dharma36' , 8 );
INSERT INTO movie_ratings VALUES( 11 , 'Kaija' , 8 );
INSERT INTO movie_ratings VALUES( 10 , 'Thancmar53' , 1 );
INSERT INTO movie_ratings VALUES( 6 , 'Valentin3' , 8 );
INSERT INTO movie_ratings VALUES( 21 , 'Sergius' , 6 );
INSERT INTO movie_ratings VALUES( 45 , 'Philippos2' , 2 );
INSERT INTO movie_ratings VALUES( 12 , 'Belshatzzar3' , 9 );
INSERT INTO movie_ratings VALUES( 13 , 'achana6' , 4 );
INSERT INTO movie_ratings VALUES( 27 , 'Wayna31' , 10 );
INSERT INTO movie_ratings VALUES( 45 , 'Enosh2' , 6 );
INSERT INTO movie_ratings VALUES( 11 , 'Govinda2' , 4 );
INSERT INTO movie_ratings VALUES( 24 , 'Jagdishyi' , 6 );
INSERT INTO movie_ratings VALUES( 24 , 'Reynard' , 5 );
INSERT INTO movie_ratings VALUES( 10 , 'Sabah7' , 3 );
INSERT INTO movie_ratings VALUES( 18 , 'Sinta5' , 8 );
INSERT INTO movie_ratings VALUES( 24 , 'Kadek78' , 9 );
INSERT INTO movie_ratings VALUES( 28 , 'Srinivas4368' , 10 );
INSERT INTO movie_ratings VALUES( 44 , 'Morpheus2' , 9 );
INSERT INTO movie_ratings VALUES( 10 , 'Murtada3' , 2 );
INSERT INTO movie_ratings VALUES( 31 , 'Ruaraidh' , 1 );
INSERT INTO movie_ratings VALUES( 41 , 'Shota34' , 5 );
INSERT INTO movie_ratings VALUES( 36 , 'Drest36423' , 6 );
INSERT INTO movie_ratings VALUES( 18 , 'Silvia' , 8 );
INSERT INTO movie_ratings VALUES( 4 , 'Elon3' , 9 );
INSERT INTO movie_ratings VALUES( 9 , 'Tabatha' , 2 );
INSERT INTO movie_ratings VALUES( 1 , 'Michal42' , 2 );
INSERT INTO movie_ratings VALUES( 10 , 'Chiyembekezo' , 6 );
INSERT INTO movie_ratings VALUES( 13 , 'Dag' , 5 );
INSERT INTO movie_ratings VALUES( 28 , 'Arie' , 8 );
INSERT INTO movie_ratings VALUES( 49 , 'Fulgenzio5' , 2 );
INSERT INTO movie_ratings VALUES( 17 , 'Audhild2' , 3 );
INSERT INTO movie_ratings VALUES( 34 , 'Montana' , 1 );
INSERT INTO movie_ratings VALUES( 12 , 'Minos' , 4 );
INSERT INTO movie_ratings VALUES( 3 , 'Arnulf' , 5 );
INSERT INTO movie_ratings VALUES( 45 , 'Mercedes5456' , 2 );
INSERT INTO movie_ratings VALUES( 47 , 'Alban' , 2 );
INSERT INTO movie_ratings VALUES( 28 , 'Octavius' , 9 );
INSERT INTO movie_ratings VALUES( 36 , 'Aurelius4' , 5 );
INSERT INTO movie_ratings VALUES( 43 , 'Kip' , 9 );
INSERT INTO movie_ratings VALUES( 49 , 'EvyDinesh' , 10 );
INSERT INTO movie_ratings VALUES( 17 , 'Arie50' , 6 );
INSERT INTO movie_ratings VALUES( 10 , 'Raj1' , 6 );
INSERT INTO movie_ratings VALUES( 2 , 'Enric8' , 8 );
INSERT INTO movie_ratings VALUES( 1 , 'Nereus3' , 3 );
INSERT INTO movie_ratings VALUES( 47 , 'Iracema' , 2 );
INSERT INTO movie_ratings VALUES( 41 , 'Tanja643' , 4 );
INSERT INTO movie_ratings VALUES( 27 , 'Ratnaq8' , 3 );
INSERT INTO movie_ratings VALUES( 4 , 'Dharma36' , 5 );
INSERT INTO movie_ratings VALUES( 38 , 'Kaija' , 1 );
INSERT INTO movie_ratings VALUES( 2 , 'Thancmar53' , 4 );
INSERT INTO movie_ratings VALUES( 13 , 'Valentin3' , 3 );
INSERT INTO movie_ratings VALUES( 14 , 'Sergius' , 10 );
INSERT INTO movie_ratings VALUES( 26 , 'Philippos2' , 2 );
INSERT INTO movie_ratings VALUES( 36 , 'Belshatzzar3' , 8 );
INSERT INTO movie_ratings VALUES( 46 , 'achana6' , 10 );
INSERT INTO movie_ratings VALUES( 21 , 'Wayna31' , 8 );
INSERT INTO movie_ratings VALUES( 38 , 'Enosh2' , 5 );
INSERT INTO movie_ratings VALUES( 44 , 'Govinda2' , 4 );
INSERT INTO movie_ratings VALUES( 42 , 'Jagdishyi' , 3 );
INSERT INTO movie_ratings VALUES( 12 , 'Reynard' , 10 );
INSERT INTO movie_ratings VALUES( 37 , 'Sabah7' , 7 );
INSERT INTO movie_ratings VALUES( 35 , 'Sinta5' , 1 );
INSERT INTO movie_ratings VALUES( 1 , 'Kadek78' , 1 );
INSERT INTO movie_ratings VALUES( 18 , 'Srinivas4368' , 9 );
INSERT INTO movie_ratings VALUES( 31 , 'Morpheus2' , 10 );
INSERT INTO movie_ratings VALUES( 24 , 'Murtada3' , 4 );
INSERT INTO movie_ratings VALUES( 1 , 'Ruaraidh' , 5 );
INSERT INTO movie_ratings VALUES( 35 , 'Shota34' , 7 );
INSERT INTO movie_ratings VALUES( 14 , 'Loke2' , 8 );
INSERT INTO movie_ratings VALUES( 28 , 'Drest36423' , 6 );
INSERT INTO movie_ratings VALUES( 34 , 'Silvia' , 1 );
INSERT INTO movie_ratings VALUES( 20 , 'Elon3' , 3 );
INSERT INTO movie_ratings VALUES( 27 , 'Tabatha' , 5 );
INSERT INTO movie_ratings VALUES( 50 , 'Michal42' , 2 );
INSERT INTO movie_ratings VALUES( 35 , 'Chiyembekezo' , 9 );
INSERT INTO movie_ratings VALUES( 18 , 'Dag' , 10 );
INSERT INTO movie_ratings VALUES( 45 , 'Fulgenzio5' , 4 );
INSERT INTO movie_ratings VALUES( 13 , 'Audhild2' , 4 );
INSERT INTO movie_ratings VALUES( 40 , 'Minos' , 8 );
INSERT INTO movie_ratings VALUES( 7 , 'Arnulf' , 7 );
INSERT INTO movie_ratings VALUES( 9 , 'Giselmund' , 1 );
INSERT INTO movie_ratings VALUES( 30 , 'Mercedes5456' , 4 );
INSERT INTO movie_ratings VALUES( 14 , 'Alban' , 5 );
INSERT INTO movie_ratings VALUES( 23 , 'Octavius' , 10 );
INSERT INTO movie_ratings VALUES( 23 , 'Aurelius4' , 3 );
INSERT INTO movie_ratings VALUES( 4 , 'Kip' , 6 );
INSERT INTO movie_ratings VALUES( 16 , 'EvyDinesh' , 1 );
INSERT INTO movie_ratings VALUES( 12 , 'Arie50' , 1 );
INSERT INTO movie_ratings VALUES( 3 , 'Raj1' , 6 );
INSERT INTO movie_ratings VALUES( 28 , 'Enric8' , 5 );
INSERT INTO movie_ratings VALUES( 24 , 'Nereus3' , 10 );
INSERT INTO movie_ratings VALUES( 17 , 'Imogen29' , 10 );
INSERT INTO movie_ratings VALUES( 42 , 'Iracema' , 4 );
INSERT INTO movie_ratings VALUES( 44 , 'Tanja643' , 3 );
INSERT INTO movie_ratings VALUES( 46 , 'Ratnaq8' , 7 );
INSERT INTO movie_ratings VALUES( 28 , 'Kaija' , 9 );
INSERT INTO movie_ratings VALUES( 3 , 'Thancmar53' , 5 );
INSERT INTO movie_ratings VALUES( 29 , 'Valentin3' , 5 );
INSERT INTO movie_ratings VALUES( 49 , 'Sergius' , 1 );
INSERT INTO movie_ratings VALUES( 14 , 'Philippos2' , 3 );
INSERT INTO movie_ratings VALUES( 22 , 'Belshatzzar3' , 9 );
INSERT INTO movie_ratings VALUES( 14 , 'achana6' , 1 );
INSERT INTO movie_ratings VALUES( 33 , 'Wayna31' , 9 );
INSERT INTO movie_ratings VALUES( 3 , 'Enosh2' , 10 );
INSERT INTO movie_ratings VALUES( 19 , 'Govinda2' , 7 );
INSERT INTO movie_ratings VALUES( 13 , 'Jagdishyi' , 10 );
INSERT INTO movie_ratings VALUES( 18 , 'Reynard' , 6 );
INSERT INTO movie_ratings VALUES( 14 , 'Sabah7' , 4 );
INSERT INTO movie_ratings VALUES( 44 , 'Sinta5' , 4 );
INSERT INTO movie_ratings VALUES( 10 , 'Kadek78' , 4 );
INSERT INTO movie_ratings VALUES( 6 , 'Srinivas4368' , 7 );
INSERT INTO movie_ratings VALUES( 22 , 'Morpheus2' , 7 );
INSERT INTO movie_ratings VALUES( 3 , 'Murtada3' , 9 );
INSERT INTO movie_ratings VALUES( 40 , 'Ruaraidh' , 8 );
INSERT INTO movie_ratings VALUES( 12 , 'Shota34' , 5 );
INSERT INTO movie_ratings VALUES( 37 , 'Loke2' , 1 );
INSERT INTO movie_ratings VALUES( 21 , 'Drest36423' , 8 );
INSERT INTO movie_ratings VALUES( 40 , 'Silvia' , 8 );
INSERT INTO movie_ratings VALUES( 23 , 'Tabatha' , 1 );
INSERT INTO movie_ratings VALUES( 5 , 'Michal42' , 4 );
INSERT INTO movie_ratings VALUES( 18 , 'Chiyembekezo' , 6 );
INSERT INTO movie_ratings VALUES( 8 , 'Dag' , 8 );
INSERT INTO movie_ratings VALUES( 17 , 'Arie' , 4 );
INSERT INTO movie_ratings VALUES( 44 , 'Fulgenzio5' , 8 );
INSERT INTO movie_ratings VALUES( 38 , 'Audhild2' , 2 );
INSERT INTO movie_ratings VALUES( 15 , 'Minos' , 10 );
INSERT INTO movie_ratings VALUES( 38 , 'Arnulf' , 6 );
INSERT INTO movie_ratings VALUES( 23 , 'Giselmund' , 10 );
INSERT INTO movie_ratings VALUES( 15 , 'Mercedes5456' , 7 );
INSERT INTO movie_ratings VALUES( 39 , 'Alban' , 6 );
INSERT INTO movie_ratings VALUES( 32 , 'Octavius' , 6 );
INSERT INTO movie_ratings VALUES( 37 , 'Aurelius4' , 7 );
INSERT INTO movie_ratings VALUES( 45 , 'Kip' , 1 );
INSERT INTO movie_ratings VALUES( 27 , 'EvyDinesh' , 7 );
INSERT INTO movie_ratings VALUES( 35 , 'Arie50' , 4 );
INSERT INTO movie_ratings VALUES( 44 , 'Raj1' , 1 );
INSERT INTO movie_ratings VALUES( 48 , 'Enric8' , 1 );
INSERT INTO movie_ratings VALUES( 20 , 'Nereus3' , 3 );
INSERT INTO movie_ratings VALUES( 44 , 'Imogen29' , 8 );
INSERT INTO movie_ratings VALUES( 18 , 'Tanja643' , 8 );
INSERT INTO movie_ratings VALUES( 3 , 'Ratnaq8' , 8 );
INSERT INTO movie_ratings VALUES( 2 , 'Dharma36' , 5 );
INSERT INTO movie_ratings VALUES( 22 , 'Kaija' , 1 );
INSERT INTO movie_ratings VALUES( 44 , 'Valentin3' , 10 );
INSERT INTO movie_ratings VALUES( 32 , 'Sergius' , 5 );
INSERT INTO movie_ratings VALUES( 43 , 'Philippos2' , 6 );
INSERT INTO movie_ratings VALUES( 29 , 'Belshatzzar3' , 7 );
INSERT INTO movie_ratings VALUES( 22 , 'achana6' , 5 );
INSERT INTO movie_ratings VALUES( 36 , 'Wayna31' , 4 );
INSERT INTO movie_ratings VALUES( 26 , 'Enosh2' , 6 );
INSERT INTO movie_ratings VALUES( 45 , 'Govinda2' , 4 );
INSERT INTO movie_ratings VALUES( 5 , 'Jagdishyi' , 6 );
INSERT INTO movie_ratings VALUES( 9 , 'Reynard' , 5 );
INSERT INTO movie_ratings VALUES( 12 , 'Sabah7' , 7 );
INSERT INTO movie_ratings VALUES( 19 , 'Sinta5' , 7 );
INSERT INTO movie_ratings VALUES( 37 , 'Srinivas4368' , 3 );
INSERT INTO movie_ratings VALUES( 46 , 'Morpheus2' , 5 );
INSERT INTO movie_ratings VALUES( 19 , 'Murtada3' , 7 );
INSERT INTO movie_ratings VALUES( 17 , 'Ruaraidh' , 7 );
INSERT INTO movie_ratings VALUES( 48 , 'Shota34' , 6 );
INSERT INTO movie_ratings VALUES( 19 , 'Loke2' , 4 );
INSERT INTO movie_ratings VALUES( 8 , 'Silvia' , 10 );
INSERT INTO movie_ratings VALUES( 36 , 'Elon3' , 6 );
INSERT INTO movie_ratings VALUES( 5 , 'Tabatha' , 6 );
INSERT INTO movie_ratings VALUES( 15 , 'Michal42' , 10 );
INSERT INTO movie_ratings VALUES( 32 , 'Chiyembekezo' , 7 );
INSERT INTO movie_ratings VALUES( 36 , 'Dag' , 4 );
INSERT INTO movie_ratings VALUES( 3 , 'Arie' , 5 );
INSERT INTO movie_ratings VALUES( 24 , 'Fulgenzio5' , 7 );
INSERT INTO movie_ratings VALUES( 2 , 'Audhild2' , 3 );
INSERT INTO movie_ratings VALUES( 50 , 'Montana' , 5 );
INSERT INTO movie_ratings VALUES( 23 , 'Minos' , 1 );
INSERT INTO movie_ratings VALUES( 8 , 'Arnulf' , 6 );
INSERT INTO movie_ratings VALUES( 20 , 'Giselmund' , 1 );
INSERT INTO movie_ratings VALUES( 42 , 'Mercedes5456' , 5 );
INSERT INTO movie_ratings VALUES( 50 , 'Alban' , 7 );
INSERT INTO movie_ratings VALUES( 46 , 'Octavius' , 4 );
INSERT INTO movie_ratings VALUES( 17 , 'Aurelius4' , 9 );
INSERT INTO movie_ratings VALUES( 33 , 'Kip' , 10 );
INSERT INTO movie_ratings VALUES( 1 , 'EvyDinesh' , 4 );
INSERT INTO movie_ratings VALUES( 19 , 'Arie50' , 8 );
INSERT INTO movie_ratings VALUES( 11 , 'Raj1' , 9 );
INSERT INTO movie_ratings VALUES( 42 , 'Enric8' , 3 );
INSERT INTO movie_ratings VALUES( 32 , 'Nereus3' , 3 );
INSERT INTO movie_ratings VALUES( 20 , 'Imogen29' , 10 );
INSERT INTO movie_ratings VALUES( 50 , 'Iracema' , 5 );
INSERT INTO movie_ratings VALUES( 26 , 'Tanja643' , 7 );
INSERT INTO movie_ratings VALUES( 36 , 'Ratnaq8' , 1 );
INSERT INTO movie_ratings VALUES( 12 , 'Dharma36' , 3 );
INSERT INTO movie_ratings VALUES( 21 , 'Kaija' , 5 );
INSERT INTO movie_ratings VALUES( 36 , 'Thancmar53' , 10 );
INSERT INTO movie_ratings VALUES( 4 , 'Valentin3' , 6 );
INSERT INTO movie_ratings VALUES( 40 , 'Sergius' , 7 );
INSERT INTO movie_ratings VALUES( 42 , 'Philippos2' , 4 );
INSERT INTO movie_ratings VALUES( 26 , 'Belshatzzar3' , 5 );
INSERT INTO movie_ratings VALUES( 37 , 'achana6' , 2 );
INSERT INTO movie_ratings VALUES( 20 , 'Wayna31' , 5 );
INSERT INTO movie_ratings VALUES( 1 , 'Enosh2' , 8 );
INSERT INTO movie_ratings VALUES( 15 , 'Govinda2' , 4 );
INSERT INTO movie_ratings VALUES( 26 , 'Jagdishyi' , 1 );
INSERT INTO movie_ratings VALUES( 4 , 'Reynard' , 7 );
INSERT INTO movie_ratings VALUES( 18 , 'Sabah7' , 6 );
INSERT INTO movie_ratings VALUES( 31 , 'Kadek78' , 1 );
INSERT INTO movie_ratings VALUES( 7 , 'Srinivas4368' , 2 );
INSERT INTO movie_ratings VALUES( 6 , 'Morpheus2' , 9 );
INSERT INTO movie_ratings VALUES( 15 , 'Murtada3' , 3 );
INSERT INTO movie_ratings VALUES( 7 , 'Ruaraidh' , 3 );
INSERT INTO movie_ratings VALUES( 3 , 'Shota34' , 8 );
INSERT INTO movie_ratings VALUES( 9 , 'Loke2' , 10 );
INSERT INTO movie_ratings VALUES( 33 , 'Drest36423' , 4 );
INSERT INTO movie_ratings VALUES( 4 , 'Silvia' , 4 );
INSERT INTO movie_ratings VALUES( 45 , 'Elon3' , 5 );
INSERT INTO movie_ratings VALUES( 30 , 'Tabatha' , 8 );
INSERT INTO movie_ratings VALUES( 8 , 'Michal42' , 9 );
INSERT INTO movie_ratings VALUES( 6 , 'Chiyembekezo' , 10 );
INSERT INTO movie_ratings VALUES( 23 , 'Dag' , 3 );
INSERT INTO movie_ratings VALUES( 37 , 'Arie' , 10 );
INSERT INTO movie_ratings VALUES( 30 , 'Fulgenzio5' , 10 );
INSERT INTO movie_ratings VALUES( 5 , 'Audhild2' , 6 );
INSERT INTO movie_ratings VALUES( 47 , 'Montana' , 1 );
INSERT INTO movie_ratings VALUES( 42 , 'Minos' , 4 );
INSERT INTO movie_ratings VALUES( 2 , 'Arnulf' , 5 );
INSERT INTO movie_ratings VALUES( 32 , 'Giselmund' , 3 );
INSERT INTO movie_ratings VALUES( 28 , 'Mercedes5456' , 6 );
INSERT INTO movie_ratings VALUES( 41 , 'Alban' , 9 );
INSERT INTO movie_ratings VALUES( 37 , 'Octavius' , 5 );
INSERT INTO movie_ratings VALUES( 7 , 'Aurelius4' , 10 );
INSERT INTO movie_ratings VALUES( 1 , 'Kip' , 5 );
INSERT INTO movie_ratings VALUES( 50 , 'EvyDinesh' , 3 );
INSERT INTO movie_ratings VALUES( 4 , 'Arie50' , 5 );
INSERT INTO movie_ratings VALUES( 40 , 'Raj1' , 1 );
INSERT INTO movie_ratings VALUES( 37 , 'Enric8' , 2 );
INSERT INTO movie_ratings VALUES( 43 , 'Nereus3' , 10 );
INSERT INTO movie_ratings VALUES( 24 , 'Imogen29' , 9 );
INSERT INTO movie_ratings VALUES( 4 , 'Iracema' , 1 );
INSERT INTO movie_ratings VALUES( 46 , 'Tanja643' , 8 );
INSERT INTO movie_ratings VALUES( 11 , 'Ratnaq8' , 4 );
INSERT INTO movie_ratings VALUES( 25 , 'Dharma36' , 6 );
INSERT INTO movie_ratings VALUES( 29 , 'Kaija' , 6 );
INSERT INTO movie_ratings VALUES( 4 , 'Thancmar53' , 1 );
INSERT INTO movie_ratings VALUES( 50 , 'Valentin3' , 4 );
INSERT INTO movie_ratings VALUES( 35 , 'Sergius' , 7 );
INSERT INTO movie_ratings VALUES( 34 , 'Philippos2' , 2 );
INSERT INTO movie_ratings VALUES( 2 , 'Belshatzzar3' , 6 );
INSERT INTO movie_ratings VALUES( 32 , 'Imogen29' , 8 , 'H' );
INSERT INTO movie_ratings VALUES( 33 , 'Imogen29' , 8 , 'H' );
INSERT INTO movie_ratings VALUES( 34 , 'Imogen29' , 9 , 'H' );
INSERT INTO movie_ratings VALUES( 35 , 'Imogen29' , 10 , 'H' );

--use
--while read line; do echo "INSERT INTO movie_ratings VALUES(" $((RANDOM % 50 + 1)) "," $line "," $((RANDOM % 10 + 1)) ");"; done < a 
--to generate more (a file with logins)

INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Noel' , 'Otto' , '1906-06-10' , 'United States');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Marcelle' , 'Zachariah' , '1906-08-06' , 'United Kingdom');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Candra' , 'Margurite' , '1911-02-05' , 'United States');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Patrice' , 'Serafina' , '1913-10-01' , 'Nigeria');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Carlotta' , 'Hershel' , '1917-01-16' , 'United Kingdom');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Brunhlia' , 'Viera' , '1974-11-10' , 'United Kingdom');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Ericka' , 'Flo' , '1975-05-22' , 'India');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Maurine' , 'Yvonne' , '1976-06-01' , 'Nigeria');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Lizzie' , 'Rowena' , '1976-10-28' , 'United States');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Kendra' , 'Tegan' , '1977-03-16' , 'India');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Barbar' , 'Alda' , '1978-02-21' , 'Nigeria');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Charissa' , 'Meda' , '1978-09-07' , 'United Kingdom');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Halley' , 'Markus' , '1985-04-18' , 'Nigeria');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Brian' , 'Ashley' , '1986-01-13' , 'United States');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Margret' , 'Scottie' , '1986-01-16' , 'United States');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Florance' , 'Irena' , '1986-02-05' , 'India');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Nona' , 'Janelle' , '1987-11-16' , 'India');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Hank' , 'Eldon' , '1991-11-12' , 'India');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Freda' , 'Myrtie' , '1993-01-21' , 'United States');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Malena' , 'Verda' , '1993-09-27' , 'United Kingdom');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Morton' , 'Bok' , '1996-03-08' , 'United Kingdom');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Erline' , 'Alina' , '1996-11-27' , 'Nigeria');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Solange' , 'Andre' , '1997-03-03' , 'Nigeria');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Shelley' , 'Elois' , '1998-04-06' , 'Nigeria');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Berna' , 'Damion' , '1998-08-29' , 'Nigeria');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Jani' , 'Claretha' , '2005-03-17' , 'Nigeria');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Phil' , 'Magnolia' , '2005-08-09' , 'Nigeria');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Claris' , 'Bill' , '2006-02-27' , 'United Kingdom');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Alise' , 'Sherwood' , '2006-12-14' , 'Nigeria');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Vita' , 'Regan' , '2008-10-15' , 'Nigeria');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'John' , 'Jayne' , '1917-10-21' , 'United Kingdom');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Jefferson' , 'Rachal' , '1932-04-23' , 'United Kingdom');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Latesha' , 'Salvador' , '1938-06-26' , 'United Kingdom');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Willis' , 'Roma' , '1939-08-18' , 'India');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Warren' , 'Salena' , '1944-03-31' , 'United States');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Rolande' , 'Lenita' , '1948-09-10' , 'United Kingdom');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Hermelinda' , 'Britt' , '1949-10-03' , 'United States');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Bertha' , 'Kathy' , '1950-10-09' , 'United States');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Jeremiah' , 'Sigrid' , '1953-08-15' , 'India');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Katy' , 'Alecia' , '1956-01-02' , 'United Kingdom');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Percy' , 'Kristopher' , '1956-07-24' , 'United Kingdom');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Markus' , 'Kristyn' , '1966-08-14' , 'United Kingdom');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Royce' , 'Willena' , '1968-09-12' , 'United States');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Fe' , 'Margarita' , '1968-12-30' , 'United States');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Billy' , 'Cornelia' , '1969-04-03' , 'Nigeria');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Garnet' , 'Stephanie' , '1972-07-31' , 'India');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Milagro' , 'Chas' , '1974-07-18' , 'Nigeria');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Yolanda' , 'Jackelyn' , '1974-08-08' , 'India');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Heidi' , 'Sherrell' , '1976-08-26' , 'United States');
INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES( 'Alida' , 'Hung' , '1990-07-31' , 'United Kingdom');


UPDATE people SET died = '2018-04-05' WHERE person_id =  1 ;
UPDATE people SET died = '2007-01-01' WHERE person_id =  2 ;
UPDATE people SET died = '2019-04-03' WHERE person_id =  3 ;
UPDATE people SET died = '2000-08-13' WHERE person_id =  4 ;
UPDATE people SET died = '1999-09-09' WHERE person_id =  5 ;


INSERT INTO profession VALUES( 44 , 'Director' );
INSERT INTO profession VALUES( 6 , 'Director' );
INSERT INTO profession VALUES( 17 , 'Director' );
INSERT INTO profession VALUES( 20 , 'Director' );
INSERT INTO profession VALUES( 12 , 'Director' );
INSERT INTO profession VALUES( 34 , 'Director' );
INSERT INTO profession VALUES( 24 , 'Director' );
INSERT INTO profession VALUES( 2 , 'Director' );
INSERT INTO profession VALUES( 27 , 'Director' );
INSERT INTO profession VALUES( 13 , 'Director' );
INSERT INTO profession VALUES( 3 , 'Director' );
INSERT INTO profession VALUES( 40 , 'Director' );

INSERT INTO profession VALUES( 39 , 'Actor' );
INSERT INTO profession VALUES( 49 , 'Actor' );
INSERT INTO profession VALUES( 20 , 'Actor' );
INSERT INTO profession VALUES( 23 , 'Actor' );
INSERT INTO profession VALUES( 7 , 'Actor' );
INSERT INTO profession VALUES( 11 , 'Actor' );
INSERT INTO profession VALUES( 28 , 'Actor' );
INSERT INTO profession VALUES( 1 , 'Actor' );
INSERT INTO profession VALUES( 24 , 'Actor' );
INSERT INTO profession VALUES( 15 , 'Actor' );
INSERT INTO profession VALUES( 43 , 'Actor' );
INSERT INTO profession VALUES( 45 , 'Actor' );
INSERT INTO profession VALUES( 8 , 'Actor' );
INSERT INTO profession VALUES( 16 , 'Actor' );
INSERT INTO profession VALUES( 6 , 'Actor' );
INSERT INTO profession VALUES( 34 , 'Actor' );

INSERT INTO profession VALUES( 45 , 'Editor' );
INSERT INTO profession VALUES( 20 , 'Editor' );
INSERT INTO profession VALUES( 16 , 'Editor' );
INSERT INTO profession VALUES( 6 , 'Editor' );
INSERT INTO profession VALUES( 27 , 'Editor' );
INSERT INTO profession VALUES( 19 , 'Editor' );
INSERT INTO profession VALUES( 18 , 'Editor' );
INSERT INTO profession VALUES( 48 , 'Editor' );
INSERT INTO profession VALUES( 22 , 'Editor' );
INSERT INTO profession VALUES( 28 , 'Editor' );
INSERT INTO profession VALUES( 13 , 'Editor' );
INSERT INTO profession VALUES( 1 , 'Editor' );

INSERT INTO profession VALUES( 40 , 'Producer' );
INSERT INTO profession VALUES( 32 , 'Producer' );
INSERT INTO profession VALUES( 39 , 'Producer' );
INSERT INTO profession VALUES( 33 , 'Producer' );
INSERT INTO profession VALUES( 48 , 'Producer' );
INSERT INTO profession VALUES( 12 , 'Producer' );
INSERT INTO profession VALUES( 49 , 'Producer' );
INSERT INTO profession VALUES( 22 , 'Producer' );
INSERT INTO profession VALUES( 29 , 'Producer' );
INSERT INTO profession VALUES( 11 , 'Producer' );
INSERT INTO profession VALUES( 42 , 'Producer' );
INSERT INTO profession VALUES( 30 , 'Producer' );
INSERT INTO profession VALUES( 10 , 'Producer' );
INSERT INTO profession VALUES( 23 , 'Producer' );

INSERT INTO profession VALUES( 28 , 'Composer' );
INSERT INTO profession VALUES( 8 , 'Composer' );
INSERT INTO profession VALUES( 24 , 'Composer' );
INSERT INTO profession VALUES( 50 , 'Composer' );

INSERT INTO profession VALUES( 5 , 'Writer' );
INSERT INTO profession VALUES( 24 , 'Writer' );
INSERT INTO profession VALUES( 13 , 'Writer' );
INSERT INTO profession VALUES( 19 , 'Writer' );
INSERT INTO profession VALUES( 48 , 'Writer' );
INSERT INTO profession VALUES( 39 , 'Writer' );
INSERT INTO profession VALUES( 11 , 'Writer' );
INSERT INTO profession VALUES( 35 , 'Writer' );
INSERT INTO profession VALUES( 8 , 'Writer' );
INSERT INTO profession VALUES( 10 , 'Writer' );

INSERT INTO profession VALUES( 41 , 'Angler' );
INSERT INTO profession VALUES( 35 , 'Angler' );
INSERT INTO profession VALUES( 20 , 'Angler' );

INSERT INTO crew VALUES( 34 , 1 , 'Director' );
INSERT INTO crew VALUES( 8 , 2 , 'Director' );
INSERT INTO crew VALUES( 1 , 3 , 'Director' );
INSERT INTO crew VALUES( 36 , 4 , 'Director' );
INSERT INTO crew VALUES( 4 , 5 , 'Director' );
INSERT INTO crew VALUES( 48 , 6 , 'Director' );
INSERT INTO crew VALUES( 31 , 7 , 'Director' );
INSERT INTO crew VALUES( 3 , 8 , 'Director' );
INSERT INTO crew VALUES( 45 , 9 , 'Director' );
INSERT INTO crew VALUES( 7 , 10 , 'Director' );
INSERT INTO crew VALUES( 4 , 11 , 'Director' );
INSERT INTO crew VALUES( 28 , 12 , 'Director' );
INSERT INTO crew VALUES( 19 , 13 , 'Director' );
INSERT INTO crew VALUES( 30 , 14 , 'Director' );
INSERT INTO crew VALUES( 2 , 15 , 'Director' );
INSERT INTO crew VALUES( 1 , 16 , 'Director' );
INSERT INTO crew VALUES( 15 , 17 , 'Director' );
INSERT INTO crew VALUES( 41 , 18 , 'Director' );
INSERT INTO crew VALUES( 9 , 19 , 'Director' );
INSERT INTO crew VALUES( 7 , 20 , 'Director' );
INSERT INTO crew VALUES( 47 , 21 , 'Director' );
INSERT INTO crew VALUES( 30 , 22 , 'Director' );
INSERT INTO crew VALUES( 48 , 23 , 'Director' );
INSERT INTO crew VALUES( 13 , 24 , 'Director' );
INSERT INTO crew VALUES( 16 , 25 , 'Director' );
INSERT INTO crew VALUES( 4 , 26 , 'Director' );
INSERT INTO crew VALUES( 48 , 27 , 'Director' );
INSERT INTO crew VALUES( 33 , 28 , 'Director' );
INSERT INTO crew VALUES( 25 , 29 , 'Director' );
INSERT INTO crew VALUES( 47 , 30 , 'Director' );
INSERT INTO crew VALUES( 1 , 31 , 'Director' );
INSERT INTO crew VALUES( 35 , 32 , 'Director' );
INSERT INTO crew VALUES( 18 , 33 , 'Director' );
INSERT INTO crew VALUES( 35 , 34 , 'Director' );
INSERT INTO crew VALUES( 43 , 35 , 'Director' );
INSERT INTO crew VALUES( 32 , 36 , 'Director' );
INSERT INTO crew VALUES( 13 , 37 , 'Director' );
INSERT INTO crew VALUES( 3 , 38 , 'Director' );
INSERT INTO crew VALUES( 36 , 39 , 'Director' );
INSERT INTO crew VALUES( 20 , 40 , 'Director' );
INSERT INTO crew VALUES( 23 , 41 , 'Director' );
INSERT INTO crew VALUES( 2 , 42 , 'Director' );
INSERT INTO crew VALUES( 39 , 43 , 'Director' );
INSERT INTO crew VALUES( 41 , 44 , 'Director' );
INSERT INTO crew VALUES( 45 , 45 , 'Director' );
INSERT INTO crew VALUES( 49 , 46 , 'Director' );
INSERT INTO crew VALUES( 18 , 47 , 'Director' );
INSERT INTO crew VALUES( 28 , 48 , 'Director' );
INSERT INTO crew VALUES( 31 , 49 , 'Director' );
INSERT INTO crew VALUES( 48 , 50 , 'Director' );

INSERT INTO crew VALUES( 9 , 1 , 'Editor' );
INSERT INTO crew VALUES( 5 , 2 , 'Editor' );
INSERT INTO crew VALUES( 47 , 3 , 'Editor' );
INSERT INTO crew VALUES( 36 , 4 , 'Editor' );
INSERT INTO crew VALUES( 3 , 5 , 'Editor' );
INSERT INTO crew VALUES( 39 , 6 , 'Editor' );
INSERT INTO crew VALUES( 30 , 7 , 'Editor' );
INSERT INTO crew VALUES( 39 , 8 , 'Editor' );
INSERT INTO crew VALUES( 25 , 9 , 'Editor' );
INSERT INTO crew VALUES( 7 , 10 , 'Editor' );
INSERT INTO crew VALUES( 12 , 11 , 'Editor' );
INSERT INTO crew VALUES( 42 , 12 , 'Editor' );
INSERT INTO crew VALUES( 40 , 13 , 'Editor' );
INSERT INTO crew VALUES( 19 , 14 , 'Editor' );
INSERT INTO crew VALUES( 13 , 15 , 'Editor' );
INSERT INTO crew VALUES( 17 , 16 , 'Editor' );
INSERT INTO crew VALUES( 31 , 17 , 'Editor' );
INSERT INTO crew VALUES( 27 , 18 , 'Editor' );
INSERT INTO crew VALUES( 20 , 19 , 'Editor' );
INSERT INTO crew VALUES( 20 , 20 , 'Editor' );
INSERT INTO crew VALUES( 31 , 21 , 'Editor' );
INSERT INTO crew VALUES( 6 , 22 , 'Editor' );
INSERT INTO crew VALUES( 13 , 23 , 'Editor' );
INSERT INTO crew VALUES( 4 , 24 , 'Editor' );
INSERT INTO crew VALUES( 46 , 25 , 'Editor' );
INSERT INTO crew VALUES( 3 , 26 , 'Editor' );
INSERT INTO crew VALUES( 42 , 27 , 'Editor' );
INSERT INTO crew VALUES( 33 , 28 , 'Editor' );
INSERT INTO crew VALUES( 7 , 29 , 'Editor' );
INSERT INTO crew VALUES( 39 , 30 , 'Editor' );
INSERT INTO crew VALUES( 19 , 31 , 'Editor' );
INSERT INTO crew VALUES( 41 , 32 , 'Editor' );
INSERT INTO crew VALUES( 44 , 33 , 'Editor' );
INSERT INTO crew VALUES( 8 , 34 , 'Editor' );
INSERT INTO crew VALUES( 14 , 35 , 'Editor' );
INSERT INTO crew VALUES( 25 , 36 , 'Editor' );
INSERT INTO crew VALUES( 2 , 37 , 'Editor' );
INSERT INTO crew VALUES( 31 , 38 , 'Editor' );
INSERT INTO crew VALUES( 11 , 39 , 'Editor' );
INSERT INTO crew VALUES( 18 , 40 , 'Editor' );
INSERT INTO crew VALUES( 40 , 41 , 'Editor' );
INSERT INTO crew VALUES( 44 , 42 , 'Editor' );
INSERT INTO crew VALUES( 42 , 43 , 'Editor' );
INSERT INTO crew VALUES( 32 , 44 , 'Editor' );
INSERT INTO crew VALUES( 29 , 45 , 'Editor' );
INSERT INTO crew VALUES( 30 , 46 , 'Editor' );
INSERT INTO crew VALUES( 24 , 47 , 'Editor' );
INSERT INTO crew VALUES( 6 , 48 , 'Editor' );
INSERT INTO crew VALUES( 8 , 49 , 'Editor' );
INSERT INTO crew VALUES( 38 , 50 , 'Editor' );

INSERT INTO crew VALUES( 20 , 1 , 'Writer' );
INSERT INTO crew VALUES( 2 , 2 , 'Writer' );
INSERT INTO crew VALUES( 32 , 3 , 'Writer' );
INSERT INTO crew VALUES( 44 , 4 , 'Writer' );
INSERT INTO crew VALUES( 3 , 5 , 'Writer' );
INSERT INTO crew VALUES( 45 , 6 , 'Writer' );
INSERT INTO crew VALUES( 16 , 7 , 'Writer' );
INSERT INTO crew VALUES( 16 , 8 , 'Writer' );
INSERT INTO crew VALUES( 14 , 9 , 'Writer' );
INSERT INTO crew VALUES( 37 , 10 , 'Writer' );
INSERT INTO crew VALUES( 16 , 11 , 'Writer' );
INSERT INTO crew VALUES( 5 , 12 , 'Writer' );
INSERT INTO crew VALUES( 23 , 13 , 'Writer' );
INSERT INTO crew VALUES( 9 , 14 , 'Writer' );
INSERT INTO crew VALUES( 32 , 15 , 'Writer' );
INSERT INTO crew VALUES( 46 , 16 , 'Writer' );
INSERT INTO crew VALUES( 48 , 17 , 'Writer' );
INSERT INTO crew VALUES( 33 , 18 , 'Writer' );
INSERT INTO crew VALUES( 48 , 19 , 'Writer' );
INSERT INTO crew VALUES( 14 , 20 , 'Writer' );
INSERT INTO crew VALUES( 26 , 21 , 'Writer' );
INSERT INTO crew VALUES( 20 , 22 , 'Writer' );
INSERT INTO crew VALUES( 48 , 23 , 'Writer' );
INSERT INTO crew VALUES( 14 , 24 , 'Writer' );
INSERT INTO crew VALUES( 1 , 25 , 'Writer' );
INSERT INTO crew VALUES( 4 , 26 , 'Writer' );
INSERT INTO crew VALUES( 26 , 27 , 'Writer' );
INSERT INTO crew VALUES( 18 , 28 , 'Writer' );
INSERT INTO crew VALUES( 40 , 29 , 'Writer' );
INSERT INTO crew VALUES( 44 , 30 , 'Writer' );
INSERT INTO crew VALUES( 41 , 31 , 'Writer' );
INSERT INTO crew VALUES( 16 , 32 , 'Writer' );
INSERT INTO crew VALUES( 19 , 33 , 'Writer' );
INSERT INTO crew VALUES( 47 , 34 , 'Writer' );
INSERT INTO crew VALUES( 25 , 35 , 'Writer' );
INSERT INTO crew VALUES( 14 , 36 , 'Writer' );
INSERT INTO crew VALUES( 36 , 37 , 'Writer' );
INSERT INTO crew VALUES( 40 , 38 , 'Writer' );
INSERT INTO crew VALUES( 29 , 39 , 'Writer' );
INSERT INTO crew VALUES( 41 , 40 , 'Writer' );
INSERT INTO crew VALUES( 1 , 41 , 'Writer' );
INSERT INTO crew VALUES( 23 , 42 , 'Writer' );
INSERT INTO crew VALUES( 50 , 43 , 'Writer' );
INSERT INTO crew VALUES( 33 , 44 , 'Writer' );
INSERT INTO crew VALUES( 11 , 45 , 'Writer' );
INSERT INTO crew VALUES( 43 , 46 , 'Writer' );
INSERT INTO crew VALUES( 45 , 47 , 'Writer' );
INSERT INTO crew VALUES( 32 , 48 , 'Writer' );
INSERT INTO crew VALUES( 11 , 49 , 'Writer' );
INSERT INTO crew VALUES( 41 , 50 , 'Writer' );

INSERT INTO crew VALUES( 19 , 1 , 'Music' );
INSERT INTO crew VALUES( 40 , 2 , 'Music' );
INSERT INTO crew VALUES( 43 , 3 , 'Music' );
INSERT INTO crew VALUES( 42 , 4 , 'Music' );
INSERT INTO crew VALUES( 2 , 5 , 'Music' );
INSERT INTO crew VALUES( 30 , 6 , 'Music' );
INSERT INTO crew VALUES( 14 , 7 , 'Music' );
INSERT INTO crew VALUES( 43 , 8 , 'Music' );
INSERT INTO crew VALUES( 16 , 9 , 'Music' );
INSERT INTO crew VALUES( 38 , 10 , 'Music' );
INSERT INTO crew VALUES( 46 , 11 , 'Music' );
INSERT INTO crew VALUES( 33 , 12 , 'Music' );
INSERT INTO crew VALUES( 21 , 13 , 'Music' );
INSERT INTO crew VALUES( 40 , 14 , 'Music' );
INSERT INTO crew VALUES( 36 , 15 , 'Music' );
INSERT INTO crew VALUES( 19 , 16 , 'Music' );
INSERT INTO crew VALUES( 9 , 17 , 'Music' );
INSERT INTO crew VALUES( 38 , 18 , 'Music' );
INSERT INTO crew VALUES( 9 , 19 , 'Music' );
INSERT INTO crew VALUES( 32 , 20 , 'Music' );
INSERT INTO crew VALUES( 23 , 21 , 'Music' );
INSERT INTO crew VALUES( 45 , 22 , 'Music' );
INSERT INTO crew VALUES( 27 , 23 , 'Music' );
INSERT INTO crew VALUES( 14 , 24 , 'Music' );
INSERT INTO crew VALUES( 22 , 25 , 'Music' );
INSERT INTO crew VALUES( 5 , 26 , 'Music' );
INSERT INTO crew VALUES( 47 , 27 , 'Music' );
INSERT INTO crew VALUES( 50 , 28 , 'Music' );
INSERT INTO crew VALUES( 38 , 29 , 'Music' );
INSERT INTO crew VALUES( 8 , 30 , 'Music' );
INSERT INTO crew VALUES( 34 , 31 , 'Music' );
INSERT INTO crew VALUES( 2 , 32 , 'Music' );
INSERT INTO crew VALUES( 35 , 33 , 'Music' );
INSERT INTO crew VALUES( 20 , 34 , 'Music' );
INSERT INTO crew VALUES( 42 , 35 , 'Music' );
INSERT INTO crew VALUES( 32 , 36 , 'Music' );
INSERT INTO crew VALUES( 15 , 37 , 'Music' );
INSERT INTO crew VALUES( 32 , 38 , 'Music' );
INSERT INTO crew VALUES( 42 , 39 , 'Music' );
INSERT INTO crew VALUES( 30 , 40 , 'Music' );
INSERT INTO crew VALUES( 16 , 41 , 'Music' );
INSERT INTO crew VALUES( 26 , 42 , 'Music' );
INSERT INTO crew VALUES( 26 , 43 , 'Music' );
INSERT INTO crew VALUES( 33 , 44 , 'Music' );
INSERT INTO crew VALUES( 34 , 45 , 'Music' );
INSERT INTO crew VALUES( 1 , 46 , 'Music' );
INSERT INTO crew VALUES( 42 , 47 , 'Music' );
INSERT INTO crew VALUES( 29 , 48 , 'Music' );
INSERT INTO crew VALUES( 46 , 49 , 'Music' );
INSERT INTO crew VALUES( 5 , 50 , 'Music' );

INSERT INTO crew VALUES( 11 , 1 , 'Cameraworker' );
INSERT INTO crew VALUES( 35 , 2 , 'Cameraworker' );
INSERT INTO crew VALUES( 15 , 3 , 'Cameraworker' );
INSERT INTO crew VALUES( 11 , 4 , 'Cameraworker' );
INSERT INTO crew VALUES( 26 , 5 , 'Cameraworker' );
INSERT INTO crew VALUES( 38 , 6 , 'Cameraworker' );
INSERT INTO crew VALUES( 3 , 7 , 'Cameraworker' );
INSERT INTO crew VALUES( 4 , 8 , 'Cameraworker' );
INSERT INTO crew VALUES( 10 , 9 , 'Cameraworker' );
INSERT INTO crew VALUES( 17 , 10 , 'Cameraworker' );
INSERT INTO crew VALUES( 35 , 11 , 'Cameraworker' );
INSERT INTO crew VALUES( 44 , 12 , 'Cameraworker' );
INSERT INTO crew VALUES( 34 , 13 , 'Cameraworker' );
INSERT INTO crew VALUES( 34 , 14 , 'Cameraworker' );
INSERT INTO crew VALUES( 12 , 15 , 'Cameraworker' );
INSERT INTO crew VALUES( 32 , 16 , 'Cameraworker' );
INSERT INTO crew VALUES( 29 , 17 , 'Cameraworker' );
INSERT INTO crew VALUES( 47 , 18 , 'Cameraworker' );
INSERT INTO crew VALUES( 7 , 19 , 'Cameraworker' );
INSERT INTO crew VALUES( 26 , 20 , 'Cameraworker' );
INSERT INTO crew VALUES( 30 , 21 , 'Cameraworker' );
INSERT INTO crew VALUES( 31 , 22 , 'Cameraworker' );
INSERT INTO crew VALUES( 1 , 23 , 'Cameraworker' );
INSERT INTO crew VALUES( 8 , 24 , 'Cameraworker' );
INSERT INTO crew VALUES( 6 , 25 , 'Cameraworker' );
INSERT INTO crew VALUES( 33 , 26 , 'Cameraworker' );
INSERT INTO crew VALUES( 15 , 27 , 'Cameraworker' );
INSERT INTO crew VALUES( 29 , 28 , 'Cameraworker' );
INSERT INTO crew VALUES( 45 , 29 , 'Cameraworker' );
INSERT INTO crew VALUES( 3 , 30 , 'Cameraworker' );
INSERT INTO crew VALUES( 35 , 31 , 'Cameraworker' );
INSERT INTO crew VALUES( 29 , 32 , 'Cameraworker' );
INSERT INTO crew VALUES( 2 , 33 , 'Cameraworker' );
INSERT INTO crew VALUES( 40 , 34 , 'Cameraworker' );
INSERT INTO crew VALUES( 25 , 35 , 'Cameraworker' );
INSERT INTO crew VALUES( 34 , 36 , 'Cameraworker' );
INSERT INTO crew VALUES( 9 , 37 , 'Cameraworker' );
INSERT INTO crew VALUES( 49 , 38 , 'Cameraworker' );
INSERT INTO crew VALUES( 41 , 39 , 'Cameraworker' );
INSERT INTO crew VALUES( 35 , 40 , 'Cameraworker' );
INSERT INTO crew VALUES( 11 , 41 , 'Cameraworker' );
INSERT INTO crew VALUES( 18 , 42 , 'Cameraworker' );
INSERT INTO crew VALUES( 44 , 43 , 'Cameraworker' );
INSERT INTO crew VALUES( 25 , 44 , 'Cameraworker' );
INSERT INTO crew VALUES( 50 , 45 , 'Cameraworker' );
INSERT INTO crew VALUES( 11 , 46 , 'Cameraworker' );
INSERT INTO crew VALUES( 20 , 47 , 'Cameraworker' );
INSERT INTO crew VALUES( 7 , 48 , 'Cameraworker' );
INSERT INTO crew VALUES( 28 , 49 , 'Cameraworker' );
INSERT INTO crew VALUES( 50 , 50 , 'Cameraworker' );

INSERT INTO crew VALUES( 27 , 1 , 'Actor' , 'Jan');
INSERT INTO crew VALUES( 3 , 2 , 'Actor' , 'John');
INSERT INTO crew VALUES( 23 , 3 , 'Actor' , 'Hans');
INSERT INTO crew VALUES( 1 , 4 , 'Actor' , 'Elon Musk');
INSERT INTO crew VALUES( 24 , 5 , 'Actor' , 'Tree');
INSERT INTO crew VALUES( 39 , 6 , 'Actor' , 'Someone important');
INSERT INTO crew VALUES( 1 , 7 , 'Actor' , 'Not important');
INSERT INTO crew VALUES( 24 , 8 , 'Actor' , 'Main character');
INSERT INTO crew VALUES( 41 , 9 , 'Actor' );
INSERT INTO crew VALUES( 36 , 10 , 'Actor' );
INSERT INTO crew VALUES( 22 , 11 , 'Actor' );
INSERT INTO crew VALUES( 37 , 12 , 'Actor' );
INSERT INTO crew VALUES( 28 , 13 , 'Actor' );
INSERT INTO crew VALUES( 15 , 14 , 'Actor' );
INSERT INTO crew VALUES( 30 , 15 , 'Actor' );
INSERT INTO crew VALUES( 31 , 16 , 'Actor' );
INSERT INTO crew VALUES( 38 , 17 , 'Actor' );
INSERT INTO crew VALUES( 30 , 18 , 'Actor' );
INSERT INTO crew VALUES( 50 , 19 , 'Actor' );
INSERT INTO crew VALUES( 36 , 20 , 'Actor' );
INSERT INTO crew VALUES( 43 , 21 , 'Actor' );
INSERT INTO crew VALUES( 49 , 22 , 'Actor' );
INSERT INTO crew VALUES( 30 , 23 , 'Actor' );
INSERT INTO crew VALUES( 4 , 24 , 'Actor' );
INSERT INTO crew VALUES( 8 , 25 , 'Actor' );
INSERT INTO crew VALUES( 16 , 26 , 'Actor' );
INSERT INTO crew VALUES( 22 , 27 , 'Actor' );
INSERT INTO crew VALUES( 27 , 28 , 'Actor' );
INSERT INTO crew VALUES( 30 , 29 , 'Actor' );
INSERT INTO crew VALUES( 36 , 30 , 'Actor' );
INSERT INTO crew VALUES( 43 , 31 , 'Actor' );
INSERT INTO crew VALUES( 34 , 32 , 'Actor' );
INSERT INTO crew VALUES( 22 , 33 , 'Actor' );
INSERT INTO crew VALUES( 21 , 34 , 'Actor' );
INSERT INTO crew VALUES( 9 , 35 , 'Actor' );
INSERT INTO crew VALUES( 35 , 36 , 'Actor' );
INSERT INTO crew VALUES( 30 , 37 , 'Actor' );
INSERT INTO crew VALUES( 11 , 38 , 'Actor' );
INSERT INTO crew VALUES( 40 , 39 , 'Actor' );
INSERT INTO crew VALUES( 41 , 40 , 'Actor' );
INSERT INTO crew VALUES( 27 , 41 , 'Actor' );
INSERT INTO crew VALUES( 11 , 42 , 'Actor' );
INSERT INTO crew VALUES( 48 , 43 , 'Actor' );
INSERT INTO crew VALUES( 19 , 44 , 'Actor' );
INSERT INTO crew VALUES( 33 , 45 , 'Actor' );
INSERT INTO crew VALUES( 40 , 46 , 'Actor' );
INSERT INTO crew VALUES( 17 , 47 , 'Actor' );
INSERT INTO crew VALUES( 40 , 48 , 'Actor' );
INSERT INTO crew VALUES( 37 , 49 , 'Actor' );
INSERT INTO crew VALUES( 44 , 50 , 'Actor' );
INSERT INTO crew VALUES( 18 , 1 , 'Actor' );
INSERT INTO crew VALUES( 34 , 2 , 'Actor' );
INSERT INTO crew VALUES( 32 , 3 , 'Actor' );
INSERT INTO crew VALUES( 49 , 4 , 'Actor' );
INSERT INTO crew VALUES( 19 , 5 , 'Actor' );
INSERT INTO crew VALUES( 30 , 6 , 'Actor' );
INSERT INTO crew VALUES( 22 , 7 , 'Actor' );
INSERT INTO crew VALUES( 44 , 8 , 'Actor' );
INSERT INTO crew VALUES( 14 , 9 , 'Actor' );
INSERT INTO crew VALUES( 19 , 10 , 'Actor' );
INSERT INTO crew VALUES( 13 , 11 , 'Actor' );
INSERT INTO crew VALUES( 26 , 12 , 'Actor' );
INSERT INTO crew VALUES( 47 , 13 , 'Actor' );
INSERT INTO crew VALUES( 9 , 14 , 'Actor' );
INSERT INTO crew VALUES( 17 , 15 , 'Actor' );
INSERT INTO crew VALUES( 23 , 16 , 'Actor' );
INSERT INTO crew VALUES( 5 , 17 , 'Actor' );
INSERT INTO crew VALUES( 34 , 18 , 'Actor' );
INSERT INTO crew VALUES( 8 , 19 , 'Actor' );
INSERT INTO crew VALUES( 8 , 20 , 'Actor' );
INSERT INTO crew VALUES( 19 , 21 , 'Actor' );
INSERT INTO crew VALUES( 32 , 22 , 'Actor' );
INSERT INTO crew VALUES( 13 , 23 , 'Actor' );
INSERT INTO crew VALUES( 50 , 24 , 'Actor' );
INSERT INTO crew VALUES( 50 , 25 , 'Actor' );
INSERT INTO crew VALUES( 7 , 26 , 'Actor' );
INSERT INTO crew VALUES( 21 , 27 , 'Actor' );
INSERT INTO crew VALUES( 43 , 28 , 'Actor' );
INSERT INTO crew VALUES( 2 , 29 , 'Actor' );
INSERT INTO crew VALUES( 16 , 30 , 'Actor' );
INSERT INTO crew VALUES( 14 , 31 , 'Actor' );
INSERT INTO crew VALUES( 6 , 32 , 'Actor' );
INSERT INTO crew VALUES( 42 , 33 , 'Actor' );
INSERT INTO crew VALUES( 23 , 34 , 'Actor' );
INSERT INTO crew VALUES( 45 , 35 , 'Actor' );
INSERT INTO crew VALUES( 18 , 36 , 'Actor' );
INSERT INTO crew VALUES( 13 , 37 , 'Actor' );
INSERT INTO crew VALUES( 12 , 38 , 'Actor' );
INSERT INTO crew VALUES( 17 , 39 , 'Actor' );
INSERT INTO crew VALUES( 30 , 40 , 'Actor' );
INSERT INTO crew VALUES( 12 , 41 , 'Actor' );
INSERT INTO crew VALUES( 17 , 42 , 'Actor' );
INSERT INTO crew VALUES( 34 , 43 , 'Actor' );
INSERT INTO crew VALUES( 14 , 44 , 'Actor' );
INSERT INTO crew VALUES( 16 , 45 , 'Actor' );
INSERT INTO crew VALUES( 26 , 46 , 'Actor' );
INSERT INTO crew VALUES( 34 , 47 , 'Actor' );
INSERT INTO crew VALUES( 45 , 48 , 'Actor' );
INSERT INTO crew VALUES( 1 , 49 , 'Actor' );
INSERT INTO crew VALUES( 16 , 50 , 'Actor' );

INSERT INTO crew VALUES( 23 , 1 , 'Others' );
INSERT INTO crew VALUES( 16 , 2 , 'Others' );
INSERT INTO crew VALUES( 7 , 3 , 'Others' );
INSERT INTO crew VALUES( 1 , 4 , 'Others' );
INSERT INTO crew VALUES( 26 , 5 , 'Others' );
INSERT INTO crew VALUES( 6 , 6 , 'Others' );
INSERT INTO crew VALUES( 15 , 7 , 'Others' );
INSERT INTO crew VALUES( 5 , 8 , 'Others' );
INSERT INTO crew VALUES( 25 , 9 , 'Others' );
INSERT INTO crew VALUES( 3 , 10 , 'Others' );
INSERT INTO crew VALUES( 30 , 11 , 'Others' );
INSERT INTO crew VALUES( 40 , 12 , 'Others' );
INSERT INTO crew VALUES( 35 , 13 , 'Others' );
INSERT INTO crew VALUES( 26 , 14 , 'Others' );
INSERT INTO crew VALUES( 48 , 15 , 'Others' );
INSERT INTO crew VALUES( 30 , 16 , 'Others' );
INSERT INTO crew VALUES( 10 , 17 , 'Others' );
INSERT INTO crew VALUES( 15 , 18 , 'Others' );
INSERT INTO crew VALUES( 50 , 19 , 'Others' );
INSERT INTO crew VALUES( 10 , 20 , 'Others' );
INSERT INTO crew VALUES( 2 , 21 , 'Others' );
INSERT INTO crew VALUES( 23 , 22 , 'Others' );
INSERT INTO crew VALUES( 1 , 23 , 'Others' );
INSERT INTO crew VALUES( 26 , 24 , 'Others' );
INSERT INTO crew VALUES( 33 , 25 , 'Others' );
INSERT INTO crew VALUES( 50 , 26 , 'Others' );
INSERT INTO crew VALUES( 21 , 27 , 'Others' );
INSERT INTO crew VALUES( 2 , 28 , 'Others' );
INSERT INTO crew VALUES( 40 , 29 , 'Others' );
INSERT INTO crew VALUES( 4 , 30 , 'Others' );
INSERT INTO crew VALUES( 42 , 31 , 'Others' );
INSERT INTO crew VALUES( 49 , 32 , 'Others' );
INSERT INTO crew VALUES( 24 , 33 , 'Others' );
INSERT INTO crew VALUES( 27 , 34 , 'Others' );
INSERT INTO crew VALUES( 17 , 35 , 'Others' );
INSERT INTO crew VALUES( 1 , 36 , 'Others' );
INSERT INTO crew VALUES( 30 , 37 , 'Others' );
INSERT INTO crew VALUES( 39 , 38 , 'Others' );
INSERT INTO crew VALUES( 24 , 39 , 'Others' );
INSERT INTO crew VALUES( 27 , 40 , 'Others' );
INSERT INTO crew VALUES( 49 , 41 , 'Others' );
INSERT INTO crew VALUES( 48 , 42 , 'Others' );
INSERT INTO crew VALUES( 47 , 43 , 'Others' );
INSERT INTO crew VALUES( 37 , 44 , 'Others' );
INSERT INTO crew VALUES( 7 , 45 , 'Others' );
INSERT INTO crew VALUES( 11 , 46 , 'Others' );
INSERT INTO crew VALUES( 33 , 47 , 'Others' );
INSERT INTO crew VALUES( 25 , 48 , 'Others' );
INSERT INTO crew VALUES( 4 , 49 , 'Others' );
INSERT INTO crew VALUES( 39 , 50 , 'Others' );
INSERT INTO crew VALUES( 44 , 1 , 'Others' );
INSERT INTO crew VALUES( 32 , 2 , 'Others' );
INSERT INTO crew VALUES( 26 , 3 , 'Others' );
INSERT INTO crew VALUES( 15 , 4 , 'Others' );
INSERT INTO crew VALUES( 26 , 5 , 'Others' );
INSERT INTO crew VALUES( 14 , 6 , 'Others' );
INSERT INTO crew VALUES( 31 , 7 , 'Others' );
INSERT INTO crew VALUES( 15 , 8 , 'Others' );
INSERT INTO crew VALUES( 38 , 9 , 'Others' );
INSERT INTO crew VALUES( 30 , 10 , 'Others' );
INSERT INTO crew VALUES( 14 , 11 , 'Others' );
INSERT INTO crew VALUES( 26 , 12 , 'Others' );
INSERT INTO crew VALUES( 32 , 13 , 'Others' );
INSERT INTO crew VALUES( 25 , 14 , 'Others' );
INSERT INTO crew VALUES( 22 , 15 , 'Others' );
INSERT INTO crew VALUES( 49 , 16 , 'Others' );
INSERT INTO crew VALUES( 10 , 17 , 'Others' );
INSERT INTO crew VALUES( 47 , 18 , 'Others' );
INSERT INTO crew VALUES( 21 , 19 , 'Others' );
INSERT INTO crew VALUES( 15 , 20 , 'Others' );
INSERT INTO crew VALUES( 32 , 21 , 'Others' );
INSERT INTO crew VALUES( 26 , 22 , 'Others' );
INSERT INTO crew VALUES( 5 , 23 , 'Others' );
INSERT INTO crew VALUES( 1 , 24 , 'Others' );
INSERT INTO crew VALUES( 31 , 25 , 'Others' );
INSERT INTO crew VALUES( 44 , 26 , 'Others' );
INSERT INTO crew VALUES( 27 , 27 , 'Others' );
INSERT INTO crew VALUES( 10 , 28 , 'Others' );
INSERT INTO crew VALUES( 9 , 29 , 'Others' );
INSERT INTO crew VALUES( 50 , 30 , 'Others' );
INSERT INTO crew VALUES( 12 , 31 , 'Others' );
INSERT INTO crew VALUES( 7 , 32 , 'Others' );
INSERT INTO crew VALUES( 8 , 33 , 'Others' );
INSERT INTO crew VALUES( 39 , 34 , 'Others' );
INSERT INTO crew VALUES( 27 , 35 , 'Others' );
INSERT INTO crew VALUES( 29 , 36 , 'Others' );
INSERT INTO crew VALUES( 25 , 37 , 'Others' );
INSERT INTO crew VALUES( 18 , 38 , 'Others' );
INSERT INTO crew VALUES( 27 , 39 , 'Others' );
INSERT INTO crew VALUES( 34 , 40 , 'Others' );
INSERT INTO crew VALUES( 32 , 41 , 'Others' );
INSERT INTO crew VALUES( 4 , 42 , 'Others' );
INSERT INTO crew VALUES( 25 , 43 , 'Others' );
INSERT INTO crew VALUES( 41 , 44 , 'Others' );
INSERT INTO crew VALUES( 39 , 45 , 'Others' );
INSERT INTO crew VALUES( 23 , 46 , 'Others' );
INSERT INTO crew VALUES( 27 , 47 , 'Others' );
INSERT INTO crew VALUES( 24 , 48 , 'Others' );
INSERT INTO crew VALUES( 16 , 49 , 'Others' );
INSERT INTO crew VALUES( 39 , 50 , 'Others' );

INSERT INTO person_ratings VALUES( 27 , 'achana6' , 7 );
INSERT INTO person_ratings VALUES( 34 , 'Wayna31' , 6 );
INSERT INTO person_ratings VALUES( 16 , 'Enosh2' , 1 );
INSERT INTO person_ratings VALUES( 10 , 'Govinda2' , 5 );
INSERT INTO person_ratings VALUES( 35 , 'Jagdishyi' , 6 );
INSERT INTO person_ratings VALUES( 26 , 'Reynard' , 3 );
INSERT INTO person_ratings VALUES( 40 , 'Sabah7' , 5 );
INSERT INTO person_ratings VALUES( 20 , 'Sinta5' , 10 );
INSERT INTO person_ratings VALUES( 34 , 'Kadek78' , 4 );
INSERT INTO person_ratings VALUES( 43 , 'Srinivas4368' , 5 );
INSERT INTO person_ratings VALUES( 39 , 'Morpheus2' , 7 );
INSERT INTO person_ratings VALUES( 40 , 'Murtada3' , 1 );
INSERT INTO person_ratings VALUES( 45 , 'Ruaraidh' , 4 );
INSERT INTO person_ratings VALUES( 31 , 'Shota34' , 3 );
INSERT INTO person_ratings VALUES( 5 , 'Loke2' , 10 );
INSERT INTO person_ratings VALUES( 14 , 'Drest36423' , 3 );
INSERT INTO person_ratings VALUES( 33 , 'Silvia' , 10 );
INSERT INTO person_ratings VALUES( 35 , 'Elon3' , 1 );
INSERT INTO person_ratings VALUES( 36 , 'Tabatha' , 2 );
INSERT INTO person_ratings VALUES( 15 , 'Michal42' , 6 );
INSERT INTO person_ratings VALUES( 41 , 'Chiyembekezo' , 3 );
INSERT INTO person_ratings VALUES( 27 , 'Dag' , 9 );
INSERT INTO person_ratings VALUES( 32 , 'Arie' , 5 );
INSERT INTO person_ratings VALUES( 8 , 'Fulgenzio5' , 2 );
INSERT INTO person_ratings VALUES( 46 , 'Audhild2' , 1 );
INSERT INTO person_ratings VALUES( 13 , 'Montana' , 10 );
INSERT INTO person_ratings VALUES( 36 , 'Minos' , 10 );
INSERT INTO person_ratings VALUES( 45 , 'Arnulf' , 3 );
INSERT INTO person_ratings VALUES( 48 , 'Giselmund' , 3 );
INSERT INTO person_ratings VALUES( 28 , 'Mercedes5456' , 7 );
INSERT INTO person_ratings VALUES( 41 , 'Alban' , 4 );
INSERT INTO person_ratings VALUES( 6 , 'Octavius' , 9 );
INSERT INTO person_ratings VALUES( 35 , 'Aurelius4' , 8 );
INSERT INTO person_ratings VALUES( 50 , 'Kip' , 1 );
INSERT INTO person_ratings VALUES( 31 , 'EvyDinesh' , 1 );
INSERT INTO person_ratings VALUES( 2 , 'Arie50' , 10 );
INSERT INTO person_ratings VALUES( 38 , 'Raj1' , 5 );
INSERT INTO person_ratings VALUES( 18 , 'Enric8' , 5 );
INSERT INTO person_ratings VALUES( 32 , 'Nereus3' , 3 );
INSERT INTO person_ratings VALUES( 1 , 'Imogen29' , 1 );
INSERT INTO person_ratings VALUES( 44 , 'Iracema' , 1 );
INSERT INTO person_ratings VALUES( 32 , 'Tanja643' , 6 );
INSERT INTO person_ratings VALUES( 11 , 'Ratnaq8' , 5 );
INSERT INTO person_ratings VALUES( 46 , 'Dharma36' , 7 );
INSERT INTO person_ratings VALUES( 24 , 'Kaija' , 3 );
INSERT INTO person_ratings VALUES( 16 , 'Thancmar53' , 8 );
INSERT INTO person_ratings VALUES( 9 , 'Valentin3' , 4 );
INSERT INTO person_ratings VALUES( 38 , 'Sergius' , 5 );
INSERT INTO person_ratings VALUES( 42 , 'Philippos2' , 6 );
INSERT INTO person_ratings VALUES( 44 , 'Belshatzzar3' , 2 );
INSERT INTO person_ratings VALUES( 1 , 'achana6' , 7 );
INSERT INTO person_ratings VALUES( 18 , 'Wayna31' , 1 );
INSERT INTO person_ratings VALUES( 46 , 'Enosh2' , 6 );
INSERT INTO person_ratings VALUES( 26 , 'Govinda2' , 8 );
INSERT INTO person_ratings VALUES( 26 , 'Jagdishyi' , 8 );
INSERT INTO person_ratings VALUES( 25 , 'Reynard' , 10 );
INSERT INTO person_ratings VALUES( 27 , 'Sabah7' , 2 );
INSERT INTO person_ratings VALUES( 42 , 'Sinta5' , 6 );
INSERT INTO person_ratings VALUES( 35 , 'Kadek78' , 4 );
INSERT INTO person_ratings VALUES( 3 , 'Srinivas4368' , 2 );
INSERT INTO person_ratings VALUES( 22 , 'Morpheus2' , 8 );
INSERT INTO person_ratings VALUES( 1 , 'Murtada3' , 4 );
INSERT INTO person_ratings VALUES( 14 , 'Ruaraidh' , 8 );
INSERT INTO person_ratings VALUES( 40 , 'Shota34' , 10 );
INSERT INTO person_ratings VALUES( 23 , 'Loke2' , 3 );
INSERT INTO person_ratings VALUES( 2 , 'Drest36423' , 9 );
INSERT INTO person_ratings VALUES( 11 , 'Silvia' , 1 );
INSERT INTO person_ratings VALUES( 25 , 'Elon3' , 10 );
INSERT INTO person_ratings VALUES( 35 , 'Tabatha' , 3 );
INSERT INTO person_ratings VALUES( 5 , 'Michal42' , 2 );
INSERT INTO person_ratings VALUES( 15 , 'Chiyembekezo' , 9 );
INSERT INTO person_ratings VALUES( 28 , 'Dag' , 8 );
INSERT INTO person_ratings VALUES( 43 , 'Arie' , 10 );
INSERT INTO person_ratings VALUES( 34 , 'Fulgenzio5' , 8 );
INSERT INTO person_ratings VALUES( 22 , 'Audhild2' , 8 );
INSERT INTO person_ratings VALUES( 28 , 'Montana' , 3 );
INSERT INTO person_ratings VALUES( 49 , 'Minos' , 9 );
INSERT INTO person_ratings VALUES( 41 , 'Arnulf' , 9 );
INSERT INTO person_ratings VALUES( 13 , 'Giselmund' , 5 );
INSERT INTO person_ratings VALUES( 4 , 'Mercedes5456' , 7 );
INSERT INTO person_ratings VALUES( 22 , 'Alban' , 2 );
INSERT INTO person_ratings VALUES( 48 , 'Octavius' , 6 );
INSERT INTO person_ratings VALUES( 30 , 'Aurelius4' , 6 );
INSERT INTO person_ratings VALUES( 42 , 'Kip' , 9 );
INSERT INTO person_ratings VALUES( 13 , 'EvyDinesh' , 3 );
INSERT INTO person_ratings VALUES( 42 , 'Arie50' , 7 );
INSERT INTO person_ratings VALUES( 26 , 'Raj1' , 1 );
INSERT INTO person_ratings VALUES( 4 , 'Enric8' , 8 );
INSERT INTO person_ratings VALUES( 21 , 'Nereus3' , 5 );
INSERT INTO person_ratings VALUES( 45 , 'Imogen29' , 8 );
INSERT INTO person_ratings VALUES( 46 , 'Iracema' , 2 );
INSERT INTO person_ratings VALUES( 24 , 'Tanja643' , 5 );
INSERT INTO person_ratings VALUES( 7 , 'Ratnaq8' , 4 );
INSERT INTO person_ratings VALUES( 13 , 'Dharma36' , 7 );
INSERT INTO person_ratings VALUES( 44 , 'Kaija' , 2 );
INSERT INTO person_ratings VALUES( 48 , 'Thancmar53' , 1 );
INSERT INTO person_ratings VALUES( 14 , 'Valentin3' , 4 );
INSERT INTO person_ratings VALUES( 27 , 'Sergius' , 8 );
INSERT INTO person_ratings VALUES( 43 , 'Philippos2' , 8 );
INSERT INTO person_ratings VALUES( 16 , 'Belshatzzar3' , 10 );
INSERT INTO person_ratings VALUES( 46 , 'achana6' , 9 );
INSERT INTO person_ratings VALUES( 47 , 'Wayna31' , 7 );
INSERT INTO person_ratings VALUES( 6 , 'Enosh2' , 2 );
INSERT INTO person_ratings VALUES( 18 , 'Govinda2' , 6 );
INSERT INTO person_ratings VALUES( 24 , 'Jagdishyi' , 4 );
INSERT INTO person_ratings VALUES( 35 , 'Reynard' , 9 );
INSERT INTO person_ratings VALUES( 32 , 'Sabah7' , 10 );
INSERT INTO person_ratings VALUES( 31 , 'Sinta5' , 9 );
INSERT INTO person_ratings VALUES( 14 , 'Srinivas4368' , 3 );
INSERT INTO person_ratings VALUES( 28 , 'Morpheus2' , 6 );
INSERT INTO person_ratings VALUES( 41 , 'Murtada3' , 3 );
INSERT INTO person_ratings VALUES( 23 , 'Shota34' , 1 );
INSERT INTO person_ratings VALUES( 9 , 'Loke2' , 4 );
INSERT INTO person_ratings VALUES( 4 , 'Drest36423' , 6 );
INSERT INTO person_ratings VALUES( 31 , 'Silvia' , 3 );
INSERT INTO person_ratings VALUES( 28 , 'Elon3' , 8 );
INSERT INTO person_ratings VALUES( 21 , 'Tabatha' , 5 );
INSERT INTO person_ratings VALUES( 23 , 'Michal42' , 9 );
INSERT INTO person_ratings VALUES( 11 , 'Chiyembekezo' , 7 );
INSERT INTO person_ratings VALUES( 20 , 'Dag' , 9 );
INSERT INTO person_ratings VALUES( 20 , 'Arie' , 1 );
INSERT INTO person_ratings VALUES( 33 , 'Fulgenzio5' , 6 );
INSERT INTO person_ratings VALUES( 34 , 'Audhild2' , 7 );
INSERT INTO person_ratings VALUES( 23 , 'Montana' , 3 );
INSERT INTO person_ratings VALUES( 1 , 'Minos' , 6 );
INSERT INTO person_ratings VALUES( 6 , 'Arnulf' , 2 );
INSERT INTO person_ratings VALUES( 41 , 'Giselmund' , 7 );
INSERT INTO person_ratings VALUES( 23 , 'Mercedes5456' , 1 );
INSERT INTO person_ratings VALUES( 31 , 'Alban' , 2 );
INSERT INTO person_ratings VALUES( 20 , 'Aurelius4' , 7 );
INSERT INTO person_ratings VALUES( 46 , 'Kip' , 6 );
INSERT INTO person_ratings VALUES( 6 , 'EvyDinesh' , 10 );
INSERT INTO person_ratings VALUES( 28 , 'Arie50' , 6 );
INSERT INTO person_ratings VALUES( 42 , 'Raj1' , 10 );
INSERT INTO person_ratings VALUES( 7 , 'Enric8' , 5 );
INSERT INTO person_ratings VALUES( 44 , 'Nereus3' , 8 );
INSERT INTO person_ratings VALUES( 4 , 'Imogen29' , 4 );
INSERT INTO person_ratings VALUES( 27 , 'Iracema' , 3 );
INSERT INTO person_ratings VALUES( 20 , 'Tanja643' , 6 );
INSERT INTO person_ratings VALUES( 17 , 'Ratnaq8' , 4 );
INSERT INTO person_ratings VALUES( 41 , 'Dharma36' , 5 );
INSERT INTO person_ratings VALUES( 45 , 'Kaija' , 4 );
INSERT INTO person_ratings VALUES( 17 , 'Thancmar53' , 7 );
INSERT INTO person_ratings VALUES( 24 , 'Valentin3' , 8 );
INSERT INTO person_ratings VALUES( 30 , 'Sergius' , 4 );
INSERT INTO person_ratings VALUES( 9 , 'Philippos2' , 4 );
INSERT INTO person_ratings VALUES( 49 , 'Belshatzzar3' , 1 );
INSERT INTO person_ratings VALUES( 23 , 'achana6' , 3 );
INSERT INTO person_ratings VALUES( 50 , 'Wayna31' , 1 );
INSERT INTO person_ratings VALUES( 17 , 'Enosh2' , 1 );
INSERT INTO person_ratings VALUES( 34 , 'Govinda2' , 4 );
INSERT INTO person_ratings VALUES( 30 , 'Jagdishyi' , 4 );
INSERT INTO person_ratings VALUES( 49 , 'Sabah7' , 9 );
INSERT INTO person_ratings VALUES( 18 , 'Sinta5' , 5 );
INSERT INTO person_ratings VALUES( 24 , 'Kadek78' , 1 );
INSERT INTO person_ratings VALUES( 49 , 'Srinivas4368' , 3 );
INSERT INTO person_ratings VALUES( 29 , 'Morpheus2' , 3 );
INSERT INTO person_ratings VALUES( 34 , 'Murtada3' , 8 );
INSERT INTO person_ratings VALUES( 46 , 'Ruaraidh' , 10 );
INSERT INTO person_ratings VALUES( 4 , 'Shota34' , 9 );
INSERT INTO person_ratings VALUES( 28 , 'Loke2' , 5 );
INSERT INTO person_ratings VALUES( 13 , 'Drest36423' , 6 );
INSERT INTO person_ratings VALUES( 12 , 'Silvia' , 8 );
INSERT INTO person_ratings VALUES( 49 , 'Elon3' , 10 );
INSERT INTO person_ratings VALUES( 38 , 'Tabatha' , 1 );
INSERT INTO person_ratings VALUES( 22 , 'Michal42' , 7 );
INSERT INTO person_ratings VALUES( 30 , 'Chiyembekezo' , 8 );
INSERT INTO person_ratings VALUES( 14 , 'Dag' , 10 );
INSERT INTO person_ratings VALUES( 9 , 'Fulgenzio5' , 7 );
INSERT INTO person_ratings VALUES( 45 , 'Audhild2' , 8 );
INSERT INTO person_ratings VALUES( 27 , 'Montana' , 5 );
INSERT INTO person_ratings VALUES( 12 , 'Minos' , 5 );
INSERT INTO person_ratings VALUES( 37 , 'Arnulf' , 7 );
INSERT INTO person_ratings VALUES( 44 , 'Giselmund' , 7 );
INSERT INTO person_ratings VALUES( 25 , 'Mercedes5456' , 7 );
INSERT INTO person_ratings VALUES( 23 , 'Alban' , 4 );
INSERT INTO person_ratings VALUES( 15 , 'Octavius' , 3 );
INSERT INTO person_ratings VALUES( 18 , 'Aurelius4' , 1 );
INSERT INTO person_ratings VALUES( 1 , 'Kip' , 4 );
INSERT INTO person_ratings VALUES( 25 , 'EvyDinesh' , 10 );
INSERT INTO person_ratings VALUES( 28 , 'Raj1' , 4 );
INSERT INTO person_ratings VALUES( 44 , 'Enric8' , 7 );
INSERT INTO person_ratings VALUES( 50 , 'Nereus3' , 6 );
INSERT INTO person_ratings VALUES( 37 , 'Imogen29' , 2 );
INSERT INTO person_ratings VALUES( 11 , 'Iracema' , 2 );
INSERT INTO person_ratings VALUES( 27 , 'Tanja643' , 2 );
INSERT INTO person_ratings VALUES( 26 , 'Ratnaq8' , 7 );
INSERT INTO person_ratings VALUES( 22 , 'Dharma36' , 1 );
INSERT INTO person_ratings VALUES( 18 , 'Kaija' , 6 );
INSERT INTO person_ratings VALUES( 37 , 'Thancmar53' , 2 );
INSERT INTO person_ratings VALUES( 21 , 'Valentin3' , 5 );
INSERT INTO person_ratings VALUES( 34 , 'Sergius' , 9 );
INSERT INTO person_ratings VALUES( 26 , 'Philippos2' , 4 );
INSERT INTO person_ratings VALUES( 48 , 'Belshatzzar3' , 2 );
INSERT INTO person_ratings VALUES( 28 , 'achana6' , 2 );
INSERT INTO person_ratings VALUES( 33 , 'Wayna31' , 8 );
INSERT INTO person_ratings VALUES( 20 , 'Enosh2' , 3 );
INSERT INTO person_ratings VALUES( 9 , 'Govinda2' , 2 );
INSERT INTO person_ratings VALUES( 17 , 'Jagdishyi' , 4 );
INSERT INTO person_ratings VALUES( 14 , 'Reynard' , 3 );
INSERT INTO person_ratings VALUES( 38 , 'Sabah7' , 3 );
INSERT INTO person_ratings VALUES( 40 , 'Sinta5' , 4 );
INSERT INTO person_ratings VALUES( 7 , 'Kadek78' , 3 );
INSERT INTO person_ratings VALUES( 34 , 'Srinivas4368' , 7 );
INSERT INTO person_ratings VALUES( 26 , 'Morpheus2' , 1 );
INSERT INTO person_ratings VALUES( 48 , 'Murtada3' , 1 );
INSERT INTO person_ratings VALUES( 16 , 'Ruaraidh' , 8 );
INSERT INTO person_ratings VALUES( 13 , 'Shota34' , 4 );
INSERT INTO person_ratings VALUES( 10 , 'Loke2' , 3 );
INSERT INTO person_ratings VALUES( 37 , 'Drest36423' , 10 );
INSERT INTO person_ratings VALUES( 15 , 'Silvia' , 4 );
INSERT INTO person_ratings VALUES( 42 , 'Tabatha' , 8 );
INSERT INTO person_ratings VALUES( 24 , 'Michal42' , 4 );
INSERT INTO person_ratings VALUES( 4 , 'Chiyembekezo' , 2 );
INSERT INTO person_ratings VALUES( 41 , 'Dag' , 5 );
INSERT INTO person_ratings VALUES( 13 , 'Arie' , 6 );
INSERT INTO person_ratings VALUES( 2 , 'Fulgenzio5' , 2 );
INSERT INTO person_ratings VALUES( 7 , 'Audhild2' , 1 );
INSERT INTO person_ratings VALUES( 39 , 'Montana' , 3 );
INSERT INTO person_ratings VALUES( 17 , 'Minos' , 6 );
INSERT INTO person_ratings VALUES( 36 , 'Arnulf' , 4 );
INSERT INTO person_ratings VALUES( 6 , 'Giselmund' , 10 );
INSERT INTO person_ratings VALUES( 29 , 'Mercedes5456' , 9 );
INSERT INTO person_ratings VALUES( 1 , 'Alban' , 1 );
INSERT INTO person_ratings VALUES( 30 , 'Octavius' , 5 );
INSERT INTO person_ratings VALUES( 37 , 'Aurelius4' , 9 );
INSERT INTO person_ratings VALUES( 47 , 'Kip' , 4 );
INSERT INTO person_ratings VALUES( 18 , 'EvyDinesh' , 9 );
INSERT INTO person_ratings VALUES( 33 , 'Arie50' , 5 );
INSERT INTO person_ratings VALUES( 45 , 'Raj1' , 6 );
INSERT INTO person_ratings VALUES( 22 , 'Enric8' , 5 );
INSERT INTO person_ratings VALUES( 45 , 'Nereus3' , 10 );
INSERT INTO person_ratings VALUES( 24 , 'Imogen29' , 1 );
INSERT INTO person_ratings VALUES( 12 , 'Iracema' , 6 );
INSERT INTO person_ratings VALUES( 48 , 'Tanja643' , 3 );
INSERT INTO person_ratings VALUES( 41 , 'Ratnaq8' , 1 );
INSERT INTO person_ratings VALUES( 19 , 'Dharma36' , 8 );
INSERT INTO person_ratings VALUES( 40 , 'Kaija' , 5 );
INSERT INTO person_ratings VALUES( 33 , 'Thancmar53' , 3 );
INSERT INTO person_ratings VALUES( 29 , 'Valentin3' , 2 );
INSERT INTO person_ratings VALUES( 14 , 'Sergius' , 6 );
INSERT INTO person_ratings VALUES( 10 , 'Philippos2' , 5 );
INSERT INTO person_ratings VALUES( 26 , 'Belshatzzar3' , 1 );
INSERT INTO person_ratings VALUES( 8 , 'achana6' , 1 );
INSERT INTO person_ratings VALUES( 29 , 'Wayna31' , 4 );
INSERT INTO person_ratings VALUES( 1 , 'Enosh2' , 10 );
INSERT INTO person_ratings VALUES( 31 , 'Govinda2' , 9 );
INSERT INTO person_ratings VALUES( 45 , 'Jagdishyi' , 7 );
INSERT INTO person_ratings VALUES( 12 , 'Reynard' , 5 );
INSERT INTO person_ratings VALUES( 10 , 'Sabah7' , 8 );
INSERT INTO person_ratings VALUES( 1 , 'Sinta5' , 4 );
INSERT INTO person_ratings VALUES( 39 , 'Kadek78' , 4 );
INSERT INTO person_ratings VALUES( 40 , 'Srinivas4368' , 10 );
INSERT INTO person_ratings VALUES( 31 , 'Murtada3' , 6 );
INSERT INTO person_ratings VALUES( 8 , 'Shota34' , 4 );
INSERT INTO person_ratings VALUES( 6 , 'Loke2' , 5 );
INSERT INTO person_ratings VALUES( 42 , 'Drest36423' , 2 );
INSERT INTO person_ratings VALUES( 25 , 'Silvia' , 10 );
INSERT INTO person_ratings VALUES( 6 , 'Elon3' , 8 );
INSERT INTO person_ratings VALUES( 26 , 'Tabatha' , 2 );
INSERT INTO person_ratings VALUES( 12 , 'Michal42' , 8 );
INSERT INTO person_ratings VALUES( 39 , 'Chiyembekezo' , 1 );
INSERT INTO person_ratings VALUES( 9 , 'Dag' , 2 );
INSERT INTO person_ratings VALUES( 9 , 'Arie' , 1 );
INSERT INTO person_ratings VALUES( 40 , 'Fulgenzio5' , 2 );
INSERT INTO person_ratings VALUES( 6 , 'Montana' , 10 );
INSERT INTO person_ratings VALUES( 6 , 'Minos' , 10 );
INSERT INTO person_ratings VALUES( 5 , 'Arnulf' , 10 );
INSERT INTO person_ratings VALUES( 7 , 'Giselmund' , 3 );
INSERT INTO person_ratings VALUES( 4 , 'Alban' , 7 );
INSERT INTO person_ratings VALUES( 21 , 'Octavius' , 9 );
INSERT INTO person_ratings VALUES( 4 , 'Aurelius4' , 6 );
INSERT INTO person_ratings VALUES( 40 , 'EvyDinesh' , 5 );
INSERT INTO person_ratings VALUES( 29 , 'Arie50' , 9 );
INSERT INTO person_ratings VALUES( 16 , 'Raj1' , 7 );
INSERT INTO person_ratings VALUES( 3 , 'Enric8' , 2 );
INSERT INTO person_ratings VALUES( 16 , 'Nereus3' , 8 );
INSERT INTO person_ratings VALUES( 15 , 'Imogen29' , 3 );
INSERT INTO person_ratings VALUES( 48 , 'Iracema' , 2 );
INSERT INTO person_ratings VALUES( 5 , 'Tanja643' , 7 );
INSERT INTO person_ratings VALUES( 50 , 'Dharma36' , 5 );
INSERT INTO person_ratings VALUES( 22 , 'Kaija' , 9 );
INSERT INTO person_ratings VALUES( 38 , 'Thancmar53' , 1 );
INSERT INTO person_ratings VALUES( 44 , 'Valentin3' , 7 );
INSERT INTO person_ratings VALUES( 4 , 'Sergius' , 1 );
INSERT INTO person_ratings VALUES( 17 , 'Philippos2' , 10 );
INSERT INTO person_ratings VALUES( 42 , 'Belshatzzar3' , 2 );   
INSERT INTO person_ratings VALUES( 22 , 'Imogen29' , 8 , 'H' );
INSERT INTO person_ratings VALUES( 23 , 'Imogen29' , 9 , 'H' );
INSERT INTO person_ratings VALUES( 25 , 'Imogen29' , 7 , 'H' );

--use
--while read line; do echo "INSERT INTO people_ratings VALUES(" $((RANDOM % 50 + 1)) "," $line "," $((RANDOM % 10 + 1)) ");"; done < a 
--to generate more (a file with logins)


INSERT INTO movie_awards VALUES(8, 'Picture', 'W', 1932);
INSERT INTO movie_awards VALUES(25, 'Picture', 'W', 2017);
INSERT INTO movie_awards VALUES(48, 'Picture', 'N', 2017);
INSERT INTO movie_awards VALUES(49, 'Picture', 'N', 2017);
INSERT INTO movie_awards VALUES(24, 'Picture', 'W', 2012);
INSERT INTO movie_awards VALUES(32, 'Picture', 'W', 1997);

INSERT INTO people_awards VALUES(2, 15, 'Director', 'W', 1965);
INSERT INTO people_awards VALUES(41, 18, 'Director', 'W', 1983);
INSERT INTO people_awards VALUES(9, 19, 'Director', 'N', 1983);
INSERT INTO people_awards VALUES(20, 40, 'Director', 'N', 2014);
INSERT INTO people_awards VALUES(28, 48, 'Director', 'N', 2017);

--INDECIES
CREATE INDEX idx_awards_movie_id ON movie_awards ( movie_id );
CREATE INDEX idx_movie_awards_category ON movie_awards ( category );
CREATE INDEX idx_production_1_movie_id ON movie_genre ( movie_id );
CREATE INDEX idx_movie_genre_genre_id ON movie_genre ( genre );
CREATE INDEX idx_movie_language_movie_id ON movie_language ( movie_id );
CREATE INDEX idx_movie_language_language_id ON movie_language ( "language" );
CREATE INDEX idx_people_birth_country ON people ( birth_country );
CREATE INDEX idx_people_awards_person_id ON people_awards ( person_id );
CREATE INDEX idx_people_awards_movie_id ON people_awards ( movie_id );
CREATE INDEX idx_people_awards_category ON people_awards ( category );
CREATE INDEX idx_production_movie_id ON production ( movie_id );
CREATE INDEX idx_production_country_id ON production ( country );
CREATE INDEX idx_production_company_movie_id ON production_company ( movie_id );
CREATE INDEX idx_production_company_company_id ON production_company ( company );
CREATE INDEX idx_similar_movies_movie_id1 ON similar_movies ( movie_id1 );
CREATE INDEX idx_similar_movies_movie_id2 ON similar_movies ( movie_id2 );
CREATE INDEX idx_watchlist_movie_id ON watchlist ( movie_id );
CREATE INDEX idx_watchlist_user_id ON watchlist ( login );
CREATE INDEX idx_alternative_title_movie_id ON alternative_title ( movie_id );
CREATE INDEX idx_awards_categories_award_id ON awards_categories ( award_name );
CREATE INDEX idx_awards_categories_category_id ON awards_categories ( category_name );
CREATE INDEX idx_citizenship_person_id ON citizenship ( person_id );
CREATE INDEX idx_citizenship_country_id ON citizenship ( country );
CREATE INDEX idx_crew_person_id ON crew ( person_id );
CREATE INDEX idx_crew_movie_id ON crew ( movie_id );
CREATE INDEX idx_movie_ratings_user_id ON movie_ratings ( login );
CREATE INDEX idx_movie_ratings_movie_id ON movie_ratings ( movie_id );
CREATE INDEX idx_person_ratings_user_id ON person_ratings ( login );
CREATE INDEX idx_person_ratings_person_id ON person_ratings ( person_id );
CREATE INDEX idx_profession_person_id ON profession ( person_id );
CREATE INDEX idx_review_user_id ON review ( login );
CREATE INDEX idx_review_movie_id ON review ( movie_id );
