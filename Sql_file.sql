CREATE DATABASE amazon;
USE amazon;



-- Creating a main table.

CREATE TABLE amazon_db AS
SELECT t1.product_name, t1.manufacturer,
	-- return zero if the price field is empty and take out the '£' sign from this numbers
	IF(t1.price = '', 0 , CAST(REPLACE(t1.price, '£', '') AS DECIMAL(6,2))) price, 
	t1.number_of_reviews num_reviews, 
	-- review rating should be a number, not "4.3 out of 5 star".
	CAST(SUBSTRING_INDEX(t1.average_review_rating, ' ', 1) AS DECIMAL(2,1)) rate, 
	t1.number_of_answered_questions num_answered_questions,
	t2.product_description , 
	t3.product_information
FROM amazon1 t1
	JOIN amazon2_product_description t2 
		ON t1.uniq_id = t2.uniq_id 
	JOIN amazon3_product_information t3 
		ON t1.uniq_id = t3.uniq_id;




-- Split first two words of Product_name

WITH cte AS (SELECT product_name, substring_index(product_name, ' ', 1) first_word, 
	     substring_index(substring_index(product_name, ' ', 2),' ', -1) second_word 
	     FROM amazon1)
SELECT first_word, COUNT(first_word) FROM cte GROUP BY first_word ORDER BY COUNT(first_word) DESC;

-- Most repeated first words are the manufacturer's name




WITH cte AS (SELECT product_name, substring_index(product_name, ' ', 1) first_word, 
	     substring_index(substring_index(product_name, ' ', 2),' ', -1) second_word 
	     from amazon1)
Select second_word, count(second_word) from cte group by second_word order by count(second_word) DESC;

-- Most repeated second Words: Diecast, Wars, Toys, Puppet, birthday, Dolls, Games, etc





-- Small size Manufactureres / Shops

WITH CTE AS (SELECT manufacturer, count(product_name) cnt_prod, AVG(price) avg_price, FLOOR(AVG(num_reviews)) avg_cnt_reviews, AVG(rate) avg_rate, 
	     FLOOR(AVG(num_answered_questions)) num_questions, length(product_description), length(product_information)
	     FROM amazon_db 
	     -- I clean some data here in Where clause
	     WHERE manufacturer != 'unbekannt' and manufacturer != 'unknown' AND price != 0
	     GROUP BY manufacturer)
SELECT * FROM CTE WHERE cnt_prod <= 10;




-- Large size Manufactureres / Shops

WITH CTE AS (SELECT manufacturer, count(product_name) cnt_prod, AVG(price) avg_price, FLOOR(AVG(num_reviews)) avg_cnt_reviews, AVG(rate) avg_rate, 
	     FLOOR(AVG(num_answered_questions)) num_questions, length(product_description), length(product_information)
	     FROM amazon_db 
	     WHERE manufacturer != 'unbekannt' and manufacturer != 'unknown' AND price != 0
	     GROUP BY manufacturer)
SELECT * FROM CTE WHERE cnt_prod > 10;



-- Overall Statistic of my two categories of Manufacturers / Shops

WITH CTE AS (SELECT manufacturer, count(product_name) cnt_prod, AVG(price) avg_price, FLOOR(AVG(num_reviews)) avg_cnt_reviews, AVG(rate) avg_rate, 
	     FLOOR(AVG(num_answered_questions)) num_questions, length(product_description), length(product_information) 
	     FROM amazon_db 
	     WHERE manufacturer != 'unbekannt' AND manufacturer != 'unknown' AND price != 0
	     GROUP BY manufacturer)
SELECT COUNT(manufacturer), AVG(cnt_prod), AVG(avg_price), AVG(avg_rate) FROM CTE WHERE cnt_prod > 10;



WITH CTE AS (SELECT manufacturer, count(product_name) cnt_prod, AVG(price) avg_price, FLOOR(AVG(num_reviews)) avg_cnt_reviews, AVG(rate) avg_rate, 
	     FLOOR(AVG(num_answered_questions)) num_questions, length(product_description), length(product_information) 
	     FROM amazon_db WHERE manufacturer != 'unbekannt' and manufacturer != 'unknown' AND price != 0
	     GROUP BY manufacturer)
SELECT COUNT(manufacturer), AVG(cnt_prod), AVG(avg_price), AVG(avg_rate) FROM CTE WHERE cnt_prod <= 10;



-- Visualization in Tableau public (Link in Readme file)
