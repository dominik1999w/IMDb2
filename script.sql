--DROP SCHEMA
DROP SCHEMA IF EXISTS imdb2 CASCADE;
--DROP TYPES
DROP TYPE IF EXISTS role_type CASCADE;
DROP TYPE IF EXISTS genre_type CASCADE;

CREATE SCHEMA imdb2;

--DROP TABLES IF EXIST
DROP TABLE IF EXISTS awards CASCADE;
DROP TABLE IF EXISTS awards_categories_names CASCADE;
DROP TABLE IF EXISTS movie CASCADE;
DROP TABLE IF EXISTS movie_awards CASCADE;
DROP TABLE IF EXISTS movie_genre CASCADE;
DROP TABLE IF EXISTS movie_ranking CASCADE;
DROP TABLE IF EXISTS people CASCADE;
DROP TABLE IF EXISTS people_awards CASCADE;
DROP TABLE IF EXISTS people_ranking CASCADE;
DROP TABLE IF EXISTS production CASCADE;
DROP TABLE IF EXISTS movie_language CASCADE;
DROP TABLE IF EXISTS production_company CASCADE;
DROP TABLE IF EXISTS similar_movies CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS watchlist CASCADE;
DROP TABLE IF EXISTS alternative_title CASCADE;
DROP TABLE IF EXISTS awards_categories CASCADE;
DROP TABLE IF EXISTS citizenship CASCADE;
DROP TABLE IF EXISTS crew CASCADE;
DROP TABLE IF EXISTS description CASCADE;
DROP TABLE IF EXISTS movie_ratings CASCADE;
DROP TABLE IF EXISTS person_ratings CASCADE;
DROP TABLE IF EXISTS profession CASCADE;
DROP TABLE IF EXISTS review CASCADE;
----------------------------------------------
--DROP TRIGGERS IF EXIST]
DROP TRIGGER IF EXISTS is_alive ON people;
DROP TRIGGER IF EXISTS movie_awards_trig ON people;
DROP TRIGGER IF EXISTS people_awards_trig ON people;
----------------------------------------------

--MOVIE TABLES
CREATE TABLE movie ( 
	movie_id             SERIAL PRIMARY KEY,
	title                varchar  NOT NULL ,
	release_date         date   NOT NULL ,
	runtime              interval  NOT NULL ,
	budget               integer   ,
	boxoffice     		 integer   ,
	opening_weekend_usa  integer   ,

	CHECK (boxoffice >= opening_weekend_usa)
 );
CREATE TYPE genre_type AS ENUM('Action','Adventure','Animation','Biography','Comedy','Crime','Documentary','Drama','Family','Fantasy','Film Noir','History','Horror','Music','Musical','Mystery','Romance','Sci-Fi','Short','Sport','Superhero','Thriller','War','Western'); /*enum for genres*/
CREATE TABLE movie_genre ( 
	movie_id             integer  NOT NULL /*REFERENCES movie*/,
	genre                genre_type  NOT NULL 
 );
CREATE TABLE movie_language ( 
	movie_id             integer  NOT NULL /*REFERENCES movie*/,
	"language"           varchar  NOT NULL
);
CREATE TABLE movie_ranking ( 
	movie_id             integer  PRIMARY KEY /*REFERENCES movie*/,
	score                numeric(4,2)  NOT NULL ,
	marks_quantity       integer  NOT NULL
 );
CREATE TABLE similar_movies ( 
	movie_id1            integer  NOT NULL /*REFERENCES movie*/,
	movie_id2            integer  NOT NULL /*REFERENCES movie*/ 
 );
CREATE TABLE alternative_title ( 
	movie_id             integer  NOT NULL /*REFERENCES movie*/,
	movie_title          varchar  NOT NULL 
);
CREATE TABLE description ( 
	movie_id             integer  PRIMARY KEY /*REFERENCES movie*/,
	description          text  NOT NULL 
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
	country              varchar  NOT NULL  
 );

CREATE TABLE production_company ( 
	movie_id             integer  NOT NULL /*REFERENCES movie*/,
	company              varchar  NOT NULL 
 );
----------------------------------------------
--AWARDS TABLES
CREATE TABLE awards ( 
	award_name           varchar  PRIMARY KEY
 );
CREATE TABLE awards_categories_names ( 
	category_name        varchar  PRIMARY KEY ,
	movie_or_person      char(1)  NOT NULL ,

	CHECK (movie_or_person = 'M' OR movie_or_person = 'P' OR movie_or_person = 'B') /* M-movie P-person B-both */
 );
CREATE TABLE movie_awards ( 
	movie_id             integer  NOT NULL /*REFERENCES movie*/,
	award_name           varchar  NOT NULL /*REFERENCES awards*/,
	category_name        varchar  /*REFERENCES awards_categories_names*/,
	nomination_or_win    char(1)  NOT NULL ,
	"year"               date  NOT NULL ,

	CHECK (nomination_or_win = 'N' OR nomination_or_win = 'W')
 );
CREATE TABLE awards_categories ( 
	award_name           varchar  NOT NULL /*REFERENCES awards*/,
	category_name        varchar  NOT NULL /*REFERENCES awards_categories_names*/
);
CREATE TABLE people_awards ( 
	person_id            integer UNIQUE NOT NULL /*REFERENCES people*/,
	award_name           varchar  NOT NULL /*REFERENCES awards*/,
	movie_id             integer   /*REFERENCES movie*/,
	category             integer   ,
	nomination_or_win    char(1)  NOT NULL ,
	"year"               date  NOT NULL , 

	CHECK (nomination_or_win = 'N' OR nomination_or_win = 'W') /* N-nomination, W-win*/
 );
--PEOPLE TABLES
CREATE TABLE people ( 
	person_id            SERIAL PRIMARY KEY,
	first_name           varchar  NOT NULL ,
	last_name            varchar   ,
	age                  numeric(3)   ,
	born                 date   ,
	died                 date   ,
	alive                char(1)   ,
	birth_country        varchar   , 

	CHECK (alive = 'Y' OR alive = 'N' OR alive ='U') , /*Y-Yes, N-No, U-unknown */
	CHECK (age >= 0) ,
	CHECK (died < NOW()) ,
	CHECK (born < NOW()) ,
	CHECK (born < died)
 );
CREATE trigger updateCitizenship AFTER UPDATE ON PEOPLE
EXECUTE  PROCEDURE UPDATE citizenship SET  person_id=new.person_id;
    
CREATE TABLE people_ranking ( 
	person_id            integer  PRIMARY KEY /*REFERENCES people*/,
	score                numeric(4,2)   NOT NULL,
	marks_quantity       integer  NOT NULL 
 );
CREATE TABLE users ( 
	login                varchar(17)  PRIMARY KEY ,
	"password"           varchar(17)  NOT NULL ,
	nickname             varchar(17) DEFAULT user , 
	CONSTRAINT safety UNIQUE(login)
 );
CREATE TABLE watchlist ( 
	login                varchar(17)  NOT NULL /*REFERENCES users*/,
	movie_id             integer  NOT NULL /*REFERENCES movie*/
);
CREATE TABLE citizenship ( 
	person_id            integer  NOT NULL /*REFERENCES people*/,
	country              varchar  NOT NULL  
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
	profession           varchar  NOT NULL
);
CREATE TYPE role_type AS ENUM ('director','editor','music','cameraworker','writer','others'); /*ENUM FOR CREW*/
CREATE TABLE crew ( 
	person_id            integer  NOT NULL /*REFERENCES people*/,
	movie_id             integer  NOT NULL /*REFERENCES movie*/,
	"role"               role_type  NOT NULL ,
	"character/s"          varchar    
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
	IF movie_year(NEW.movie_id) + 1 > year THEN
		RAISE EXCEPTION 'Wrong year';
		RETURN NULL;
	END IF;
	IF (SELECT SUM(1) FROM awards_categories  
		WHERE award_name = NEW.award_name AND category_name = NEW.category_name) IS NOT NULL
		AND 
		(SELECT movie_or_person FROM awards_categories_names 
			WHERE category_name = NEW.category_name) ~ '[MB]' THEN
    	RETURN NEW;
    END IF;
    RAISE EXCEPTION 'Wrong award category';
    --ewentualnie kategoria się dodaje
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER movie_awards_trig BEFORE INSERT OR UPDATE ON movie_awards
FOR EACH ROW EXECUTE PROCEDURE movie_awards_trig();

----------------------------------------------

--awards people
CREATE OR REPLACE FUNCTION people_awards_trig() RETURNS trigger AS $$
BEGIN
	IF movie_year(NEW.born) > year THEN
		RAISE EXCEPTION 'Wrong year';
		RETURN NULL;
	END IF;
	IF (SELECT SUM(1) FROM awards_categories  
		WHERE award_name = NEW.award_name AND category_name = NEW.category_name) IS NOT NULL
		AND 
		(SELECT movie_or_person FROM awards_categories_names 
			WHERE category_name = NEW.category_name) ~ '[PB]' THEN
    	RETURN NEW;
    END IF;
    RAISE EXCEPTION 'Wrong award category';
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER people_awards_trig BEFORE INSERT OR UPDATE ON people_awards
FOR EACH ROW EXECUTE PROCEDURE people_awards_trig();

----------------------------------------------

----------------------------------------------




--CONSTRAINTS - FOREIGN KEYS
ALTER TABLE movie_genre ADD CONSTRAINT fk_production_1_movie FOREIGN KEY ( movie_id ) REFERENCES movie( movie_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE movie_language ADD CONSTRAINT fk_movie_language_movie FOREIGN KEY ( movie_id ) REFERENCES movie( movie_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE movie_ranking ADD CONSTRAINT fk_movie_ranking_movie FOREIGN KEY ( movie_id ) REFERENCES movie( movie_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE similar_movies ADD CONSTRAINT fk_similar_movies_movie FOREIGN KEY ( movie_id1 ) REFERENCES movie( movie_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE similar_movies ADD CONSTRAINT fk_similar_movies_movie_0 FOREIGN KEY ( movie_id2 ) REFERENCES movie( movie_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE alternative_title ADD CONSTRAINT fk_alternative_title_movie FOREIGN KEY ( movie_id ) REFERENCES movie( movie_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE description ADD CONSTRAINT fk_description_movie FOREIGN KEY ( movie_id ) REFERENCES movie( movie_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE movie_ratings ADD CONSTRAINT fk_movie_ratings_users FOREIGN KEY ( login ) REFERENCES users( login ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE movie_ratings ADD CONSTRAINT fk_movie_ratings_movie FOREIGN KEY ( movie_id ) REFERENCES movie( movie_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE review ADD CONSTRAINT fk_review_users FOREIGN KEY ( login ) REFERENCES users( login ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE review ADD CONSTRAINT fk_review_movie FOREIGN KEY ( movie_id ) REFERENCES movie( movie_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE production ADD CONSTRAINT fk_production_movie FOREIGN KEY ( movie_id ) REFERENCES movie( movie_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE production_company ADD CONSTRAINT fk_production_company_movie FOREIGN KEY ( movie_id ) REFERENCES movie( movie_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE movie_awards ADD CONSTRAINT fk_awards_movie FOREIGN KEY ( movie_id ) REFERENCES movie( movie_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE movie_awards ADD CONSTRAINT fk_movie_awards_awards FOREIGN KEY ( award_name ) REFERENCES awards( award_name ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE movie_awards ADD CONSTRAINT fk_movie_awards_awards_categories_names FOREIGN KEY ( category_name ) REFERENCES awards_categories_names( category_name ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE awards_categories ADD CONSTRAINT fk_awards_categories_awards FOREIGN KEY ( award_name ) REFERENCES awards( award_name ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE awards_categories ADD CONSTRAINT fk_awards_categories_awards_categories_names FOREIGN KEY ( category_name ) REFERENCES awards_categories_names( category_name ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE people_awards ADD CONSTRAINT fk_people_awards_people FOREIGN KEY ( person_id ) REFERENCES people( person_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE people_awards ADD CONSTRAINT fk_people_awards_movie FOREIGN KEY ( movie_id ) REFERENCES movie( movie_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE people_awards ADD CONSTRAINT fk_people_awards_awards FOREIGN KEY ( award_name ) REFERENCES awards( award_name ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE people_ranking ADD CONSTRAINT fk_people_ranking_people_awards FOREIGN KEY ( person_id ) REFERENCES people_awards( person_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE watchlist ADD CONSTRAINT fk_watchlist_movie FOREIGN KEY ( movie_id ) REFERENCES movie( movie_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE watchlist ADD CONSTRAINT fk_watchlist_users FOREIGN KEY ( login ) REFERENCES users( login ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE citizenship ADD CONSTRAINT fk_citizenship_people FOREIGN KEY ( person_id ) REFERENCES people( person_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE person_ratings ADD CONSTRAINT fk_person_ratings_users FOREIGN KEY ( login ) REFERENCES users( login ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE person_ratings ADD CONSTRAINT fk_person_ratings_people FOREIGN KEY ( person_id ) REFERENCES people( person_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE profession ADD CONSTRAINT fk_profession_people FOREIGN KEY ( person_id ) REFERENCES people( person_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE crew ADD CONSTRAINT fk_crew_people FOREIGN KEY ( person_id ) REFERENCES people( person_id ) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE crew ADD CONSTRAINT fk_crew_movie FOREIGN KEY ( movie_id ) REFERENCES movie( movie_id ) ON UPDATE CASCADE ON DELETE CASCADE;
----------------------------------------------

--SAMPLE DATA
INSERT INTO movie(title,release_date,runtime,budget,boxoffice,opening_weekend_usa)
SELECT
md5(random()::text), --for title
now() - round(random()*1000) * '1 day'::interval,--for release_date
random()*'1 hour'::interval+'1 hour'::interval,--for runtime
round(random()*700),--for budget
round(random()*700+71),--for boxoffice
round(random()*70)--for opening_weekend_usa
FROM generate_series(1,20);
INSERT INTO similar_movies VALUES(1,2);
INSERT INTO similar_movies VALUES(19,2);
INSERT INTO similar_movies VALUES(18,2);
INSERT INTO similar_movies VALUES(15,7);
INSERT INTO similar_movies VALUES(9,4);
INSERT INTO similar_movies VALUES(5,2);
INSERT INTO similar_movies VALUES(3,12);
INSERT INTO similar_movies VALUES(2,12);
INSERT INTO description VALUES(1,md5(random()::text));
INSERT INTO description VALUES(14,md5(random()::text));
INSERT INTO description VALUES(12,md5(random()::text));
INSERT INTO description VALUES(11,md5(random()::text));
INSERT INTO alternative_title VALUES(10,md5(random()::text));
INSERT INTO alternative_title VALUES(2,md5(random()::text));
INSERT INTO production VALUES(1,md5(random()::text));
INSERT INTO production VALUES(1,md5(random()::text));
INSERT INTO movie_language VALUES(1,md5(random()::text));
INSERT INTO movie_language VALUES(13,md5(random()::text));
INSERT INTO movie_genre VALUES(16,'Action');
INSERT INTO movie_genre VALUES(10,'Drama');
INSERT INTO production_company VALUES(1,md5(random()::text));
INSERT INTO production_company VALUES(10,md5(random()::text));
INSERT INTO users VALUES('asdd','zxc','ccc');
INSERT INTO users VALUES('zxcase','qwe','bbb');
INSERT INTO review VALUES('asdd',3,'xzzzzczxc');
INSERT INTO watchlist VALUES('zxcase',6);
INSERT INTO movie_ratings VALUES(8,'asdd',7,'H');

--INDECIES

CREATE INDEX idx_awards_movie_id ON movie_awards ( movie_id );

CREATE INDEX idx_movie_awards_awards_id ON movie_awards ( award_name );

CREATE INDEX idx_people_birth_country ON people ( birth_country );

CREATE INDEX idx_people_awards_movie_id ON people_awards ( movie_id );

CREATE INDEX idx_people_awards_award_id ON people_awards ( award_id );

CREATE INDEX idx_production_company_movie_id ON production_company ( movie_id );

CREATE INDEX idx_production_company_company_id ON production_company ( company );

CREATE INDEX idx_similar_movies_movie_id1 ON similar_movies ( movie_id1 );

CREATE INDEX idx_similar_movies_movie_id2 ON similar_movies ( movie_id2 );

CREATE INDEX idx_watchlist_movie_id ON watchlist ( movie_id );

CREATE INDEX idx_watchlist_user_id ON watchlist ( user_id );

CREATE INDEX idx_alternative_title_movie_id ON alternative_title ( movie_id );

CREATE INDEX idx_awards_categories_award_id ON awards_categories ( award_id );

CREATE INDEX idx_awards_categories_category_id ON awards_categories ( category_id );

CREATE INDEX idx_crew_person_id ON crew ( person_id );

CREATE INDEX idx_citizenship_person_id ON citizenship ( person_id );

CREATE INDEX idx_crew_movie_id ON crew ( movie_id );

CREATE INDEX idx_movie_ratings_user_id ON movie_ratings ( user_id );

CREATE INDEX idx_movie_ratings_movie_id ON movie_ratings ( movie_id );

CREATE INDEX idx_person_ratings_user_id ON person_ratings ( user_id );

CREATE INDEX idx_person_ratings_person_id ON person_ratings ( person_id );

CREATE INDEX idx_profession_person_id ON profession ( person_id );

CREATE INDEX idx_profession_profession_id ON profession ( profession );

CREATE INDEX idx_review_user_id ON review ( user_id );

CREATE INDEX idx_review_movie_id ON review ( movie_id );
