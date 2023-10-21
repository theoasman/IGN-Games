USE IGNGames

--DATA CLEANING:
--Opened in Excel, found no duplicate values. 
--Used COUNTBLANK function and found 36 blank values. All blank values were in the Genre column.
--Filled in the missing genres by doing research on the games.
--Condensed the genre list to just 20 genres instead of 112 genres. Kept old genres as "Sub-Genre".

--Removed 2 entries: 18490 (HTC Vibe) and 18533 (Oculus Rift) due to not being games but instead VR platforms.
--Changed the platform "New Nintendo 3DS" to "Nintendo 3DS" for cohesion in database.

--The Walking Dead Ep. 1 had an outlying release year of 1970, and there isn't another game released until 1996,
--showing it was clearly a mistake. I found the correct release date and changed it. 
--Then realized the same game/episode is only available on 1 platform, while the following episodes are available
--on 5 platforms. Therefore, I created 4 new entries for Ep. 1, adding on the missing platforms.
--These new entries have the same score as the original, as most games have the same score regardless of platform.
--The URLs are missing from these new entries as well, but I don't use them in the analysis.

--BASIC OVERVIEW: This is a basic overview of the dataset.
--How many games are in the dataset
SELECT COUNT(DISTINCT title) AS Number_of_Titles, COUNT(title) AS Number_of_Games
FROM ign
--What is the date range of the game releases in this dataset?
SELECT CONCAT(MIN(release_month), ' / ', MIN(release_day), ' / ', MIN(release_year)) AS Earliest_Game, 
CONCAT(MAX(release_month), ' / ', MAX(release_day), ' / ', MAX(release_year)) AS Latest_Game
FROM ign
--What are the available platforms?
SELECT DISTINCT platform
FROM ign
ORDER BY platform
--What are the available genres?
SELECT DISTINCT genre
FROM ign
ORDER BY genre
--What are the scores/ratings and their accompanying phrases?
SELECT score_phrase, score
FROM ign
GROUP BY score, score_phrase
ORDER BY score
--What are the top 10 games per platform?
SELECT platform, rank, title, score
FROM
(SELECT platform, RANK() OVER (PARTITION BY platform ORDER BY score DESC) AS rank, title, score
FROM ign) AS SubRanked
WHERE rank <= 10

--RATINGS/PLATFORM/GENRE/TEMPORAL ANALYSIS
--How many games per platform, ranked?
SELECT RANK() OVER (ORDER BY COUNT(title) DESC) AS Rank, platform, COUNT(title) AS Number_of_Games
FROM ign
GROUP BY platform
ORDER BY Number_of_Games DESC
--How many games per genre?
SELECT RANK() OVER (ORDER BY COUNT(genre) DESC) AS Rank, Genre, COUNT(Genre) AS Number_of_Games
FROM ign
GROUP BY Genre
--Average rating of games per platform
SELECT RANK() OVER (ORDER BY ROUND(AVG(score), 2) DESC) AS Rank, platform, ROUND(AVG(score), 2) AS Avg_Score
FROM ign
GROUP BY platform
ORDER BY Avg_Score DESC
--Average rating of games per genre
SELECT RANK() OVER (ORDER BY ROUND(AVG(score), 2) DESC) as Rank, genre, ROUND(AVG(score), 2) AS Avg_Score
FROM ign
GROUP BY genre
ORDER BY Avg_Score DESC
--Most popular genre per platform, as well as number of games per genres per platform
WITH Top_Genre AS(
	SELECT platform, genre, COUNT(genre) AS game_count, 
	RANK() OVER (PARTITION BY platform ORDER BY COUNT(genre) DESC) AS genre_rank
	FROM ign
	GROUP BY platform, genre)
SELECT platform, genre, game_count
FROM Top_Genre
WHERE genre_rank = 1
ORDER BY platform
--Popularity of genre changing over time
WITH RankedGames AS(
	SELECT release_year, genre, COUNT(title) as game_count, 
	RANK() OVER (PARTITION BY release_year ORDER BY COUNT(title) DESC) AS genre_rank
	FROM ign
	GROUP BY release_year, genre)
SELECT release_year, genre, game_count as game_count, genre_rank
FROM RankedGames
WHERE genre_rank IN (1, 2, 3)
ORDER BY release_year
--Game releases per year
SELECT release_year, COUNT(title) AS game_count
FROM ign
GROUP BY release_year
ORDER BY release_year
--What month had most game releases per year
WITH MonthGames AS(
	SELECT release_year, release_month, COUNT(title) as game_count, 
	RANK() OVER (PARTITION BY release_year ORDER BY COUNT(title) DESC) AS rnk
	FROM IGN
	GROUP BY release_year, release_month)
SELECT release_year, release_month, game_count
FROM MonthGames
WHERE rnk = 1
ORDER BY release_year