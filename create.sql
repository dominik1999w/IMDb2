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
--DROP FUNCTIONS IF EXIST
DROP FUNCTION IF EXISTS to_year(date);
DROP FUNCTION IF EXISTS remove_duplicates(text);
DROP FUNCTION IF EXISTS delete_symmetric_rows();
DROP FUNCTION IF EXISTS movie_year(int);
DROP FUNCTION IF EXISTS is_alive_trig();
DROP FUNCTION IF EXISTS movie_awards_trig();
DROP FUNCTION IF EXISTS people_awards_trig();
DROP FUNCTION IF EXISTS before_born();
DROP FUNCTION IF EXISTS awards_amount(integer, char);
DROP FUNCTION IF EXISTS show_similar(integer);
DROP FUNCTION IF EXISTS seen_date();
----------------------------------------------
--DROP VIEW IF EXIST
DROP VIEW IF EXISTS show_movie_ranking;
DROP VIEW IF EXISTS show_heart_movie_ranking;
DROP VIEW IF EXISTS show_person_ranking;
DROP VIEW IF EXISTS show_heart_person_ranking;
DROP VIEW IF EXISTS watchlist_info;
DROP VIEW IF EXISTS show_similar_movies;

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


CREATE OR REPLACE FUNCTION to_year(d date) RETURNS numeric(4) AS $$
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
	CHECK (boxoffice >= opening_weekend_usa) ,
	CONSTRAINT unique_movie UNIQUE(title,release_date)
 );

CREATE TYPE genre_type AS ENUM('Action','Adventure','Animation','Biography','Comedy',
	'Crime','Documentary','Drama','Family','Fantasy','Film Noir','History','Horror',
	'Music','Musical','Mystery','Romance','Sci-fi','Short','Sport','Superhero','Thriller',
	'War','Western','Other'); /*enum for genres*/

CREATE TYPE role_type AS ENUM ('Director','Editor','Music','Cameraworker','Writer','Actor','Others'); /*ENUM FOR CREW*/

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
    seen                 date DEFAULT NOW() ,
	PRIMARY KEY(movie_id,login),
    CHECK(seen <= NOW()),
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
	category_genre       genre_type ,
	category_role        role_type ,
	is_short             char(1) ,


	CHECK (movie_or_person = 'M' OR movie_or_person = 'P') ,
	CHECK (is_short = 'Y')
 );

CREATE TABLE movie_awards ( 
	movie_id             integer  NOT NULL /*REFERENCES movie*/,
	category             varchar(512)  NOT NULL /*REFERENCES categories*/,
	nomination_or_win    char(1)  NOT NULL ,
	"year"               numeric(4)  NOT NULL ,

	CHECK (nomination_or_win = 'N' OR nomination_or_win = 'W') ,
	CHECK ("year" >= 1927 AND "year" <= to_year(current_date)) ,

	CONSTRAINT unique_movie_awards UNIQUE(movie_id, category, nomination_or_win)
 );

CREATE TABLE people_awards ( 
	person_id            integer NOT NULL /*REFERENCES people*/,
	category             varchar(512)   NOT NULL/*REFERENCES categories*/,
	nomination_or_win    char(1)  NOT NULL ,

	CHECK (nomination_or_win = 'N' OR nomination_or_win = 'W') /* N-nomination, W-win*/,

	CONSTRAINT unique_people_awards UNIQUE(person_id, category, nomination_or_win)
 );

--PEOPLE TABLES
CREATE TABLE people ( 
	person_id            SERIAL PRIMARY KEY,
	first_name           varchar(512)  NOT NULL ,
	last_name            varchar(512)   ,
	born                 date   NOT NULL,
	died                 date   ,
	birth_country        varchar(512)   , 

	CHECK (died < NOW()) ,
	CHECK (born < NOW()) ,
	CHECK (born < died) ,
	CONSTRAINT unique_people UNIQUE(first_name, last_name, born)
 );

CREATE TABLE users ( 
	login                varchar(17)  PRIMARY KEY ,
	"password"           INT  NOT NULL ,
    admin                BOOL DEFAULT false,
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



CREATE TABLE crew ( 
	person_id            integer  NOT NULL /*REFERENCES people*/,
	movie_id             integer  NOT NULL /*REFERENCES movie*/,
	"role"               role_type  NOT NULL ,
	"character"          varchar(512)    ,

	CONSTRAINT unique_crew UNIQUE(person_id,movie_id,"role","character")
 );

----------------------------------------------

--FUNCTIONS

--seen_date constraint
CREATE OR REPLACE function seen_date() returns trigger AS $$
BEGIN 
    IF ((SELECT release_date FROM movie WHERE movie_id=NEW.movie_id)>NEW.seen)
        THEN RAISE EXCEPTION 'Seen date is not valid!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER seen_date_trigger BEFORE INSERT OR UPDATE ON movie_ratings
FOR EACH ROW EXECUTE PROCEDURE seen_date();

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
CREATE OR REPLACE FUNCTION movie_year(id int) RETURNS numeric(4) AS $$
BEGIN
	RETURN EXTRACT(year FROM (SELECT release_date FROM movie WHERE movie_id = id));
END;
$$ LANGUAGE plpgsql;

--age
CREATE OR REPLACE FUNCTION age(idd int) RETURNS int AS $$
BEGIN
	IF (SELECT born FROM people p WHERE p.person_id = idd) IS NULL 
	OR (SELECT died FROM people p WHERE p.person_id = idd) IS NOT NULL 
	THEN RETURN NULL; 
	END IF;

	RETURN to_year(current_date)::int - 
	to_year((SELECT born FROM people p WHERE p.person_id = idd))::int;
END;
$$ LANGUAGE plpgsql;

----------------------------------------------

--awards movies
CREATE OR REPLACE FUNCTION movie_awards_trig() RETURNS trigger AS $$
BEGIN
	IF (SELECT SUM(1) FROM categories WHERE category = NEW.category AND movie_or_person = 'M')
		IS NULL THEN
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
		(SELECT category_genre FROM categories WHERE category = NEW.category) IS NOT NULL
		THEN
		IF (SELECT movie_id FROM movie JOIN movie_genre USING(movie_id) 
			WHERE movie_id = NEW.movie_id AND genre IN (SELECT category_genre FROM categories WHERE category = NEW.category)) IS NULL
			THEN
				RAISE EXCEPTION 'Wrong genere!';
		END IF;
	END IF;
	IF
		(SELECT is_short FROM categories WHERE category = NEW.category) IS NOT NULL
		THEN
			IF (SELECT runtime FROM movie WHERE movie_id = NEW.movie_id) > INTERVAL '40 minutes'
			THEN
				RAISE EXCEPTION 'Not short film';
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

	IF (SELECT SUM(1) FROM categories WHERE category = NEW.category AND movie_or_person = 'P')
		IS NULL THEN
		RAISE EXCEPTION 'Wrong category';
	END IF;

	--categories constraints

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
			RETURN NULL;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_born BEFORE INSERT OR UPDATE ON crew
FOR EACH ROW EXECUTE PROCEDURE before_born();
----------------------------------------------

--how many awards for a movie
CREATE OR REPLACE FUNCTION awards_amount(movieIn integer,c char) RETURNS integer AS $$
BEGIN
    IF(c='W' OR c='N') THEN
        RETURN (SELECT count(*) FROM movie_awards ma WHERE movie_id = movieIn AND nomination_or_win=c);
    END IF;
    IF(c='B') THEN /* B for both */
        RETURN (SELECT count(*) FROM movie_awards ma WHERE movie_id = movieIn);
    END IF;
    RAISE EXCEPTION 'Invalid input';
END;
$$ LANGUAGE plpgsql;

----------------------------------------------

--similar movies
CREATE OR REPLACE FUNCTION show_similar(id integer) RETURNS 
	TABLE (
		m_id integer,
		movie_title varchar(512),
		release_year numeric(4)
	)
 AS $$
BEGIN

	RETURN QUERY SELECT 
	movie_id,
	title,
	to_year(release_date)
	 FROM movie m WHERE movie_id IN (SELECT movie_id1 FROM similar_movies WHERE movie_id2 = id) OR movie_id IN (SELECT movie_id2 FROM similar_movies WHERE movie_id1 = id);

END;
$$ LANGUAGE plpgsql;

--to use type : SELECT * FROM show_similar(id);
----------------------------------------------

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
ALTER TABLE watchlist ADD CONSTRAINT fk_watchlist_movie FOREIGN KEY ( movie_id ) REFERENCES movie( movie_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE watchlist ADD CONSTRAINT fk_watchlist_users FOREIGN KEY ( login ) REFERENCES users( login ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE person_ratings ADD CONSTRAINT fk_person_ratings_users FOREIGN KEY ( login ) REFERENCES users( login ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE person_ratings ADD CONSTRAINT fk_person_ratings_people FOREIGN KEY ( person_id ) REFERENCES people( person_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE profession ADD CONSTRAINT fk_profession_people FOREIGN KEY ( person_id ) REFERENCES people( person_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE crew ADD CONSTRAINT fk_crew_people FOREIGN KEY ( person_id ) REFERENCES people( person_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE crew ADD CONSTRAINT fk_crew_movie FOREIGN KEY ( movie_id ) REFERENCES movie( movie_id ) ON UPDATE CASCADE ON DELETE CASCADE;
----------------------------------------------



--SAMPLE DATA
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa) VALUES
( 'Blacksmith Of The World' , '1891-09-24' , INTERVAL '29 minutes' , 21000 , 74000 , 420), 
( 'Tree Of Freedom' , '1896-10-18' , INTERVAL '181 minutes' , 32000 , 73000 , 220), 
( 'Children With Strength' , '1903-11-07' , INTERVAL '75 minutes' , 45000 , 99000 , 630), 
( 'Pilots Of Reality' , '1908-02-10' , INTERVAL '131 minutes' , 65000 , 96000 , 230), 
( 'Viva Nollywood' , '1919-09-05' , INTERVAL '23 minutes' , 93000 , 53000 , 870), 
( 'Foreigners And Friends' , '1928-10-14' , INTERVAL '29 minutes' , 50000 , 71000 , 460), 
( 'Tower Of Reality' , '1929-12-25' , INTERVAL '26 minutes' , 82000 , 10000 , 540), 
( 'Strife Of Glory' , '1932-01-14' , INTERVAL '85 minutes' , 92000 , 36000000 , 300000), 
( 'Hurt By The City' , '1935-06-19' , INTERVAL '191 minutes' , 1000 , 20000 , 530), 
( 'Welcome To The City' , '1936-07-20' , INTERVAL '145 minutes' , 31000 , 12000 , 6000), 
( 'Slave Of Reality' , '1941-02-03' , INTERVAL '129 minutes' , 75000 , 30000 , 340), 
( 'Warrior Of Perfection' , '1943-02-02' , INTERVAL '199 minutes' , 1000 , 46000 , 740), 
( 'Horses Of Fortune' , '1956-05-24' , INTERVAL '179 minutes' , 18000 , 11000 , 90), 
( 'Butchers Of Perfection' , '1959-01-08' , INTERVAL '103 minutes' , 90000 , 21000 , 700), 
( 'Foes And Defenders' , '1965-05-26' , INTERVAL '170 minutes' , 28000 , 38000 , 30), 
( 'Blacksmiths And Slaves' , '1971-12-20' , INTERVAL '69 minutes' , 31000 , 17000 , 160), 
( 'Unity Of The Frontline' , '1972-05-31' , INTERVAL '123 minutes' , 29000 , 82000 , 710), 
( 'Culling Of Gold' , '1983-04-14' , INTERVAL '180 minutes' , 49000 , 97000 , 170), 
( 'Losing Eternity' , '1983-06-15' , INTERVAL '98 minutes' , 44000 , 87000 , 490), 
( 'Searching In My End' , '1992-04-28' , INTERVAL '27 minutes' , 96000 , 7000 , 360), 
( 'Owl Of The End' , '1996-03-20' , INTERVAL '119 minutes' , 76000 , 75000 , 330), 
( 'Soldier With Gold' , '2001-05-18' , INTERVAL '115 minutes' , 12000 , 38000 , 350), 
( 'Agents Of Fire' , '2004-10-02' , INTERVAL '24 minutes' , 47000 , 78000 , 260), 
( 'Boys Of The North' , '2012-10-05' , INTERVAL '38 minutes' , 16000 , 43000 , 150), 
( 'Boys And Gods' , '2017-09-10' , INTERVAL '20 minutes' , 52000 , 66000 , 530), 
( 'Owls And Invaders' , '1989-06-23' , INTERVAL '85 minutes' , 64000 , 48000 , 410), 
( 'Star With Silver' , '1990-01-23' , INTERVAL '94 minutes' , 46000 , 79000 , 10), 
( 'Family Without Faith' , '1993-04-24' , INTERVAL '114 minutes' , 28000 , 31000 , 970), 
( 'Travel To The World' , '1993-05-17' , INTERVAL '67 minutes' , 8000 , 59000 , 540), 
( 'Taste Of My Nightmares' , '1994-01-06' , INTERVAL '174 minutes' , 79000 , 95000 , 170), 
( 'Nymph Of Dreams' , '1994-07-31' , INTERVAL '71 minutes' , 99000 , 63000 , 240), 
( 'Defender Without Hope' , '1997-09-28' , INTERVAL '196 minutes' , 49000 , 97000 , 680), 
( 'Foes Of Joy' , '2000-06-03' , INTERVAL '76 minutes' , 63000 , 83000 , 270), 
( 'Fish With Money' , '2003-01-14' , INTERVAL '192 minutes' , 22000 , 16000 , 560), 
( 'Pirates And Foes' , '2003-11-24' , INTERVAL '92 minutes' , 28000 , 53000 , 260), 
( 'Witches And Hunters' , '2007-05-16' , INTERVAL '53 minutes' , 37000 , 2000 , 850), 
( 'Bane Of Power' , '2009-01-01' , INTERVAL '144 minutes' , 8000 , 90000 , 130), 
( 'Fruit Without Sin' , '2012-06-02' , INTERVAL '83 minutes' , 49000 , 980 , 380), 
( 'Amusing My Home' , '2012-06-04' , INTERVAL '79 minutes' , 7000 , 27000 , 800), 
( 'Breaking The Graveyard' , '2014-02-01' , INTERVAL '44 minutes' , 32000 , 41000 , 200), 
( 'Bandit Of Destruction' , '2014-05-08' , INTERVAL '146 minutes' , 60000 , 94000 , 440), 
( 'Snake Of The Sea' , '2014-11-15' , INTERVAL '30 minutes' , 12000 , 47000 , 400), 
( 'Pilots Without A Goal' , '2015-01-11' , INTERVAL '34 minutes' , 3000 , 9000 , 270), 
( 'Wolves Of History' , '2015-01-15' , INTERVAL '39 minutes' , 32000 , 7000 , 130), 
( 'Descendants And Snakes' , '2015-06-27' , INTERVAL '48 minutes' , 51000 , 29000 , 340), 
( 'Lords And Spies' , '2015-07-20' , INTERVAL '159 minutes' , 21000 , 4100 , 710), 
( 'Edge Of Insanity' , '2016-07-30' , INTERVAL '164 minutes' , 11000 , 76000 , 680), 
( 'Intention Of The North' , '2017-02-11' , INTERVAL '198 minutes' , 50000 , 93000 , 800), 
( 'Separated By The Dungeons' , '2017-12-20' , INTERVAL '62 minutes' , 59000 , 65000 , 170), 
( 'Wspomnienia moich koszmarów' , '2018-12-26' , INTERVAL '79 minutes' , 70000 , 23000 , 520);

INSERT INTO similar_movies VALUES 
 (1,2), 
 (19,2), 
 (18,2), 
 (15,7), 
 (9,4), 
 (5,2), 
 (3,12), 
 (2,12), 
 (1,34), 
 (1,42), 
 (2,10);

INSERT INTO alternative_title VALUES
(2,'Tree'), (2,'Freedom'), (3,'Chistengens');

INSERT INTO production VALUES 
(1,'United Kingdom'), 
 (1,'China'), 
 (1,'Australia'), 
 (2 , 'United States'), 
 (3 , 'United States'), 
 (4 , 'United States'), 
 (5,'Nigeria'), 
 (6 , 'United States'), 
 (7 , 'United States'), 
 (8 , 'United States'), 
 (9 , 'United States'), 
 (10 , 'United States'), 
 (11 , 'United States'), 
 (12 , 'United States'), 
 (13 , 'United States'), 
 (14 , 'United States'), 
 (15 , 'United States'), 
 (16 , 'United States'), 
 (17 , 'United States'), 
 (18 , 'United States'), 
 (19 , 'United States'), 
 (20 , 'United States'), 
 (21 , 'United States'), 
 (22 , 'United States'), 
 (23 , 'United States'), 
 (24 , 'United States'), 
 (25 , 'United States'), 
 (26 , 'United States'), 
 (27 , 'United States'), 
 (28 , 'United States'), 
 (29 , 'United States'), 
 (30 , 'United States'), 
 (31 , 'United States'), 
 (32 , 'United States'), 
 (33 , 'United States'), 
 (34 , 'United States'), 
 (35 , 'Sweden'), 
 (36 , 'United States'), 
 (37 , 'United States'), 
 (38 , 'United States'), 
 (39 , 'United States'), 
 (40 , 'United States'), 
 (41 , 'United States'), 
 (42 , 'United States'), 
 (43 , 'United States'), 
 (44 , 'United States'), 
 (45 , 'United States'), 
 (46 , 'United States'), 
 (47 , 'United States'), 
 (48 , 'United States'), 
 (49 , 'United States'), 
 (50,'Poland');

INSERT INTO movie_language VALUES 
 (1 , 'Chinesee'), 
 (1 , 'Arabic'), 
 (2 , 'English'), 
 (3 , 'English'), 
 (4 , 'English'), 
 (5 , 'English'), 
 (5 , 'Afrikanaas'), 
 (6 , 'English'), 
 (7 , 'English'), 
 (8 , 'English'), 
 (9 , 'English'), 
 (10 , 'English'), 
 (11 , 'English'), 
 (11 , 'Arabic'), 
 (12 , 'English'), 
 (13 , 'English'), 
 (14 , 'English'), 
 (15 , 'English'), 
 (16 , 'English'), 
 (17 , 'English'), 
 (18 , 'English'), 
 (19 , 'English'), 
 (20 , 'English'), 
 (21 , 'English'), 
 (22 , 'English'), 
 (23 , 'English'), 
 (24 , 'English'), 
 (25 , 'English'), 
 (26 , 'English'), 
 (27 , 'English'), 
 (28 , 'English'), 
 (29 , 'English'), 
 (30 , 'English'), 
 (31 , 'English'), 
 (32 , 'English'), 
 (33 , 'English'), 
 (34 , 'English'), 
 (35 , 'Swedish'), 
 (35 , 'English'), 
 (36 , 'English'), 
 (37 , 'English'), 
 (38 , 'English'), 
 (39 , 'English'), 
 (40 , 'English'), 
 (41 , 'English'), 
 (42 , 'English'), 
 (43 , 'English'), 
 (44 , 'English'), 
 (45 , 'English'), 
 (46 , 'English'), 
 (47 , 'English'), 
 (48 , 'English'), 
 (49 , 'English'), 
 (50 , 'Polish');

INSERT INTO movie_genre VALUES 
 (1 , 'Drama'), 
 (2 , 'Drama'), 
 (3 , 'Drama'), 
 (4 , 'Drama'), 
 (5 , 'Drama'), 
 (6 , 'Drama'), 
 (7 , 'Drama'), 
 (8 , 'Drama'), 
 (9 , 'Drama'), 
 (10 , 'Drama'), 
 (11 , 'Drama'), 
 (12 , 'Drama'), 
 (13 , 'Drama'), 
 (31 , 'Drama'), 
 (32 , 'Drama'), 
 (33 , 'Drama'), 
 (34 , 'Drama'), 
 (35 , 'Drama'), 
 (36 , 'Drama'), 
 (37 , 'Drama'), 
 (38 , 'Drama'), 
 (39 , 'Drama'), 
 (40 , 'Drama'), 
 (41 , 'Drama'), 
 (42 , 'Drama'), 
 (43 , 'Drama'), 
 (44 , 'Drama'), 
 (45 , 'Drama'), 
 (46 , 'Drama'), 
 (47 , 'Drama'), 
 (48 , 'Drama'), 
 (49 , 'Drama'), 
 (50 , 'Drama'), 
 (2 , 'Action'), 
 (3 , 'Action'), 
 (4 , 'Action'), 
 (5 , 'Action'), 
 (6 , 'Action'), 
 (7 , 'Action'), 
 (8 , 'Action'), 
 (9 , 'Action'), 
 (10 , 'Action'), 
 (11 , 'Action'), 
 (12 , 'Action'), 
 (13 , 'Action'), 
 (14 , 'Action'), 
 (15 , 'Action'), 
 (16 , 'Action'), 
 (17 , 'Action'), 
 (18 , 'Action'), 
 (19 , 'Action'), 
 (20 , 'Action'), 
 (21 , 'Action'), 
 (22 , 'Action'), 
 (23 , 'Action'), 
 (24 , 'Action'), 
 (25 , 'Action'), 
 (26 , 'Action'), 
 (27 , 'Action'), 
 (28 , 'Action'), 
 (29 , 'Action'), 
 (30 , 'Action'), 
 (42 , 'Action'), 
 (43 , 'Action'), 
 (44 , 'Action'), 
 (45 , 'Action'), 
 (46 , 'Action'), 
 (47 , 'Action'), 
 (48 , 'Action'), 
 (49 , 'Action'), 
 (50 , 'Action'), 
 (11 , 'Documentary'), 
 (12 , 'Documentary'), 
 (15 , 'Documentary'), 
 (16 , 'Documentary'), 
 (17 , 'Documentary'), 
 (18 , 'Documentary'), 
 (19 , 'Documentary'), 
 (34 , 'Documentary'), 
 (35 , 'Documentary'), 
 (38 , 'Documentary'), 
 (13 , 'Animation'), 
 (14 , 'Animation'), 
 (15 , 'Animation'), 
 (16 , 'Animation'), 
 (17 , 'Animation'), 
 (43 , 'Animation'), 
 (45 , 'Animation'), 
 (49 , 'Animation'), 
 (6 , 'Comedy'), 
 (7 , 'Comedy'), 
 (8 , 'Comedy'), 
 (9 , 'Comedy'), 
 (10 , 'Comedy'), 
 (16 , 'Comedy'), 
 (17 , 'Comedy'), 
 (25 , 'Comedy'), 
 (26 , 'Comedy'), 
 (27 , 'Comedy'), 
 (28 , 'Comedy'), 
 (29 , 'Comedy'), 
 (30 , 'Comedy'), 
 (34 , 'Comedy'), 
 (35 , 'Comedy'), 
 (38 , 'Comedy'), 
 (2 , 'Sci-fi'), 
 (3 , 'Sci-fi'), 
 (4 , 'Sci-fi'), 
 (7 , 'Sci-fi'), 
 (8 , 'Sci-fi'), 
 (9 , 'Sci-fi'), 
 (10 , 'Sci-fi'), 
 (11 , 'Sci-fi'), 
 (12 , 'Sci-fi'), 
 (13 , 'Sci-fi'), 
 (14 , 'Sci-fi'), 
 (15 , 'Sci-fi'), 
 (19 , 'Sci-fi'), 
 (20 , 'Sci-fi'), 
 (24 , 'Sci-fi'), 
 (25 , 'Sci-fi'), 
 (26 , 'Sci-fi'), 
 (27 , 'Sci-fi'), 
 (28 , 'Sci-fi'), 
 (29 , 'Sci-fi'), 
 (30 , 'Sci-fi'), 
 (31 , 'Sci-fi'), 
 (42 , 'Sci-fi'), 
 (43 , 'Sci-fi');

INSERT INTO production_company VALUES
 (2 , 'Disney'), 
 (3 , 'Disney'), 
 (4 , 'Disney'), 
 (11 , 'Disney'), 
 (12 , 'Disney'), 
 (13 , 'Disney'), 
 (14 , 'Disney'), 
 (15 , 'Disney'), 
 (25 , 'Disney'), 
 (26 , 'Disney'), 
 (27 , 'Disney'), 
 (28 , 'Disney'), 
 (29 , 'Disney'), 
 (30 , 'Disney'), 
 (31 , 'Disney'), 
 (32 , 'Disney'), 
 (33 , 'Disney'), 
 (34 , 'Disney'), 
 (1 , 'Warner Bros'), 
 (1 , 'China movies'), 
 (5 , 'Warner Bros'), 
 (6 , 'Warner Bros'), 
 (7 , 'Warner Bros'), 
 (8 , 'Warner Bros'), 
 (9 , 'Warner Bros'), 
 (10 , 'Warner Bros'), 
 (16 , 'Warner Bros'), 
 (17 , 'Warner Bros'), 
 (18 , 'Warner Bros'), 
 (19 , 'Warner Bros'), 
 (20 , 'Warner Bros'), 
 (21 , 'Warner Bros'), 
 (22 , 'Warner Bros'), 
 (23 , 'Warner Bros'), 
 (24 , 'Warner Bros'), 
 (35 , 'Warner Bros'), 
 (36 , 'Warner Bros'), 
 (37 , 'Warner Bros'), 
 (38 , 'Warner Bros'), 
 (39 , 'Warner Bros'), 
 (40 , 'Warner Bros'), 
 (41 , 'Warner Bros'), 
 (42 , 'Warner Bros'), 
 (43 , 'Warner Bros'), 
 (44 , 'Warner Bros'), 
 (45 , 'Warner Bros'), 
 (46 , 'Warner Bros'), 
 (47 , 'Warner Bros'), 
 (48 , 'Warner Bros'), 
 (49 , 'Warner Bros'), 
 (50 , 'Polski Instytut Filmowy');

INSERT INTO users(login,password)
SELECT
names,
random()::int
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

--ONLY FOR TESTING PURPOSE 
INSERT INTO users VALUES ('''admin''', -1057345382 ,true); 

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

INSERT INTO watchlist VALUES
 ('Imogen29',6), 
 ('Imogen29',16), 
 ('Imogen29',4), 
 ('Imogen29',34), 
 ('Imogen29',42), 
 ('Imogen29',3), 
 ('Imogen29',1), 
 ('Imogen29',2), 
 ('Audhild2',6), 
 ('Audhild2',1), 
 ('Audhild2',4), 
 ('Audhild2',34), 
 ('Audhild2',42), 
 ('Audhild2',41), 
 ('Audhild2',12), 
 ('Audhild2',7);

INSERT INTO categories VALUES('Picture', '1927-01-01', NULL, 'M');
INSERT INTO categories VALUES('Director', '1927-01-01', NULL, 'P', NULL, 'Director');
INSERT INTO categories VALUES('Actor', '1927-01-01', NULL, 'P', NULL, 'Actor');
INSERT INTO categories VALUES('Actress', '1927-01-01', NULL, 'P', NULL, 'Actor');
INSERT INTO categories VALUES('Supporting Actor', '1936-01-01', NULL, 'P', NULL, 'Actor');
INSERT INTO categories VALUES('Supporting Actress', '1936-01-01', NULL, 'P', NULL, 'Actor');
INSERT INTO categories VALUES('Animated Feature Film', '2001-01-01', NULL, 'M', 'Animation');
INSERT INTO categories VALUES('Animated Short Film', '1930-01-01', NULL, 'M', 'Animation', NULL, 'Y');
INSERT INTO categories VALUES('Cinematography', '1927-01-01', NULL, 'M');
INSERT INTO categories VALUES('Costume Design', '1948-01-01', NULL, 'M');
INSERT INTO categories VALUES('Documentary Feature', '1943-01-01', NULL, 'M', 'Documentary');
INSERT INTO categories VALUES('Documentary Short Subject', '1941-01-01', NULL, 'M', 'Documentary');
INSERT INTO categories VALUES('Film Editing', '1934-01-01', NULL, 'M');
INSERT INTO categories VALUES('International Feature Film', '1947-01-01', NULL, 'M');
INSERT INTO categories VALUES('Live Action Short Film', '1931-01-01', NULL, 'M', 'Action', NULL, 'Y');
INSERT INTO categories VALUES('Makeup and Hairstyling', '1981-01-01', NULL, 'M');
INSERT INTO categories VALUES('Original Score', '1934-01-01', NULL, 'M');
INSERT INTO categories VALUES('Original Song', '1934-01-01', NULL, 'M');
INSERT INTO categories VALUES('Production Design', '1927-01-01', NULL, 'M');
INSERT INTO categories VALUES('Sound Editing', '1963-01-01', NULL, 'M');
INSERT INTO categories VALUES('Sound Mixing', '1929-01-01', NULL, 'M');
INSERT INTO categories VALUES('Visual Effects', '1939-01-01', NULL, 'M');
INSERT INTO categories VALUES('Adapted Screenplay', '1927-01-01', NULL, 'M');
INSERT INTO categories VALUES('Original Screenplay', '1940-01-01', NULL, 'M');
INSERT INTO categories VALUES('Assistant Director', '1932-01-01', '1937-12-31', 'P', NULL, 'Director');
INSERT INTO categories VALUES('Director - Comedy', '1927-01-01', '1928-12-31', 'P', 'Comedy', 'Director');
INSERT INTO categories VALUES('Director - Dramatic', '1927-01-01', '1928-12-31', 'P', 'Drama', 'Director');
INSERT INTO categories VALUES('Dance Direction', '1935-01-01', '1937-12-31', 'M');
INSERT INTO categories VALUES('Engineering Effects', '1927-01-01', '1928-12-31', 'M');
INSERT INTO categories VALUES('Original Musical', '1984-01-01', '1984-12-31', 'M', 'Musical');
INSERT INTO categories VALUES('Original Story', '1927-01-01', '1956-12-31', 'M');
INSERT INTO categories VALUES('Short Subject – Color', '1936-01-01', '1937-12-31', 'M', NULL, NULL, 'Y');
INSERT INTO categories VALUES('Short Subject – Comedy', '1931-01-01', '1935-12-31', 'M', 'Comedy', NULL, 'Y');
INSERT INTO categories VALUES('Title Writing', '1927-01-01', '1928-12-31', 'M');
INSERT INTO categories VALUES('Unique and Artistic Production', '1927-01-01', '1928-12-31', 'M');

INSERT INTO movie_ratings VALUES
 ( 20 , 'achana6' , 10 ), 
 ( 11 , 'Wayna31' , 7 ), 
 ( 44 , 'Enosh2' , 9 ), 
 ( 41 , 'Govinda2' , 9 ), 
 ( 31 , 'Jagdishyi' , 10 ), 
 ( 45 , 'Reynard' , 9 ), 
 ( 33 , 'Sabah7' , 4 ), 
 ( 36 , 'Sinta5' , 4 ), 
 ( 39 , 'Kadek78' , 1 ), 
 ( 3 , 'Srinivas4368' , 9 ), 
 ( 12 , 'Morpheus2' , 2 ), 
 ( 42 , 'Murtada3' , 3 ), 
 ( 18 , 'Ruaraidh' , 10 ), 
 ( 39 , 'Shota34' , 3 ), 
 ( 46 , 'Loke2' , 10 ), 
 ( 35 , 'Drest36423' , 4 ), 
 ( 50 , 'Silvia' , 6 ), 
 ( 17 , 'Elon3' , 7 ), 
 ( 6 , 'Tabatha' , 1 ), 
 ( 19 , 'Michal42' , 10 ), 
 ( 24 , 'Chiyembekezo' , 7 ), 
 ( 7 , 'Dag' , 9 ), 
 ( 19 , 'Arie' , 8 ), 
 ( 40 , 'Fulgenzio5' , 5 ), 
 ( 17 , 'Montana' , 4 ), 
 ( 24 , 'Minos' , 1 ), 
 ( 34 , 'Arnulf' , 1 ), 
 ( 6 , 'Giselmund' , 9 ), 
 ( 39 , 'Mercedes5456' , 10 ), 
 ( 4 , 'Alban' , 7 ), 
 ( 20 , 'Aurelius4' , 10 ), 
 ( 44 , 'Kip' , 3 ), 
 ( 37 , 'EvyDinesh' , 3 ), 
 ( 47 , 'Arie50' , 10 ), 
 ( 6 , 'Raj1' , 1 ), 
 ( 7 , 'Enric8' , 8 ), 
 ( 30 , 'Nereus3' , 9 ), 
 ( 6 , 'Imogen29' , 2 ), 
 ( 31 , 'Iracema' , 4 ), 
 ( 30 , 'Tanja643' , 5 ), 
 ( 29 , 'Dharma36' , 8 ), 
 ( 11 , 'Kaija' , 8 ), 
 ( 10 , 'Thancmar53' , 1 ), 
 ( 6 , 'Valentin3' , 8 ), 
 ( 21 , 'Sergius' , 6 ), 
 ( 45 , 'Philippos2' , 2 ), 
 ( 12 , 'Belshatzzar3' , 9 ), 
 ( 13 , 'achana6' , 4 ), 
 ( 27 , 'Wayna31' , 10 ), 
 ( 45 , 'Enosh2' , 6 ), 
 ( 11 , 'Govinda2' , 4 ), 
 ( 24 , 'Jagdishyi' , 6 ), 
 ( 24 , 'Reynard' , 5 ), 
 ( 10 , 'Sabah7' , 3 ), 
 ( 18 , 'Sinta5' , 8 ), 
 ( 24 , 'Kadek78' , 9 ), 
 ( 28 , 'Srinivas4368' , 10 ), 
 ( 44 , 'Morpheus2' , 9 ), 
 ( 10 , 'Murtada3' , 2 ), 
 ( 31 , 'Ruaraidh' , 1 ), 
 ( 41 , 'Shota34' , 5 ), 
 ( 36 , 'Drest36423' , 6 ), 
 ( 18 , 'Silvia' , 8 ), 
 ( 4 , 'Elon3' , 9 ), 
 ( 9 , 'Tabatha' , 2 ), 
 ( 1 , 'Michal42' , 2 ), 
 ( 10 , 'Chiyembekezo' , 6 ), 
 ( 13 , 'Dag' , 5 ), 
 ( 28 , 'Arie' , 8 ), 
 ( 49 , 'Fulgenzio5' , 2 ), 
 ( 17 , 'Audhild2' , 3 ), 
 ( 34 , 'Montana' , 1 ), 
 ( 12 , 'Minos' , 4 ), 
 ( 3 , 'Arnulf' , 5 ), 
 ( 45 , 'Mercedes5456' , 2 ), 
 ( 47 , 'Alban' , 2 ), 
 ( 28 , 'Octavius' , 9 ), 
 ( 36 , 'Aurelius4' , 5 ), 
 ( 43 , 'Kip' , 9 ), 
 ( 49 , 'EvyDinesh' , 10 ), 
 ( 17 , 'Arie50' , 6 ), 
 ( 10 , 'Raj1' , 6 ), 
 ( 2 , 'Enric8' , 8 ), 
 ( 1 , 'Nereus3' , 3 ), 
 ( 47 , 'Iracema' , 2 ), 
 ( 41 , 'Tanja643' , 4 ), 
 ( 27 , 'Ratnaq8' , 3 ), 
 ( 4 , 'Dharma36' , 5 ), 
 ( 38 , 'Kaija' , 1 ), 
 ( 2 , 'Thancmar53' , 4 ), 
 ( 13 , 'Valentin3' , 3 ), 
 ( 14 , 'Sergius' , 10 ), 
 ( 26 , 'Philippos2' , 2 ), 
 ( 36 , 'Belshatzzar3' , 8 ), 
 ( 46 , 'achana6' , 10 ), 
 ( 21 , 'Wayna31' , 8 ), 
 ( 38 , 'Enosh2' , 5 ), 
 ( 44 , 'Govinda2' , 4 ), 
 ( 42 , 'Jagdishyi' , 3 ), 
 ( 12 , 'Reynard' , 10 ), 
 ( 37 , 'Sabah7' , 7 ), 
 ( 35 , 'Sinta5' , 1 ), 
 ( 1 , 'Kadek78' , 1 ), 
 ( 18 , 'Srinivas4368' , 9 ), 
 ( 31 , 'Morpheus2' , 10 ), 
 ( 24 , 'Murtada3' , 4 ), 
 ( 1 , 'Ruaraidh' , 5 ), 
 ( 35 , 'Shota34' , 7 ), 
 ( 14 , 'Loke2' , 8 ), 
 ( 28 , 'Drest36423' , 6 ), 
 ( 34 , 'Silvia' , 1 ), 
 ( 20 , 'Elon3' , 3 ), 
 ( 27 , 'Tabatha' , 5 ), 
 ( 50 , 'Michal42' , 2 ), 
 ( 35 , 'Chiyembekezo' , 9 ), 
 ( 18 , 'Dag' , 10 ), 
 ( 45 , 'Fulgenzio5' , 4 ), 
 ( 13 , 'Audhild2' , 4 ), 
 ( 40 , 'Minos' , 8 ), 
 ( 7 , 'Arnulf' , 7 ), 
 ( 9 , 'Giselmund' , 1 ), 
 ( 30 , 'Mercedes5456' , 4 ), 
 ( 14 , 'Alban' , 5 ), 
 ( 23 , 'Octavius' , 10 ), 
 ( 23 , 'Aurelius4' , 3 ), 
 ( 4 , 'Kip' , 6 ), 
 ( 16 , 'EvyDinesh' , 1 ), 
 ( 12 , 'Arie50' , 1 ), 
 ( 3 , 'Raj1' , 6 ), 
 ( 28 , 'Enric8' , 5 ), 
 ( 24 , 'Nereus3' , 10 ), 
 ( 17 , 'Imogen29' , 10 ), 
 ( 42 , 'Iracema' , 4 ), 
 ( 44 , 'Tanja643' , 3 ), 
 ( 46 , 'Ratnaq8' , 7 ), 
 ( 28 , 'Kaija' , 9 ), 
 ( 3 , 'Thancmar53' , 5 ), 
 ( 29 , 'Valentin3' , 5 ), 
 ( 49 , 'Sergius' , 1 ), 
 ( 14 , 'Philippos2' , 3 ), 
 ( 22 , 'Belshatzzar3' , 9 ), 
 ( 14 , 'achana6' , 1 ), 
 ( 33 , 'Wayna31' , 9 ), 
 ( 3 , 'Enosh2' , 10 ), 
 ( 19 , 'Govinda2' , 7 ), 
 ( 13 , 'Jagdishyi' , 10 ), 
 ( 18 , 'Reynard' , 6 ), 
 ( 14 , 'Sabah7' , 4 ), 
 ( 44 , 'Sinta5' , 4 ), 
 ( 10 , 'Kadek78' , 4 ), 
 ( 6 , 'Srinivas4368' , 7 ), 
 ( 22 , 'Morpheus2' , 7 ), 
 ( 3 , 'Murtada3' , 9 ), 
 ( 40 , 'Ruaraidh' , 8 ), 
 ( 12 , 'Shota34' , 5 ), 
 ( 37 , 'Loke2' , 1 ), 
 ( 21 , 'Drest36423' , 8 ), 
 ( 40 , 'Silvia' , 8 ), 
 ( 23 , 'Tabatha' , 1 ), 
 ( 5 , 'Michal42' , 4 ), 
 ( 18 , 'Chiyembekezo' , 6 ), 
 ( 8 , 'Dag' , 8 ), 
 ( 17 , 'Arie' , 4 ), 
 ( 44 , 'Fulgenzio5' , 8 ), 
 ( 38 , 'Audhild2' , 2 ), 
 ( 15 , 'Minos' , 10 ), 
 ( 38 , 'Arnulf' , 6 ), 
 ( 23 , 'Giselmund' , 10 ), 
 ( 15 , 'Mercedes5456' , 7 ), 
 ( 39 , 'Alban' , 6 ), 
 ( 32 , 'Octavius' , 6 ), 
 ( 37 , 'Aurelius4' , 7 ), 
 ( 45 , 'Kip' , 1 ), 
 ( 27 , 'EvyDinesh' , 7 ), 
 ( 35 , 'Arie50' , 4 ), 
 ( 44 , 'Raj1' , 1 ), 
 ( 48 , 'Enric8' , 1 ), 
 ( 20 , 'Nereus3' , 3 ), 
 ( 44 , 'Imogen29' , 8 ), 
 ( 18 , 'Tanja643' , 8 ), 
 ( 3 , 'Ratnaq8' , 8 ), 
 ( 2 , 'Dharma36' , 5 ), 
 ( 22 , 'Kaija' , 1 ), 
 ( 44 , 'Valentin3' , 10 ), 
 ( 32 , 'Sergius' , 5 ), 
 ( 43 , 'Philippos2' , 6 ), 
 ( 29 , 'Belshatzzar3' , 7 ), 
 ( 22 , 'achana6' , 5 ), 
 ( 36 , 'Wayna31' , 4 ), 
 ( 26 , 'Enosh2' , 6 ), 
 ( 45 , 'Govinda2' , 4 ), 
 ( 5 , 'Jagdishyi' , 6 ), 
 ( 9 , 'Reynard' , 5 ), 
 ( 12 , 'Sabah7' , 7 ), 
 ( 19 , 'Sinta5' , 7 ), 
 ( 37 , 'Srinivas4368' , 3 ), 
 ( 46 , 'Morpheus2' , 5 ), 
 ( 19 , 'Murtada3' , 7 ), 
 ( 17 , 'Ruaraidh' , 7 ), 
 ( 48 , 'Shota34' , 6 ), 
 ( 19 , 'Loke2' , 4 ), 
 ( 8 , 'Silvia' , 10 ), 
 ( 36 , 'Elon3' , 6 ), 
 ( 5 , 'Tabatha' , 6 ), 
 ( 15 , 'Michal42' , 10 ), 
 ( 32 , 'Chiyembekezo' , 7 ), 
 ( 36 , 'Dag' , 4 ), 
 ( 3 , 'Arie' , 5 ), 
 ( 24 , 'Fulgenzio5' , 7 ), 
 ( 2 , 'Audhild2' , 3 ), 
 ( 50 , 'Montana' , 5 ), 
 ( 23 , 'Minos' , 1 ), 
 ( 8 , 'Arnulf' , 6 ), 
 ( 20 , 'Giselmund' , 1 ), 
 ( 42 , 'Mercedes5456' , 5 ), 
 ( 50 , 'Alban' , 7 ), 
 ( 46 , 'Octavius' , 4 ), 
 ( 17 , 'Aurelius4' , 9 ), 
 ( 33 , 'Kip' , 10 ), 
 ( 1 , 'EvyDinesh' , 4 ), 
 ( 19 , 'Arie50' , 8 ), 
 ( 11 , 'Raj1' , 9 ), 
 ( 42 , 'Enric8' , 3 ), 
 ( 32 , 'Nereus3' , 3 ), 
 ( 20 , 'Imogen29' , 10 ), 
 ( 50 , 'Iracema' , 5 ), 
 ( 26 , 'Tanja643' , 7 ), 
 ( 36 , 'Ratnaq8' , 1 ), 
 ( 12 , 'Dharma36' , 3 ), 
 ( 21 , 'Kaija' , 5 ), 
 ( 36 , 'Thancmar53' , 10 ), 
 ( 4 , 'Valentin3' , 6 ), 
 ( 40 , 'Sergius' , 7 ), 
 ( 42 , 'Philippos2' , 4 ), 
 ( 26 , 'Belshatzzar3' , 5 ), 
 ( 37 , 'achana6' , 2 ), 
 ( 20 , 'Wayna31' , 5 ), 
 ( 1 , 'Enosh2' , 8 ), 
 ( 15 , 'Govinda2' , 4 ), 
 ( 26 , 'Jagdishyi' , 1 ), 
 ( 4 , 'Reynard' , 7 ), 
 ( 18 , 'Sabah7' , 6 ), 
 ( 31 , 'Kadek78' , 1 ), 
 ( 7 , 'Srinivas4368' , 2 ), 
 ( 6 , 'Morpheus2' , 9 ), 
 ( 15 , 'Murtada3' , 3 ), 
 ( 7 , 'Ruaraidh' , 3 ), 
 ( 3 , 'Shota34' , 8 ), 
 ( 9 , 'Loke2' , 10 ), 
 ( 33 , 'Drest36423' , 4 ), 
 ( 4 , 'Silvia' , 4 ), 
 ( 45 , 'Elon3' , 5 ), 
 ( 30 , 'Tabatha' , 8 ), 
 ( 8 , 'Michal42' , 9 ), 
 ( 6 , 'Chiyembekezo' , 10 ), 
 ( 23 , 'Dag' , 3 ), 
 ( 37 , 'Arie' , 10 ), 
 ( 30 , 'Fulgenzio5' , 10 ), 
 ( 5 , 'Audhild2' , 6 ), 
 ( 47 , 'Montana' , 1 ), 
 ( 42 , 'Minos' , 4 ), 
 ( 2 , 'Arnulf' , 5 ), 
 ( 32 , 'Giselmund' , 3 ), 
 ( 28 , 'Mercedes5456' , 6 ), 
 ( 41 , 'Alban' , 9 ), 
 ( 37 , 'Octavius' , 5 ), 
 ( 7 , 'Aurelius4' , 10 ), 
 ( 1 , 'Kip' , 5 ), 
 ( 50 , 'EvyDinesh' , 3 ), 
 ( 4 , 'Arie50' , 5 ), 
 ( 40 , 'Raj1' , 1 ), 
 ( 37 , 'Enric8' , 2 ), 
 ( 43 , 'Nereus3' , 10 ), 
 ( 24 , 'Imogen29' , 9 ), 
 ( 4 , 'Iracema' , 1 ), 
 ( 46 , 'Tanja643' , 8 ), 
 ( 11 , 'Ratnaq8' , 4 ), 
 ( 25 , 'Dharma36' , 6 ), 
 ( 29 , 'Kaija' , 6 ), 
 ( 4 , 'Thancmar53' , 1 ), 
 ( 50 , 'Valentin3' , 4 ), 
 ( 35 , 'Sergius' , 7 ), 
 ( 34 , 'Philippos2' , 2 ), 
 ( 2 , 'Belshatzzar3' , 6 );

INSERT INTO movie_ratings VALUES
 ( 32 , 'Imogen29' , 8 , 'H' ), 
 ( 33 , 'Imogen29' , 8 , 'H' ), 
 ( 34 , 'Imogen29' , 9 , 'H' ), 
 ( 35 , 'Imogen29' , 10 , 'H' );

--use
--while read line; do echo "INSERT INTO movie_ratings VALUES(" $((RANDOM % 50 + 1)) "," $line "," $((RANDOM % 10 + 1)) ");"; done < a 
--to generate more (a file with logins)

INSERT INTO people(first_name, last_name, born, birth_country) 
VALUES
( 'Noel' , 'Otto' , '1906-06-10' , 'United States'), 
( 'Marcelle' , 'Zachariah' , '1906-08-06' , 'United Kingdom'), 
( 'Candra' , 'Margurite' , '1911-02-05' , 'United States'), 
( 'Patrice' , 'Serafina' , '1913-10-01' , 'Nigeria'), 
( 'Carlotta' , 'Hershel' , '1917-01-16' , 'United Kingdom'), 
( 'Brunhlia' , 'Viera' , '1974-11-10' , 'United Kingdom'), 
( 'Ericka' , 'Flo' , '1975-05-22' , 'India'), 
( 'Maurine' , 'Yvonne' , '1976-06-01' , 'Nigeria'), 
( 'Lizzie' , 'Rowena' , '1976-10-28' , 'United States'), 
( 'Kendra' , 'Tegan' , '1977-03-16' , 'India'), 
( 'Barbar' , 'Alda' , '1978-02-21' , 'Nigeria'), 
( 'Charissa' , 'Meda' , '1978-09-07' , 'United Kingdom'), 
( 'Halley' , 'Markus' , '1985-04-18' , 'Nigeria'), 
( 'Brian' , 'Ashley' , '1986-01-13' , 'United States'), 
( 'Margret' , 'Scottie' , '1986-01-16' , 'United States'), 
( 'Florance' , 'Irena' , '1986-02-05' , 'India'), 
( 'Nona' , 'Janelle' , '1987-11-16' , 'India'), 
( 'Hank' , 'Eldon' , '1991-11-12' , 'India'), 
( 'Freda' , 'Myrtie' , '1993-01-21' , 'United States'), 
( 'Malena' , 'Verda' , '1993-09-27' , 'United Kingdom'), 
( 'Morton' , 'Bok' , '1996-03-08' , 'United Kingdom'), 
( 'Erline' , 'Alina' , '1996-11-27' , 'Nigeria'), 
( 'Solange' , 'Andre' , '1997-03-03' , 'Nigeria'), 
( 'Shelley' , 'Elois' , '1998-04-06' , 'Nigeria'), 
( 'Berna' , 'Damion' , '1998-08-29' , 'Nigeria'), 
( 'Jani' , 'Claretha' , '2005-03-17' , 'Nigeria'), 
( 'Phil' , 'Magnolia' , '2005-08-09' , 'Nigeria'), 
( 'Claris' , 'Bill' , '2006-02-27' , 'United Kingdom'), 
( 'Alise' , 'Sherwood' , '2006-12-14' , 'Nigeria'), 
( 'Vita' , 'Regan' , '2008-10-15' , 'Nigeria'), 
( 'John' , 'Jayne' , '1917-10-21' , 'United Kingdom'), 
( 'Jefferson' , 'Rachal' , '1932-04-23' , 'United Kingdom'), 
( 'Latesha' , 'Salvador' , '1938-06-26' , 'United Kingdom'), 
( 'Willis' , 'Roma' , '1939-08-18' , 'India'), 
( 'Warren' , 'Salena' , '1944-03-31' , 'United States'), 
( 'Rolande' , 'Lenita' , '1948-09-10' , 'United Kingdom'), 
( 'Hermelinda' , 'Britt' , '1949-10-03' , 'United States'), 
( 'Bertha' , 'Kathy' , '1950-10-09' , 'United States'), 
( 'Jeremiah' , 'Sigrid' , '1953-08-15' , 'India'), 
( 'Katy' , 'Alecia' , '1956-01-02' , 'United Kingdom'), 
( 'Percy' , 'Kristopher' , '1956-07-24' , 'United Kingdom'), 
( 'Markus' , 'Kristyn' , '1966-08-14' , 'United Kingdom'), 
( 'Royce' , 'Willena' , '1968-09-12' , 'United States'), 
( 'Fe' , 'Margarita' , '1968-12-30' , 'United States'), 
( 'Billy' , 'Cornelia' , '1969-04-03' , 'Nigeria'), 
( 'Garnet' , 'Stephanie' , '1972-07-31' , 'India'), 
( 'Milagro' , 'Chas' , '1974-07-18' , 'Nigeria'), 
( 'Yolanda' , 'Jackelyn' , '1974-08-08' , 'India'), 
( 'Heidi' , 'Sherrell' , '1976-08-26' , 'United States'), 
( 'Alida' , 'Hung' , '1990-07-31' , 'United Kingdom');


UPDATE people SET died = '2018-04-05' WHERE person_id =  1 ;
UPDATE people SET died = '2007-01-01' WHERE person_id =  2 ;
UPDATE people SET died = '2019-04-03' WHERE person_id =  3 ;
UPDATE people SET died = '2000-08-13' WHERE person_id =  4 ;
UPDATE people SET died = '1999-09-09' WHERE person_id =  5 ;


INSERT INTO profession VALUES
 ( 44 , 'Director' ), 
 ( 6 , 'Director' ), 
 ( 17 , 'Director' ), 
 ( 20 , 'Director' ), 
 ( 12 , 'Director' ), 
 ( 34 , 'Director' ), 
 ( 24 , 'Director' ), 
 ( 2 , 'Director' ), 
 ( 27 , 'Director' ), 
 ( 13 , 'Director' ), 
 ( 3 , 'Director' ), 
 ( 40 , 'Director' ), 

 ( 39 , 'Actor' ), 
 ( 49 , 'Actor' ), 
 ( 20 , 'Actor' ), 
 ( 23 , 'Actor' ), 
 ( 7 , 'Actor' ), 
 ( 11 , 'Actor' ), 
 ( 28 , 'Actor' ), 
 ( 1 , 'Actor' ), 
 ( 24 , 'Actor' ), 
 ( 15 , 'Actor' ), 
 ( 43 , 'Actor' ), 
 ( 45 , 'Actor' ), 
 ( 8 , 'Actor' ), 
 ( 16 , 'Actor' ), 
 ( 6 , 'Actor' ), 
 ( 34 , 'Actor' ), 

 ( 45 , 'Editor' ), 
 ( 20 , 'Editor' ), 
 ( 16 , 'Editor' ), 
 ( 6 , 'Editor' ), 
 ( 27 , 'Editor' ), 
 ( 19 , 'Editor' ), 
 ( 18 , 'Editor' ), 
 ( 48 , 'Editor' ), 
 ( 22 , 'Editor' ), 
 ( 28 , 'Editor' ), 
 ( 13 , 'Editor' ), 
 ( 1 , 'Editor' ), 

 ( 40 , 'Producer' ), 
 ( 32 , 'Producer' ), 
 ( 39 , 'Producer' ), 
 ( 33 , 'Producer' ), 
 ( 48 , 'Producer' ), 
 ( 12 , 'Producer' ), 
 ( 49 , 'Producer' ), 
 ( 22 , 'Producer' ), 
 ( 29 , 'Producer' ), 
 ( 11 , 'Producer' ), 
 ( 42 , 'Producer' ), 
 ( 30 , 'Producer' ), 
 ( 10 , 'Producer' ), 
 ( 23 , 'Producer' ), 

 ( 28 , 'Composer' ), 
 ( 8 , 'Composer' ), 
 ( 24 , 'Composer' ), 
 ( 50 , 'Composer' ), 

 ( 5 , 'Writer' ), 
 ( 24 , 'Writer' ), 
 ( 13 , 'Writer' ), 
 ( 19 , 'Writer' ), 
 ( 48 , 'Writer' ), 
 ( 39 , 'Writer' ), 
 ( 11 , 'Writer' ), 
 ( 35 , 'Writer' ), 
 ( 8 , 'Writer' ), 
 ( 10 , 'Writer' ), 

 ( 41 , 'Angler' ), 
 ( 35 , 'Angler' ), 
 ( 20 , 'Angler' );

INSERT INTO crew VALUES
 ( 34 , 1 , 'Director' ), 
 ( 8 , 2 , 'Director' ), 
 ( 1 , 3 , 'Director' ), 
 ( 36 , 4 , 'Director' ), 
 ( 4 , 5 , 'Director' ), 
 ( 48 , 6 , 'Director' ), 
 ( 31 , 7 , 'Director' ), 
 ( 3 , 8 , 'Director' ), 
 ( 45 , 9 , 'Director' ), 
 ( 7 , 10 , 'Director' ), 
 ( 4 , 11 , 'Director' ), 
 ( 28 , 12 , 'Director' ), 
 ( 19 , 13 , 'Director' ), 
 ( 30 , 14 , 'Director' ), 
 ( 2 , 15 , 'Director' ), 
 ( 1 , 16 , 'Director' ), 
 ( 15 , 17 , 'Director' ), 
 ( 41 , 18 , 'Director' ), 
 ( 9 , 19 , 'Director' ), 
 ( 7 , 20 , 'Director' ), 
 ( 47 , 21 , 'Director' ), 
 ( 30 , 22 , 'Director' ), 
 ( 48 , 23 , 'Director' ), 
 ( 13 , 24 , 'Director' ), 
 ( 16 , 25 , 'Director' ), 
 ( 4 , 26 , 'Director' ), 
 ( 48 , 27 , 'Director' ), 
 ( 33 , 28 , 'Director' ), 
 ( 25 , 29 , 'Director' ), 
 ( 47 , 30 , 'Director' ), 
 ( 1 , 31 , 'Director' ), 
 ( 35 , 32 , 'Director' ), 
 ( 18 , 33 , 'Director' ), 
 ( 35 , 34 , 'Director' ), 
 ( 43 , 35 , 'Director' ), 
 ( 32 , 36 , 'Director' ), 
 ( 13 , 37 , 'Director' ), 
 ( 3 , 38 , 'Director' ), 
 ( 36 , 39 , 'Director' ), 
 ( 20 , 40 , 'Director' ), 
 ( 23 , 41 , 'Director' ), 
 ( 2 , 42 , 'Director' ), 
 ( 39 , 43 , 'Director' ), 
 ( 41 , 44 , 'Director' ), 
 ( 45 , 45 , 'Director' ), 
 ( 49 , 46 , 'Director' ), 
 ( 18 , 47 , 'Director' ), 
 ( 28 , 48 , 'Director' ), 
 ( 31 , 49 , 'Director' ), 
 ( 48 , 50 , 'Director' ), 

 ( 9 , 1 , 'Editor' ), 
 ( 5 , 2 , 'Editor' ), 
 ( 47 , 3 , 'Editor' ), 
 ( 36 , 4 , 'Editor' ), 
 ( 3 , 5 , 'Editor' ), 
 ( 39 , 6 , 'Editor' ), 
 ( 30 , 7 , 'Editor' ), 
 ( 39 , 8 , 'Editor' ), 
 ( 25 , 9 , 'Editor' ), 
 ( 7 , 10 , 'Editor' ), 
 ( 12 , 11 , 'Editor' ), 
 ( 42 , 12 , 'Editor' ), 
 ( 40 , 13 , 'Editor' ), 
 ( 19 , 14 , 'Editor' ), 
 ( 13 , 15 , 'Editor' ), 
 ( 17 , 16 , 'Editor' ), 
 ( 31 , 17 , 'Editor' ), 
 ( 27 , 18 , 'Editor' ), 
 ( 20 , 19 , 'Editor' ), 
 ( 20 , 20 , 'Editor' ), 
 ( 31 , 21 , 'Editor' ), 
 ( 6 , 22 , 'Editor' ), 
 ( 13 , 23 , 'Editor' ), 
 ( 4 , 24 , 'Editor' ), 
 ( 46 , 25 , 'Editor' ), 
 ( 3 , 26 , 'Editor' ), 
 ( 42 , 27 , 'Editor' ), 
 ( 33 , 28 , 'Editor' ), 
 ( 7 , 29 , 'Editor' ), 
 ( 39 , 30 , 'Editor' ), 
 ( 19 , 31 , 'Editor' ), 
 ( 41 , 32 , 'Editor' ), 
 ( 44 , 33 , 'Editor' ), 
 ( 8 , 34 , 'Editor' ), 
 ( 14 , 35 , 'Editor' ), 
 ( 25 , 36 , 'Editor' ), 
 ( 2 , 37 , 'Editor' ), 
 ( 31 , 38 , 'Editor' ), 
 ( 11 , 39 , 'Editor' ), 
 ( 18 , 40 , 'Editor' ), 
 ( 40 , 41 , 'Editor' ), 
 ( 44 , 42 , 'Editor' ), 
 ( 42 , 43 , 'Editor' ), 
 ( 32 , 44 , 'Editor' ), 
 ( 29 , 45 , 'Editor' ), 
 ( 30 , 46 , 'Editor' ), 
 ( 24 , 47 , 'Editor' ), 
 ( 6 , 48 , 'Editor' ), 
 ( 8 , 49 , 'Editor' ), 
 ( 38 , 50 , 'Editor' ), 

 ( 20 , 1 , 'Writer' ), 
 ( 2 , 2 , 'Writer' ), 
 ( 32 , 3 , 'Writer' ), 
 ( 44 , 4 , 'Writer' ), 
 ( 3 , 5 , 'Writer' ), 
 ( 45 , 6 , 'Writer' ), 
 ( 16 , 7 , 'Writer' ), 
 ( 16 , 8 , 'Writer' ), 
 ( 14 , 9 , 'Writer' ), 
 ( 37 , 10 , 'Writer' ), 
 ( 16 , 11 , 'Writer' ), 
 ( 5 , 12 , 'Writer' ), 
 ( 23 , 13 , 'Writer' ), 
 ( 9 , 14 , 'Writer' ), 
 ( 32 , 15 , 'Writer' ), 
 ( 46 , 16 , 'Writer' ), 
 ( 48 , 17 , 'Writer' ), 
 ( 33 , 18 , 'Writer' ), 
 ( 48 , 19 , 'Writer' ), 
 ( 14 , 20 , 'Writer' ), 
 ( 26 , 21 , 'Writer' ), 
 ( 20 , 22 , 'Writer' ), 
 ( 48 , 23 , 'Writer' ), 
 ( 14 , 24 , 'Writer' ), 
 ( 1 , 25 , 'Writer' ), 
 ( 4 , 26 , 'Writer' ), 
 ( 26 , 27 , 'Writer' ), 
 ( 18 , 28 , 'Writer' ), 
 ( 40 , 29 , 'Writer' ), 
 ( 44 , 30 , 'Writer' ), 
 ( 41 , 31 , 'Writer' ), 
 ( 16 , 32 , 'Writer' ), 
 ( 19 , 33 , 'Writer' ), 
 ( 47 , 34 , 'Writer' ), 
 ( 25 , 35 , 'Writer' ), 
 ( 14 , 36 , 'Writer' ), 
 ( 36 , 37 , 'Writer' ), 
 ( 40 , 38 , 'Writer' ), 
 ( 29 , 39 , 'Writer' ), 
 ( 41 , 40 , 'Writer' ), 
 ( 1 , 41 , 'Writer' ), 
 ( 23 , 42 , 'Writer' ), 
 ( 50 , 43 , 'Writer' ), 
 ( 33 , 44 , 'Writer' ), 
 ( 11 , 45 , 'Writer' ), 
 ( 43 , 46 , 'Writer' ), 
 ( 45 , 47 , 'Writer' ), 
 ( 32 , 48 , 'Writer' ), 
 ( 11 , 49 , 'Writer' ), 
 ( 41 , 50 , 'Writer' ), 

 ( 19 , 1 , 'Music' ), 
 ( 40 , 2 , 'Music' ), 
 ( 43 , 3 , 'Music' ), 
 ( 42 , 4 , 'Music' ), 
 ( 2 , 5 , 'Music' ), 
 ( 30 , 6 , 'Music' ), 
 ( 14 , 7 , 'Music' ), 
 ( 43 , 8 , 'Music' ), 
 ( 16 , 9 , 'Music' ), 
 ( 38 , 10 , 'Music' ), 
 ( 46 , 11 , 'Music' ), 
 ( 33 , 12 , 'Music' ), 
 ( 21 , 13 , 'Music' ), 
 ( 40 , 14 , 'Music' ), 
 ( 36 , 15 , 'Music' ), 
 ( 19 , 16 , 'Music' ), 
 ( 9 , 17 , 'Music' ), 
 ( 38 , 18 , 'Music' ), 
 ( 9 , 19 , 'Music' ), 
 ( 32 , 20 , 'Music' ), 
 ( 23 , 21 , 'Music' ), 
 ( 45 , 22 , 'Music' ), 
 ( 27 , 23 , 'Music' ), 
 ( 14 , 24 , 'Music' ), 
 ( 22 , 25 , 'Music' ), 
 ( 5 , 26 , 'Music' ), 
 ( 47 , 27 , 'Music' ), 
 ( 50 , 28 , 'Music' ), 
 ( 38 , 29 , 'Music' ), 
 ( 8 , 30 , 'Music' ), 
 ( 34 , 31 , 'Music' ), 
 ( 2 , 32 , 'Music' ), 
 ( 35 , 33 , 'Music' ), 
 ( 20 , 34 , 'Music' ), 
 ( 42 , 35 , 'Music' ), 
 ( 32 , 36 , 'Music' ), 
 ( 15 , 37 , 'Music' ), 
 ( 32 , 38 , 'Music' ), 
 ( 42 , 39 , 'Music' ), 
 ( 30 , 40 , 'Music' ), 
 ( 16 , 41 , 'Music' ), 
 ( 26 , 42 , 'Music' ), 
 ( 26 , 43 , 'Music' ), 
 ( 33 , 44 , 'Music' ), 
 ( 34 , 45 , 'Music' ), 
 ( 1 , 46 , 'Music' ), 
 ( 42 , 47 , 'Music' ), 
 ( 29 , 48 , 'Music' ), 
 ( 46 , 49 , 'Music' ), 
 ( 5 , 50 , 'Music' ), 

 ( 11 , 1 , 'Cameraworker' ), 
 ( 35 , 2 , 'Cameraworker' ), 
 ( 15 , 3 , 'Cameraworker' ), 
 ( 11 , 4 , 'Cameraworker' ), 
 ( 26 , 5 , 'Cameraworker' ), 
 ( 38 , 6 , 'Cameraworker' ), 
 ( 3 , 7 , 'Cameraworker' ), 
 ( 4 , 8 , 'Cameraworker' ), 
 ( 10 , 9 , 'Cameraworker' ), 
 ( 17 , 10 , 'Cameraworker' ), 
 ( 35 , 11 , 'Cameraworker' ), 
 ( 44 , 12 , 'Cameraworker' ), 
 ( 34 , 13 , 'Cameraworker' ), 
 ( 34 , 14 , 'Cameraworker' ), 
 ( 12 , 15 , 'Cameraworker' ), 
 ( 32 , 16 , 'Cameraworker' ), 
 ( 29 , 17 , 'Cameraworker' ), 
 ( 47 , 18 , 'Cameraworker' ), 
 ( 7 , 19 , 'Cameraworker' ), 
 ( 26 , 20 , 'Cameraworker' ), 
 ( 30 , 21 , 'Cameraworker' ), 
 ( 31 , 22 , 'Cameraworker' ), 
 ( 1 , 23 , 'Cameraworker' ), 
 ( 8 , 24 , 'Cameraworker' ), 
 ( 6 , 25 , 'Cameraworker' ), 
 ( 33 , 26 , 'Cameraworker' ), 
 ( 15 , 27 , 'Cameraworker' ), 
 ( 29 , 28 , 'Cameraworker' ), 
 ( 45 , 29 , 'Cameraworker' ), 
 ( 3 , 30 , 'Cameraworker' ), 
 ( 35 , 31 , 'Cameraworker' ), 
 ( 29 , 32 , 'Cameraworker' ), 
 ( 2 , 33 , 'Cameraworker' ), 
 ( 40 , 34 , 'Cameraworker' ), 
 ( 25 , 35 , 'Cameraworker' ), 
 ( 34 , 36 , 'Cameraworker' ), 
 ( 9 , 37 , 'Cameraworker' ), 
 ( 49 , 38 , 'Cameraworker' ), 
 ( 41 , 39 , 'Cameraworker' ), 
 ( 35 , 40 , 'Cameraworker' ), 
 ( 11 , 41 , 'Cameraworker' ), 
 ( 18 , 42 , 'Cameraworker' ), 
 ( 44 , 43 , 'Cameraworker' ), 
 ( 25 , 44 , 'Cameraworker' ), 
 ( 50 , 45 , 'Cameraworker' ), 
 ( 11 , 46 , 'Cameraworker' ), 
 ( 20 , 47 , 'Cameraworker' ), 
 ( 7 , 48 , 'Cameraworker' ), 
 ( 28 , 49 , 'Cameraworker' ), 
 ( 50 , 50 , 'Cameraworker' ), 

 ( 41 , 9 , 'Actor' ), 
 ( 36 , 10 , 'Actor' ), 
 ( 22 , 11 , 'Actor' ), 
 ( 37 , 12 , 'Actor' ), 
 ( 28 , 13 , 'Actor' ), 
 ( 15 , 14 , 'Actor' ), 
 ( 30 , 15 , 'Actor' ), 
 ( 31 , 16 , 'Actor' ), 
 ( 38 , 17 , 'Actor' ), 
 ( 30 , 18 , 'Actor' ), 
 ( 50 , 19 , 'Actor' ), 
 ( 36 , 20 , 'Actor' ), 
 ( 43 , 21 , 'Actor' ), 
 ( 49 , 22 , 'Actor' ), 
 ( 30 , 23 , 'Actor' ), 
 ( 4 , 24 , 'Actor' ), 
 ( 8 , 25 , 'Actor' ), 
 ( 16 , 26 , 'Actor' ), 
 ( 22 , 27 , 'Actor' ), 
 ( 27 , 28 , 'Actor' ), 
 ( 30 , 29 , 'Actor' ), 
 ( 36 , 30 , 'Actor' ), 
 ( 43 , 31 , 'Actor' ), 
 ( 34 , 32 , 'Actor' ), 
 ( 22 , 33 , 'Actor' ), 
 ( 21 , 34 , 'Actor' ), 
 ( 9 , 35 , 'Actor' ), 
 ( 35 , 36 , 'Actor' ), 
 ( 30 , 37 , 'Actor' ), 
 ( 11 , 38 , 'Actor' ), 
 ( 40 , 39 , 'Actor' ), 
 ( 41 , 40 , 'Actor' ), 
 ( 27 , 41 , 'Actor' ), 
 ( 11 , 42 , 'Actor' ), 
 ( 48 , 43 , 'Actor' ), 
 ( 19 , 44 , 'Actor' ), 
 ( 33 , 45 , 'Actor' ), 
 ( 40 , 46 , 'Actor' ), 
 ( 17 , 47 , 'Actor' ), 
 ( 40 , 48 , 'Actor' ), 
 ( 37 , 49 , 'Actor' ), 
 ( 44 , 50 , 'Actor' ), 
 ( 18 , 1 , 'Actor' ), 
 ( 34 , 2 , 'Actor' ), 
 ( 32 , 3 , 'Actor' ), 
 ( 49 , 4 , 'Actor' ), 
 ( 19 , 5 , 'Actor' ), 
 ( 30 , 6 , 'Actor' ), 
 ( 22 , 7 , 'Actor' ), 
 ( 44 , 8 , 'Actor' ), 
 ( 14 , 9 , 'Actor' ), 
 ( 19 , 10 , 'Actor' ), 
 ( 13 , 11 , 'Actor' ), 
 ( 26 , 12 , 'Actor' ), 
 ( 47 , 13 , 'Actor' ), 
 ( 9 , 14 , 'Actor' ), 
 ( 17 , 15 , 'Actor' ), 
 ( 23 , 16 , 'Actor' ), 
 ( 5 , 17 , 'Actor' ), 
 ( 34 , 18 , 'Actor' ), 
 ( 8 , 19 , 'Actor' ), 
 ( 8 , 20 , 'Actor' ), 
 ( 19 , 21 , 'Actor' ), 
 ( 32 , 22 , 'Actor' ), 
 ( 13 , 23 , 'Actor' ), 
 ( 50 , 24 , 'Actor' ), 
 ( 50 , 25 , 'Actor' ), 
 ( 7 , 26 , 'Actor' ), 
 ( 21 , 27 , 'Actor' ), 
 ( 43 , 28 , 'Actor' ), 
 ( 2 , 29 , 'Actor' ), 
 ( 16 , 30 , 'Actor' ), 
 ( 14 , 31 , 'Actor' ), 
 ( 6 , 32 , 'Actor' ), 
 ( 42 , 33 , 'Actor' ), 
 ( 23 , 34 , 'Actor' ), 
 ( 45 , 35 , 'Actor' ), 
 ( 18 , 36 , 'Actor' ), 
 ( 13 , 37 , 'Actor' ), 
 ( 12 , 38 , 'Actor' ), 
 ( 17 , 39 , 'Actor' ), 
 ( 30 , 40 , 'Actor' ), 
 ( 12 , 41 , 'Actor' ), 
 ( 17 , 42 , 'Actor' ), 
 ( 34 , 43 , 'Actor' ), 
 ( 14 , 44 , 'Actor' ), 
 ( 16 , 45 , 'Actor' ), 
 ( 26 , 46 , 'Actor' ), 
 ( 34 , 47 , 'Actor' ), 
 ( 45 , 48 , 'Actor' ), 
 ( 1 , 49 , 'Actor' ), 
 ( 16 , 50 , 'Actor' ), 

 ( 23 , 1 , 'Others' ), 
 ( 16 , 2 , 'Others' ), 
 ( 7 , 3 , 'Others' ), 
 ( 1 , 4 , 'Others' ), 
 ( 26 , 5 , 'Others' ), 
 ( 6 , 6 , 'Others' ), 
 ( 15 , 7 , 'Others' ), 
 ( 5 , 8 , 'Others' ), 
 ( 25 , 9 , 'Others' ), 
 ( 3 , 10 , 'Others' ), 
 ( 30 , 11 , 'Others' ), 
 ( 40 , 12 , 'Others' ), 
 ( 35 , 13 , 'Others' ), 
 ( 26 , 14 , 'Others' ), 
 ( 48 , 15 , 'Others' ), 
 ( 30 , 16 , 'Others' ), 
 ( 10 , 17 , 'Others' ), 
 ( 15 , 18 , 'Others' ), 
 ( 50 , 19 , 'Others' ), 
 ( 10 , 20 , 'Others' ), 
 ( 2 , 21 , 'Others' ), 
 ( 23 , 22 , 'Others' ), 
 ( 1 , 23 , 'Others' ), 
 ( 26 , 24 , 'Others' ), 
 ( 33 , 25 , 'Others' ), 
 ( 50 , 26 , 'Others' ), 
 ( 21 , 27 , 'Others' ), 
 ( 2 , 28 , 'Others' ), 
 ( 40 , 29 , 'Others' ), 
 ( 4 , 30 , 'Others' ), 
 ( 42 , 31 , 'Others' ), 
 ( 49 , 32 , 'Others' ), 
 ( 24 , 33 , 'Others' ), 
 ( 27 , 34 , 'Others' ), 
 ( 17 , 35 , 'Others' ), 
 ( 1 , 36 , 'Others' ), 
 ( 30 , 37 , 'Others' ), 
 ( 39 , 38 , 'Others' ), 
 ( 24 , 39 , 'Others' ), 
 ( 27 , 40 , 'Others' ), 
 ( 49 , 41 , 'Others' ), 
 ( 48 , 42 , 'Others' ), 
 ( 47 , 43 , 'Others' ), 
 ( 37 , 44 , 'Others' ), 
 ( 7 , 45 , 'Others' ), 
 ( 11 , 46 , 'Others' ), 
 ( 33 , 47 , 'Others' ), 
 ( 25 , 48 , 'Others' ), 
 ( 4 , 49 , 'Others' ), 
 ( 39 , 50 , 'Others' ), 
 ( 44 , 1 , 'Others' ), 
 ( 32 , 2 , 'Others' ), 
 ( 26 , 3 , 'Others' ), 
 ( 15 , 4 , 'Others' ), 
 ( 26 , 5 , 'Others' ), 
 ( 14 , 6 , 'Others' ), 
 ( 31 , 7 , 'Others' ), 
 ( 15 , 8 , 'Others' ), 
 ( 38 , 9 , 'Others' ), 
 ( 30 , 10 , 'Others' ), 
 ( 14 , 11 , 'Others' ), 
 ( 26 , 12 , 'Others' ), 
 ( 32 , 13 , 'Others' ), 
 ( 25 , 14 , 'Others' ), 
 ( 22 , 15 , 'Others' ), 
 ( 49 , 16 , 'Others' ), 
 ( 10 , 17 , 'Others' ), 
 ( 47 , 18 , 'Others' ), 
 ( 21 , 19 , 'Others' ), 
 ( 15 , 20 , 'Others' ), 
 ( 32 , 21 , 'Others' ), 
 ( 26 , 22 , 'Others' ), 
 ( 5 , 23 , 'Others' ), 
 ( 1 , 24 , 'Others' ), 
 ( 31 , 25 , 'Others' ), 
 ( 44 , 26 , 'Others' ), 
 ( 27 , 27 , 'Others' ), 
 ( 10 , 28 , 'Others' ), 
 ( 9 , 29 , 'Others' ), 
 ( 50 , 30 , 'Others' ), 
 ( 12 , 31 , 'Others' ), 
 ( 7 , 32 , 'Others' ), 
 ( 8 , 33 , 'Others' ), 
 ( 39 , 34 , 'Others' ), 
 ( 27 , 35 , 'Others' ), 
 ( 29 , 36 , 'Others' ), 
 ( 25 , 37 , 'Others' ), 
 ( 18 , 38 , 'Others' ), 
 ( 27 , 39 , 'Others' ), 
 ( 34 , 40 , 'Others' ), 
 ( 32 , 41 , 'Others' ), 
 ( 4 , 42 , 'Others' ), 
 ( 25 , 43 , 'Others' ), 
 ( 41 , 44 , 'Others' ), 
 ( 39 , 45 , 'Others' ), 
 ( 23 , 46 , 'Others' ), 
 ( 27 , 47 , 'Others' ), 
 ( 24 , 48 , 'Others' ), 
 ( 16 , 49 , 'Others' ), 
 ( 39 , 50 , 'Others' );

 INSERT INTO crew VALUES 
 ( 27 , 1 , 'Actor' , 'Jan'), 
 ( 3 , 2 , 'Actor' , 'John'), 
 ( 23 , 3 , 'Actor' , 'Hans'), 
 ( 1 , 4 , 'Actor' , 'Elon Musk'), 
 ( 24 , 5 , 'Actor' , 'Tree'), 
 ( 39 , 6 , 'Actor' , 'Someone important'), 
 ( 1 , 7 , 'Actor' , 'Not important'), 
 ( 24 , 8 , 'Actor' , 'Main character');

INSERT INTO person_ratings VALUES
 ( 27 , 'achana6' , 7 ), 
 ( 34 , 'Wayna31' , 6 ), 
 ( 16 , 'Enosh2' , 1 ), 
 ( 10 , 'Govinda2' , 5 ), 
 ( 35 , 'Jagdishyi' , 6 ), 
 ( 26 , 'Reynard' , 3 ), 
 ( 40 , 'Sabah7' , 5 ), 
 ( 20 , 'Sinta5' , 10 ), 
 ( 34 , 'Kadek78' , 4 ), 
 ( 43 , 'Srinivas4368' , 5 ), 
 ( 39 , 'Morpheus2' , 7 ), 
 ( 40 , 'Murtada3' , 1 ), 
 ( 45 , 'Ruaraidh' , 4 ), 
 ( 31 , 'Shota34' , 3 ), 
 ( 5 , 'Loke2' , 10 ), 
 ( 14 , 'Drest36423' , 3 ), 
 ( 33 , 'Silvia' , 10 ), 
 ( 35 , 'Elon3' , 1 ), 
 ( 36 , 'Tabatha' , 2 ), 
 ( 15 , 'Michal42' , 6 ), 
 ( 41 , 'Chiyembekezo' , 3 ), 
 ( 27 , 'Dag' , 9 ), 
 ( 32 , 'Arie' , 5 ), 
 ( 8 , 'Fulgenzio5' , 2 ), 
 ( 46 , 'Audhild2' , 1 ), 
 ( 13 , 'Montana' , 10 ), 
 ( 36 , 'Minos' , 10 ), 
 ( 45 , 'Arnulf' , 3 ), 
 ( 48 , 'Giselmund' , 3 ), 
 ( 28 , 'Mercedes5456' , 7 ), 
 ( 41 , 'Alban' , 4 ), 
 ( 6 , 'Octavius' , 9 ), 
 ( 35 , 'Aurelius4' , 8 ), 
 ( 50 , 'Kip' , 1 ), 
 ( 31 , 'EvyDinesh' , 1 ), 
 ( 2 , 'Arie50' , 10 ), 
 ( 38 , 'Raj1' , 5 ), 
 ( 18 , 'Enric8' , 5 ), 
 ( 32 , 'Nereus3' , 3 ), 
 ( 1 , 'Imogen29' , 1 ), 
 ( 44 , 'Iracema' , 1 ), 
 ( 32 , 'Tanja643' , 6 ), 
 ( 11 , 'Ratnaq8' , 5 ), 
 ( 46 , 'Dharma36' , 7 ), 
 ( 24 , 'Kaija' , 3 ), 
 ( 16 , 'Thancmar53' , 8 ), 
 ( 9 , 'Valentin3' , 4 ), 
 ( 38 , 'Sergius' , 5 ), 
 ( 42 , 'Philippos2' , 6 ), 
 ( 44 , 'Belshatzzar3' , 2 ), 
 ( 1 , 'achana6' , 7 ), 
 ( 18 , 'Wayna31' , 1 ), 
 ( 46 , 'Enosh2' , 6 ), 
 ( 26 , 'Govinda2' , 8 ), 
 ( 26 , 'Jagdishyi' , 8 ), 
 ( 25 , 'Reynard' , 10 ), 
 ( 27 , 'Sabah7' , 2 ), 
 ( 42 , 'Sinta5' , 6 ), 
 ( 35 , 'Kadek78' , 4 ), 
 ( 3 , 'Srinivas4368' , 2 ), 
 ( 22 , 'Morpheus2' , 8 ), 
 ( 1 , 'Murtada3' , 4 ), 
 ( 14 , 'Ruaraidh' , 8 ), 
 ( 40 , 'Shota34' , 10 ), 
 ( 23 , 'Loke2' , 3 ), 
 ( 2 , 'Drest36423' , 9 ), 
 ( 11 , 'Silvia' , 1 ), 
 ( 25 , 'Elon3' , 10 ), 
 ( 35 , 'Tabatha' , 3 ), 
 ( 5 , 'Michal42' , 2 ), 
 ( 15 , 'Chiyembekezo' , 9 ), 
 ( 28 , 'Dag' , 8 ), 
 ( 43 , 'Arie' , 10 ), 
 ( 34 , 'Fulgenzio5' , 8 ), 
 ( 22 , 'Audhild2' , 8 ), 
 ( 28 , 'Montana' , 3 ), 
 ( 49 , 'Minos' , 9 ), 
 ( 41 , 'Arnulf' , 9 ), 
 ( 13 , 'Giselmund' , 5 ), 
 ( 4 , 'Mercedes5456' , 7 ), 
 ( 22 , 'Alban' , 2 ), 
 ( 48 , 'Octavius' , 6 ), 
 ( 30 , 'Aurelius4' , 6 ), 
 ( 42 , 'Kip' , 9 ), 
 ( 13 , 'EvyDinesh' , 3 ), 
 ( 42 , 'Arie50' , 7 ), 
 ( 26 , 'Raj1' , 1 ), 
 ( 4 , 'Enric8' , 8 ), 
 ( 21 , 'Nereus3' , 5 ), 
 ( 45 , 'Imogen29' , 8 ), 
 ( 46 , 'Iracema' , 2 ), 
 ( 24 , 'Tanja643' , 5 ), 
 ( 7 , 'Ratnaq8' , 4 ), 
 ( 13 , 'Dharma36' , 7 ), 
 ( 44 , 'Kaija' , 2 ), 
 ( 48 , 'Thancmar53' , 1 ), 
 ( 14 , 'Valentin3' , 4 ), 
 ( 27 , 'Sergius' , 8 ), 
 ( 43 , 'Philippos2' , 8 ), 
 ( 16 , 'Belshatzzar3' , 10 ), 
 ( 46 , 'achana6' , 9 ), 
 ( 47 , 'Wayna31' , 7 ), 
 ( 6 , 'Enosh2' , 2 ), 
 ( 18 , 'Govinda2' , 6 ), 
 ( 24 , 'Jagdishyi' , 4 ), 
 ( 35 , 'Reynard' , 9 ), 
 ( 32 , 'Sabah7' , 10 ), 
 ( 31 , 'Sinta5' , 9 ), 
 ( 14 , 'Srinivas4368' , 3 ), 
 ( 28 , 'Morpheus2' , 6 ), 
 ( 41 , 'Murtada3' , 3 ), 
 ( 23 , 'Shota34' , 1 ), 
 ( 9 , 'Loke2' , 4 ), 
 ( 4 , 'Drest36423' , 6 ), 
 ( 31 , 'Silvia' , 3 ), 
 ( 28 , 'Elon3' , 8 ), 
 ( 21 , 'Tabatha' , 5 ), 
 ( 23 , 'Michal42' , 9 ), 
 ( 11 , 'Chiyembekezo' , 7 ), 
 ( 20 , 'Dag' , 9 ), 
 ( 20 , 'Arie' , 1 ), 
 ( 33 , 'Fulgenzio5' , 6 ), 
 ( 34 , 'Audhild2' , 7 ), 
 ( 23 , 'Montana' , 3 ), 
 ( 1 , 'Minos' , 6 ), 
 ( 6 , 'Arnulf' , 2 ), 
 ( 41 , 'Giselmund' , 7 ), 
 ( 23 , 'Mercedes5456' , 1 ), 
 ( 31 , 'Alban' , 2 ), 
 ( 20 , 'Aurelius4' , 7 ), 
 ( 46 , 'Kip' , 6 ), 
 ( 6 , 'EvyDinesh' , 10 ), 
 ( 28 , 'Arie50' , 6 ), 
 ( 42 , 'Raj1' , 10 ), 
 ( 7 , 'Enric8' , 5 ), 
 ( 44 , 'Nereus3' , 8 ), 
 ( 4 , 'Imogen29' , 4 ), 
 ( 27 , 'Iracema' , 3 ), 
 ( 20 , 'Tanja643' , 6 ), 
 ( 17 , 'Ratnaq8' , 4 ), 
 ( 41 , 'Dharma36' , 5 ), 
 ( 45 , 'Kaija' , 4 ), 
 ( 17 , 'Thancmar53' , 7 ), 
 ( 24 , 'Valentin3' , 8 ), 
 ( 30 , 'Sergius' , 4 ), 
 ( 9 , 'Philippos2' , 4 ), 
 ( 49 , 'Belshatzzar3' , 1 ), 
 ( 23 , 'achana6' , 3 ), 
 ( 50 , 'Wayna31' , 1 ), 
 ( 17 , 'Enosh2' , 1 ), 
 ( 34 , 'Govinda2' , 4 ), 
 ( 30 , 'Jagdishyi' , 4 ), 
 ( 49 , 'Sabah7' , 9 ), 
 ( 18 , 'Sinta5' , 5 ), 
 ( 24 , 'Kadek78' , 1 ), 
 ( 49 , 'Srinivas4368' , 3 ), 
 ( 29 , 'Morpheus2' , 3 ), 
 ( 34 , 'Murtada3' , 8 ), 
 ( 46 , 'Ruaraidh' , 10 ), 
 ( 4 , 'Shota34' , 9 ), 
 ( 28 , 'Loke2' , 5 ), 
 ( 13 , 'Drest36423' , 6 ), 
 ( 12 , 'Silvia' , 8 ), 
 ( 49 , 'Elon3' , 10 ), 
 ( 38 , 'Tabatha' , 1 ), 
 ( 22 , 'Michal42' , 7 ), 
 ( 30 , 'Chiyembekezo' , 8 ), 
 ( 14 , 'Dag' , 10 ), 
 ( 9 , 'Fulgenzio5' , 7 ), 
 ( 45 , 'Audhild2' , 8 ), 
 ( 27 , 'Montana' , 5 ), 
 ( 12 , 'Minos' , 5 ), 
 ( 37 , 'Arnulf' , 7 ), 
 ( 44 , 'Giselmund' , 7 ), 
 ( 25 , 'Mercedes5456' , 7 ), 
 ( 23 , 'Alban' , 4 ), 
 ( 15 , 'Octavius' , 3 ), 
 ( 18 , 'Aurelius4' , 1 ), 
 ( 1 , 'Kip' , 4 ), 
 ( 25 , 'EvyDinesh' , 10 ), 
 ( 28 , 'Raj1' , 4 ), 
 ( 44 , 'Enric8' , 7 ), 
 ( 50 , 'Nereus3' , 6 ), 
 ( 37 , 'Imogen29' , 2 ), 
 ( 11 , 'Iracema' , 2 ), 
 ( 27 , 'Tanja643' , 2 ), 
 ( 26 , 'Ratnaq8' , 7 ), 
 ( 22 , 'Dharma36' , 1 ), 
 ( 18 , 'Kaija' , 6 ), 
 ( 37 , 'Thancmar53' , 2 ), 
 ( 21 , 'Valentin3' , 5 ), 
 ( 34 , 'Sergius' , 9 ), 
 ( 26 , 'Philippos2' , 4 ), 
 ( 48 , 'Belshatzzar3' , 2 ), 
 ( 28 , 'achana6' , 2 ), 
 ( 33 , 'Wayna31' , 8 ), 
 ( 20 , 'Enosh2' , 3 ), 
 ( 9 , 'Govinda2' , 2 ), 
 ( 17 , 'Jagdishyi' , 4 ), 
 ( 14 , 'Reynard' , 3 ), 
 ( 38 , 'Sabah7' , 3 ), 
 ( 40 , 'Sinta5' , 4 ), 
 ( 7 , 'Kadek78' , 3 ), 
 ( 34 , 'Srinivas4368' , 7 ), 
 ( 26 , 'Morpheus2' , 1 ), 
 ( 48 , 'Murtada3' , 1 ), 
 ( 16 , 'Ruaraidh' , 8 ), 
 ( 13 , 'Shota34' , 4 ), 
 ( 10 , 'Loke2' , 3 ), 
 ( 37 , 'Drest36423' , 10 ), 
 ( 15 , 'Silvia' , 4 ), 
 ( 42 , 'Tabatha' , 8 ), 
 ( 24 , 'Michal42' , 4 ), 
 ( 4 , 'Chiyembekezo' , 2 ), 
 ( 41 , 'Dag' , 5 ), 
 ( 13 , 'Arie' , 6 ), 
 ( 2 , 'Fulgenzio5' , 2 ), 
 ( 7 , 'Audhild2' , 1 ), 
 ( 39 , 'Montana' , 3 ), 
 ( 17 , 'Minos' , 6 ), 
 ( 36 , 'Arnulf' , 4 ), 
 ( 6 , 'Giselmund' , 10 ), 
 ( 29 , 'Mercedes5456' , 9 ), 
 ( 1 , 'Alban' , 1 ), 
 ( 30 , 'Octavius' , 5 ), 
 ( 37 , 'Aurelius4' , 9 ), 
 ( 47 , 'Kip' , 4 ), 
 ( 18 , 'EvyDinesh' , 9 ), 
 ( 33 , 'Arie50' , 5 ), 
 ( 45 , 'Raj1' , 6 ), 
 ( 22 , 'Enric8' , 5 ), 
 ( 45 , 'Nereus3' , 10 ), 
 ( 24 , 'Imogen29' , 1 ), 
 ( 12 , 'Iracema' , 6 ), 
 ( 48 , 'Tanja643' , 3 ), 
 ( 41 , 'Ratnaq8' , 1 ), 
 ( 19 , 'Dharma36' , 8 ), 
 ( 40 , 'Kaija' , 5 ), 
 ( 33 , 'Thancmar53' , 3 ), 
 ( 29 , 'Valentin3' , 2 ), 
 ( 14 , 'Sergius' , 6 ), 
 ( 10 , 'Philippos2' , 5 ), 
 ( 26 , 'Belshatzzar3' , 1 ), 
 ( 8 , 'achana6' , 1 ), 
 ( 29 , 'Wayna31' , 4 ), 
 ( 1 , 'Enosh2' , 10 ), 
 ( 31 , 'Govinda2' , 9 ), 
 ( 45 , 'Jagdishyi' , 7 ), 
 ( 12 , 'Reynard' , 5 ), 
 ( 10 , 'Sabah7' , 8 ), 
 ( 1 , 'Sinta5' , 4 ), 
 ( 39 , 'Kadek78' , 4 ), 
 ( 40 , 'Srinivas4368' , 10 ), 
 ( 31 , 'Murtada3' , 6 ), 
 ( 8 , 'Shota34' , 4 ), 
 ( 6 , 'Loke2' , 5 ), 
 ( 42 , 'Drest36423' , 2 ), 
 ( 25 , 'Silvia' , 10 ), 
 ( 6 , 'Elon3' , 8 ), 
 ( 26 , 'Tabatha' , 2 ), 
 ( 12 , 'Michal42' , 8 ), 
 ( 39 , 'Chiyembekezo' , 1 ), 
 ( 9 , 'Dag' , 2 ), 
 ( 9 , 'Arie' , 1 ), 
 ( 40 , 'Fulgenzio5' , 2 ), 
 ( 6 , 'Montana' , 10 ), 
 ( 6 , 'Minos' , 10 ), 
 ( 5 , 'Arnulf' , 10 ), 
 ( 7 , 'Giselmund' , 3 ), 
 ( 4 , 'Alban' , 7 ), 
 ( 21 , 'Octavius' , 9 ), 
 ( 4 , 'Aurelius4' , 6 ), 
 ( 40 , 'EvyDinesh' , 5 ), 
 ( 29 , 'Arie50' , 9 ), 
 ( 16 , 'Raj1' , 7 ), 
 ( 3 , 'Enric8' , 2 ), 
 ( 16 , 'Nereus3' , 8 ), 
 ( 15 , 'Imogen29' , 3 ), 
 ( 48 , 'Iracema' , 2 ), 
 ( 5 , 'Tanja643' , 7 ), 
 ( 50 , 'Dharma36' , 5 ), 
 ( 22 , 'Kaija' , 9 ), 
 ( 38 , 'Thancmar53' , 1 ), 
 ( 44 , 'Valentin3' , 7 ), 
 ( 4 , 'Sergius' , 1 ), 
 ( 17 , 'Philippos2' , 10 ), 
 ( 42 , 'Belshatzzar3' , 2 );


INSERT INTO person_ratings VALUES
 ( 22 , 'Imogen29' , 8 , 'H' ), 
 ( 23 , 'Tanja643' , 9 , 'H' ), 
 ( 25 , 'Belshatzzar3' , 7 , 'H' ), 
 ( 22 , 'Iracema' , 4 , 'H' ), 
 ( 22 , 'Raj1' , 1 , 'H' ), 
 ( 22 , 'Aurelius4' , 1 , 'H' ), 
 ( 22 , 'Minos' , 8 , 'H' ), 
 ( 22 , 'EvyDinesh' , 8 , 'H' );

--use
--while read line; do echo "INSERT INTO people_ratings VALUES(" $((RANDOM % 50 + 1)) "," $line "," $((RANDOM % 10 + 1)) ");"; done < a 
--to generate more (a file with logins)


INSERT INTO movie_awards VALUES(8, 'Picture', 'W', 1932);
INSERT INTO movie_awards VALUES(25, 'Picture', 'W', 2017);
INSERT INTO movie_awards VALUES(48, 'Picture', 'N', 2017);
INSERT INTO movie_awards VALUES(49, 'Picture', 'N', 2017);
INSERT INTO movie_awards VALUES(24, 'Picture', 'W', 2012);
INSERT INTO movie_awards VALUES(32, 'Picture', 'W', 1997);

INSERT INTO people_awards VALUES(2, 'Director', 'W');
INSERT INTO people_awards VALUES(41, 'Director', 'W');
INSERT INTO people_awards VALUES(9, 'Director', 'N');
INSERT INTO people_awards VALUES(20, 'Director', 'N');
INSERT INTO people_awards VALUES(28, 'Director', 'N');

--INDECIES
CREATE INDEX idx_awards_movie_id ON movie_awards ( movie_id );
CREATE INDEX idx_movie_awards_category ON movie_awards ( category );
CREATE INDEX idx_production_1_movie_id ON movie_genre ( movie_id );
CREATE INDEX idx_movie_genre_genre_id ON movie_genre ( genre );
CREATE INDEX idx_movie_language_movie_id ON movie_language ( movie_id );
CREATE INDEX idx_movie_language_language_id ON movie_language ( "language" );
CREATE INDEX idx_people_birth_country ON people ( birth_country );
CREATE INDEX idx_people_awards_person_id ON people_awards ( person_id );
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
CREATE INDEX idx_crew_person_id ON crew ( person_id );
CREATE INDEX idx_crew_movie_id ON crew ( movie_id );
CREATE INDEX idx_movie_ratings_user_id ON movie_ratings ( login );
CREATE INDEX idx_movie_ratings_movie_id ON movie_ratings ( movie_id );
CREATE INDEX idx_person_ratings_user_id ON person_ratings ( login );
CREATE INDEX idx_person_ratings_person_id ON person_ratings ( person_id );
CREATE INDEX idx_profession_person_id ON profession ( person_id );
CREATE INDEX idx_review_user_id ON review ( login );
CREATE INDEX idx_review_movie_id ON review ( movie_id );
