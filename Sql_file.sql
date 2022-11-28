CREATE DATABASE amazon;
USE amazon;

#### I create a table from all of the information that i want to use in this analysis and change some columns to formats that is better for calculation.
##### For example: i want to change the price column from text format to float format. First i have to take the pound sign out of it.
######## change average_review_rating from text to number: 4.0 

CREATE TABLE amazon_db AS
SELECT t1.product_name, t1.manufacturer, 
IF(t1.price = '', 0 , CAST(REPLACE(t1.price, '£', '') AS DECIMAL(6,2))) price, 
t1.number_of_reviews num_reviews, 
CAST(SUBSTRING_INDEX(t1.average_review_rating, ' ', 1) AS DECIMAL(2,1)) rate, 
t1.number_of_answered_questions num_answered_questions,
t2.product_description , 
t3.product_information
FROM amazon1 t1
JOIN amazon2_product_description t2 ON t1.uniq_id = t2.uniq_id 
JOIN amazon3_product_information t3 ON t1.uniq_id = t3.uniq_id;

#### First i will split the first two words of product_name column to see what is the most repeated words in the product_name so we can know them better

with cte as (SELECT product_name, substring_index(product_name, ' ', 1) first_word, 
					substring_index(substring_index(product_name, ' ', 2),' ', -1) second_word
			 from amazon1)
Select first_word, count(first_word) from cte group by first_word order by count(first_word) DESC;

##### What I found in first word repeated the most: Star, Oxford, Lego, Disney, playmobil, pokemon, Hornby, Hot, corgi, scalextric, 
##### Thomas, Schkeich, Melissa, Revell, Ravensburger, Marvel
##### #As we can see the first word of the title is the name of the brand in many cases and we can use the manufacturer column instead.

##### now group by second word
with cte as (SELECT product_name, substring_index(product_name, ' ', 1) first_word, 
					substring_index(substring_index(product_name, ' ', 2),' ', -1) second_word
			 from amazon1)
Select second_word, count(second_word) from cte group by second_word order by count(second_word) DESC;

##### What I found in second word repeated the most: Diecast, Wars, Toys, TOY, Puppet, birthday, Wheels, Dolls, Games, Pixar, Model etc

##### First i tried to analyze the whole table at once, but then realized it is better to divide it to two categories. Small and Big Manufacturers/Shops

#### Small size Manufactureres / Shops
WITH CTE AS (
SELECT manufacturer, count(product_name) cnt_prod, AVG(price) avg_price, FLOOR(AVG(num_reviews)) avg_cnt_reviews, AVG(rate) avg_rate, 
FLOOR(AVG(num_answered_questions)) num_questions, length(product_description), length(product_information) 
FROM amazon_db WHERE manufacturer != 'unbekannt' and manufacturer != 'unknown' AND price != 0
GROUP BY manufacturer)
SELECT * FROM CTE WHERE cnt_prod <= 10;

#### Large size Manufactureres / Shops
WITH CTE AS (
SELECT manufacturer, count(product_name) cnt_prod, AVG(price) avg_price, FLOOR(AVG(num_reviews)) avg_cnt_reviews, AVG(rate) avg_rate, 
FLOOR(AVG(num_answered_questions)) num_questions, length(product_description), length(product_information) 
FROM amazon_db WHERE manufacturer != 'unbekannt' and manufacturer != 'unknown' AND price != 0
GROUP BY manufacturer)
SELECT * FROM CTE WHERE cnt_prod > 10;

#### Overall Statistic of my two categories of Manufacturers / Shops
WITH CTE AS (
SELECT manufacturer, count(product_name) cnt_prod, AVG(price) avg_price, FLOOR(AVG(num_reviews)) avg_cnt_reviews, AVG(rate) avg_rate, 
FLOOR(AVG(num_answered_questions)) num_questions, length(product_description), length(product_information) 
FROM amazon_db WHERE manufacturer != 'unbekannt' and manufacturer != 'unknown' AND price != 0
GROUP BY manufacturer)
SELECT COUNT(manufacturer), AVG(cnt_prod), AVG(avg_price), AVG(avg_rate) FROM CTE WHERE cnt_prod > 10;

WITH CTE AS (
SELECT manufacturer, count(product_name) cnt_prod, AVG(price) avg_price, FLOOR(AVG(num_reviews)) avg_cnt_reviews, AVG(rate) avg_rate, 
FLOOR(AVG(num_answered_questions)) num_questions, length(product_description), length(product_information) 
FROM amazon_db WHERE manufacturer != 'unbekannt' and manufacturer != 'unknown' AND price != 0
GROUP BY manufacturer)
SELECT COUNT(manufacturer), AVG(cnt_prod), AVG(avg_price), AVG(avg_rate) FROM CTE WHERE cnt_prod <= 10;

### Visualization in Tableau public
