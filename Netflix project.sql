CREATE TABLE netflix (
show_id varchar(10),
type varchar(10),
title varchar(250),
director varchar(1000),
casts varchar(1000),
country varchar(1000),
date_added varchar(1000),
release_year int ,
rating varchar(1000),
duration varchar(1000),
listed_in varchar(1000),
description varchar(1000)
);

---	queries ---;

Select * from netflix;

Select * from netflix limit 5;

select count(*) from netflix;


-- Business Problems and Solution ---


-- 1. Count the Number of Movies vs TV Shows ---

Select * from netflix;
select type,count(*) from netflix group by type;


-- 2. Find the Most Common Rating for Movies and TV Shows --

Select * from netflix;

WITH RATINGCOUNTS AS (
SELECT 
    TYPE, RATING, COUNT(*) AS RATING_COUNT 
FROM NETFLIX 
GROUP by TYPE,RATING
),
RANKEDRATINGS AS
(
select type,rating,RATING_COUNT,
RANK() OVER(PARTITION  by TYPE ORDER by RATING_COUNT DESC) AS RANK 
FROM RATINGCOUNTS
)
SELECT TYPE ,RATING AS MOST_FREQUENT_RATING 
FROM RANKEDRATINGS
WHERE RANK = 1;

--- 2nd method ----
select type , rating from 
(
select type,rating, count(*), 
RANK() OVER(PARTITION BY TYPE ORDER BY COUNT(*) DESC ) AS RANKING 
FROM NETFLIX 
GROUP BY TYPE,RATING 
) AS T1

WHERE RANKING = 1


-- 3. List All Movies Released in a Specific Year (e.g., 2020) --
SELECT * FROM NETFLIX;

(SELECT TYPE,RELEASE_YEAR FROM NETFLIX
WHERE TYPE = 'Movie' AND RELEASE_YEAR = 2020);

SELECT COUNT(*)
FROM NETFLIX
WHERE TYPE = 'Movie' AND RELEASE_YEAR = 2020;

-- by using CTE ---

WITH filtered_movies AS (
    SELECT TYPE, RELEASE_YEAR
    FROM NETFLIX
    WHERE TYPE = 'Movie' AND RELEASE_YEAR = 2020
)
SELECT *, 
       (SELECT COUNT(*) FROM filtered_movies) AS total_count
FROM filtered_movies;


--- 4.Find the Top 5 Countries with the Most Content on Netflix ---

SELECT * FROM NETFLIX;

SELECT UNNEST (STRING_TO_ARRAY(COUNTRY,',')) AS NEW_COUNTRY,
-- UNNEST(...)	Converts the array into individual rows. 
-- So 'India, United States' becomes two rows: one for 'India' and one for ' United States'.
COUNT(SHOW_ID) AS TOTAL_CONTENT 
FROM NETFLIX WHERE COUNTRY IS NOT NULL
GROUP BY COUNTRY ORDER BY TOTAL_CONTENT DESC LIMIT 5;


-- 5. Identify the Longest Movie ---

SELECT * FROM NETFLIX;

select max(duration) from netflix WHERE TYPE = 'Movie';

SELECT  MAX(duration) FROM NETFLIX 
WHERE duration is not null and TYPE = 'Movie'  GROUP BY DURATION order by duration desc;
-- i don't know why it's getting wrong

SELECT
     show_id,
    duration
FROM netflix
WHERE type = 'Movie' and duration is not null
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;


-- 6. Find Content Added in the Last 5 Years --

SELECT * FROM NETFLIX;

SELECT DISTINCT(RELEASE_YEAR) 
FROM NETFLIX 
ORDER BY RELEASE_YEAR DESC 
LIMIT 5;

SELECT * FROM NETFLIX
WHERE TO_DATE(DATE_ADDED,'MONTH DD,YYYY')>=CURRENT_DATE - INTERVAL'5 YEARS';


-- 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka' --

SELECT * FROM NETFLIX;

SELECT * FROM (
    SELECT 
        *,
        UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix
) AS t 
WHERE DIRECTOR = 'Rajiv Chilaka';

-- Method 2 --
select type,director from netflix where director ='Rajiv Chilaka';

select * from netflix where director ='Rajiv Chilaka';


-- 8. List All TV Shows with More Than 5 Seasons --

select * from netflix;

select * from netflix where type = 'TV Show' AND SPLIT_PART(duration, ' ', 1)::INT > 5;

select type,duration from netflix where type = 'TV Show' AND SPLIT_PART(duration, ' ', 1)::INT > 5;

select type,duration from netflix where  SPLIT_PART(duration, ' ', 1)::INT > 5;

-- duration	A column (likely a string) that contains data like '90 min' or '1 Season'.
--SPLIT_PART(duration, ' ', 1)	Splits the duration string by space ' ' and takes the first part.
--For example:
--'90 min' → '90'
--'1 Season' → '1'
--::INT	Casts the result (which is a string) into an integer. So '90' becomes 90.


-- 9. Count the Number of Content Items in Each Genre --


select * from netflix;

SELECT UNNEST (STRING_TO_ARRAY(listed_in,',')) AS Genre,
-- UNNEST(...)	Converts the array into individual rows. 
-- So 'India, United States' becomes two rows: one for 'India' and one for ' United States'.
COUNT(*) AS TOTAL_CONTENT 
FROM NETFLIX WHERE listed_in IS NOT NULL
GROUP BY listed_in ORDER BY TOTAL_CONTENT DESC;

SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY 1 ORDER BY TOTAL_CONTENT DESC;


-- 10.Find each year and the average numbers of content release in India on netflix. --
-- return top 5 year with highest avg content release! --

select * from netflix;

SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;


-- 11. List All Movies that are Documentaries --

select * from netflix;

SELECT title,type, 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre  
From netflix 
where type = 'Movie' and listed_in = 'Documentaries';

-- 2nd Method ---

SELECT title,type,listed_in
FROM netflix
WHERE listed_in LIKE '%Documentaries';


-- 12. Find All Content Without a Director --

select * from netflix;

SELECT * 
FROM netflix
WHERE director IS NULL;


-- 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years --

select * from netflix;

SELECT * 
FROM netflix
WHERE casts LIKE '%Salman Khan%'
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;


-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India --

SELECT * FROM NETFLIX;

SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;


-- 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords --

SELECT * FROM NETFLIX;

SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;

-- Findings and Conclusion
--Content Distribution: The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
--Common Ratings: Insights into the most common ratings provide an understanding of the content's target audience.
--Geographical Insights: The top countries and the average content releases by India highlight regional content distribution.
--Content Categorization: Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.
--This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making. ---




