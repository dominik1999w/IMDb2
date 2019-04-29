CREATE SCHEMA imdb2;

DROP TABLE IF EXISTS awards CASCADE;
CREATE TABLE awards ( 
	award_id             SERIAL PRIMARY KEY,
	award_name           varchar  NOT NULL
 );

DROP TABLE IF EXISTS awards_categories_names CASCADE;
CREATE TABLE awards_categories_names ( 
	category_id          SERIAL PRIMARY KEY,
	category_name        varchar  NOT NULL ,
	movie_or_person      char(1)  NOT NULL ,

	CHECK (movie_or_person = 'M' OR movie_or_person = 'P' OR movie_or_person = 'B')
 );

COMMENT ON COLUMN awards_categories_names.movie_or_person IS 'M-movie P-person B-both';

DROP TABLE IF EXISTS movie CASCADE;
CREATE TABLE movie ( 
	movie_id             SERIAL PRIMARY KEY,
	title                varchar  NOT NULL ,
	release_date         date   ,
	runtime              interval  NOT NULL ,
	budget               integer   ,
	boxoffice     		 integer   ,
	opening_weekend_usa  integer   ,

	CHECK (boxoffice >= opening_weekend_usa)
 );

DROP TABLE IF EXISTS movie_awards CASCADE;
CREATE TABLE movie_awards ( 
	movie_id             integer  NOT NULL REFERENCES movie,
	awards_id            integer  NOT NULL REFERENCES awards,
	category_id          integer  REFERENCES awards_categories_names,
	nomination_or_win    char(1)  NOT NULL ,
	"year"               date  NOT NULL ,

	CHECK (nomination_or_win = 'N' OR nomination_or_win = 'W')
 );

DROP TABLE IF EXISTS movie_genre CASCADE;
CREATE TABLE movie_genre ( 
	movie_id             integer  NOT NULL REFERENCES movie,
	genre                varchar  NOT NULL 
 );

DROP TABLE IF EXISTS movie_language CASCADE;
CREATE TABLE movie_language ( 
	movie_id             integer  NOT NULL REFERENCES movie,
	"language"           integer  NOT NULL
);


DROP TABLE IF EXISTS movie_ranking CASCADE;
CREATE TABLE movie_ranking ( 
	movie_id             integer  PRIMARY KEY REFERENCES movie,
	score                numeric(4,2)  NOT NULL ,
	marks_quantity     integer  NOT NULL
 );


DROP TABLE IF EXISTS people CASCADE;
CREATE TABLE people ( 
	person_id            SERIAL PRIMARY KEY,
	first_name           varchar  NOT NULL ,
	last_name            varchar   ,
	age                  numeric(3)   ,
	born                 date   ,
	died                 date   ,
	alive                char(1)   ,
	birth_country        varchar   , 

	CHECK (alive = 'Y' OR alive = 'N') ,
	CHECK (age >= 0)
 );


DROP TABLE IF EXISTS people_awards CASCADE;
CREATE TABLE people_awards ( 
	person_id            integer  NOT NULL REFERENCES people,
	award_id             integer  NOT NULL REFERENCES awards,
	movie_id             integer   REFERENCES movie,
	category             integer   ,
	nomination_or_win    char(1)  NOT NULL ,
	"year"               date  NOT NULL , 

	CHECK (nomination_or_win = 'N' OR nomination_or_win = 'W') 
 );


DROP TABLE IF EXISTS people_ranking CASCADE;
CREATE TABLE people_ranking ( 
	person_id            integer  PRIMARY KEY REFERENCES people,
	score                numeric(4,2)   NOT NULL,
	marks_quantity       integer  NOT NULL 
 );

DROP TABLE IF EXISTS production CASCADE;
CREATE TABLE production ( 
	movie_id             integer  NOT NULL REFERENCES movie,
	country              varchar  NOT NULL  
 );

DROP TABLE IF EXISTS production_company CASCADE;
CREATE TABLE production_company ( 
	movie_id             integer  NOT NULL REFERENCES movie,
	company              varchar  NOT NULL 
 );

DROP TABLE IF EXISTS professions CASCADE;
CREATE TABLE professions ( 
	profession_id        SERIAL PRIMARY KEY,
	name                 varchar  NOT NULL 
 );

DROP TABLE IF EXISTS similar_movies CASCADE;
CREATE TABLE similar_movies ( 
	movie_id1            integer  NOT NULL REFERENCES movie,
	movie_id2            integer  NOT NULL REFERENCES movie 
 );

DROP TABLE IF EXISTS users CASCADE;
CREATE TABLE users ( 
	users_id             SERIAL PRIMARY KEY,
	login                varchar(17)  NOT NULL ,
	"password"           varchar(17)  NOT NULL ,
	nickname             varchar(17) DEFAULT user , 
	CONSTRAINT safety UNIQUE(login)
 );

DROP TABLE IF EXISTS watchlist CASCADE;
CREATE TABLE watchlist ( 
	user_id              integer  NOT NULL REFERENCES users,
	movie_id             integer  NOT NULL REFERENCES movie
 );


DROP TABLE IF EXISTS alternative_title CASCADE;
CREATE TABLE alternative_title ( 
	movie_id             integer  NOT NULL REFERENCES movie,
	movie_title          varchar  NOT NULL 
);


DROP TABLE IF EXISTS awards_categories CASCADE;
CREATE TABLE awards_categories ( 
	award_id             integer  NOT NULL REFERENCES awards,
	category_id          integer  NOT NULL REFERENCES awards_categories_names
);


DROP TABLE IF EXISTS citizenship CASCADE;
CREATE TABLE citizenship ( 
	person_id            integer  NOT NULL REFERENCES people,
	country              varchar  NOT NULL  
 );

CREATE INDEX idx_citizenship_person_id ON citizenship ( person_id );

DROP TABLE IF EXISTS crew CASCADE;
CREATE TABLE crew ( 
	person_id            integer  NOT NULL REFERENCES people,
	movie_id             integer  NOT NULL REFERENCES movie,
	"role"               varchar  NOT NULL ,
	"character/s"          varchar    
 );

COMMENT ON COLUMN crew."role" IS '//Add enum:\n{director,editor,music,cameraworker,writer,others}';

DROP TABLE IF EXISTS description CASCADE;
CREATE TABLE description ( 
	movie_id             integer  PRIMARY KEY REFERENCES movie,
	description          text  NOT NULL 
 );

DROP TABLE IF EXISTS movie_ratings CASCADE;
CREATE TABLE movie_ratings ( 
	movie_id             integer  REFERENCES movie,
	user_id              integer  REFERENCES users,
	mark                 numeric(2)  NOT NULL ,
	heart                char(1)  , 

	PRIMARY KEY(movie_id,user_id),
	CHECK(heart = 'H' OR heart IS NULL) ,
	CHECK(mark > 0 AND mark <= 10) 
 );


DROP TABLE IF EXISTS person_ratings CASCADE;
CREATE TABLE person_ratings ( 
	person_id            integer  REFERENCES people,
	user_id              integer  REFERENCES users,
	mark                 numeric(2)  NOT NULL ,
	heart                char(1)  , 

	PRIMARY KEY(person_id,user_id),
	CHECK(heart = 'H' OR heart IS NULL) ,
	CHECK(mark > 0 AND mark <= 10) 
 );

DROP TABLE IF EXISTS profession CASCADE;
CREATE TABLE profession ( 
	person_id            integer  NOT NULL REFERENCES people,
	profession           varchar  NOT NULL
);

DROP TABLE IF EXISTS review CASCADE;
CREATE TABLE review ( 
	user_id              integer  NOT NULL REFERENCES users,
	movie_id             integer  NOT NULL REFERENCES movie,
	review               text  NOT NULL ,

	PRIMARY KEY(movie_id,user_id) 
 );


CREATE INDEX idx_awards_movie_id ON movie_awards ( movie_id );

CREATE INDEX idx_movie_awards_awards_id ON movie_awards ( awards_id );

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

CREATE INDEX idx_crew_movie_id ON crew ( movie_id );

CREATE INDEX idx_movie_ratings_user_id ON movie_ratings ( user_id );

CREATE INDEX idx_movie_ratings_movie_id ON movie_ratings ( movie_id );

CREATE INDEX idx_person_ratings_user_id ON person_ratings ( user_id );

CREATE INDEX idx_person_ratings_person_id ON person_ratings ( person_id );

CREATE INDEX idx_profession_person_id ON profession ( person_id );

CREATE INDEX idx_profession_profession_id ON profession ( profession );

CREATE INDEX idx_review_user_id ON review ( user_id );

CREATE INDEX idx_review_movie_id ON review ( movie_id );
