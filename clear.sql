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
DROP VIEW IF EXISTS user_history;
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

