----CREATE DATABASE FoodserviceDB-----
CREATE DATABASE FoodserviceDB;

-----CONNECTING TO THE DATABASE FoodserviceDB---
USE FoodserviceDB
GO
----importation of resturant table csv-------
SELECT * FROM restaurants;


----Importatation of consumer table-----

SELECT * FROM consumers;

---------Importation of ratings table
SELECT * FROM ratings

---Importation of Restaurant_Cuisines

SELECT * FROM Restaurant_Cuisines;

----Ratings table---
----Add a new column Ratings_ID---
ALTER TABLE Ratings
ADD Ratings_ID INT IDENTITY(1000,1) PRIMARY KEY;

SELECT * FROM Ratings

----Add a new Column to Restaurant_Cuisine AND MAKE IT THE Primary key---
ALTER TABLE Restaurant_Cuisines
ADD  Restaurant_Cuisines_ID INT IDENTITY(1000,1) PRIMARY KEY;

SELECT * FROM Restaurant_Cuisines


------ALTER THE RATING TABLE ADD FOREIGN KEY CONSTRAINT TO THE RATING TABLE REFERENCE THE CONSUMER TABLE---------
ALTER TABLE Ratings
ADD CONSTRAINT FK_Ratings_Consumers FOREIGN KEY (Consumer_ID) REFERENCES Consumers(Consumer_ID);

------ALTER THE RATING TABLE ADD FOREIGN KEY CONSTRAINT TO THE RATING TABLE REFERENCE THE RESTAURANTS TABLE-
ALTER TABLE Ratings
ADD CONSTRAINT FK_Ratings_Restaurants FOREIGN KEY (Restaurant_ID) REFERENCES Restaurants(Restaurant_ID);


---ALTER THE Restaurant_Cuisines TABLE AND ADD FOREIGN KEY CONSTRAINT TO REFERENCE THE RESTURANT TABLE
ALTER TABLE Restaurant_Cuisines
ADD FOREIGN KEY (Restaurant_ID) REFERENCES Restaurants(Restaurant_ID)



--- (1) Write a query that lists all restaurants with a Medium range price with open area, serving Mexican food.

SELECT r.Name 
FROM Restaurants r
INNER JOIN Restaurant_Cuisines rc ON r.Restaurant_ID = rc.Restaurant_ID
WHERE r.Price = 'Medium' 
AND r.Area = 'Open' 
AND rc.Cuisine = 'Mexican';

2)------------Total Number of restaurant serves that serves mexican cusine
SELECT COUNT(DISTINCT r.Restaurant_ID) AS Total_Mexican_Restaurants_Rating_1
FROM
Restaurants r
JOIN
    Restaurant_Cuisines rc ON r.Restaurant_ID = rc.Restaurant_ID
JOIN
    Ratings ra ON r.Restaurant_ID = ra.Restaurant_ID
WHERE
    rc.Cuisine = 'Mexican'
    AND ra.Overall_Rating = 1;

	----------Total Number of restaurant serves that serves italian cusine
	SELECT 
    COUNT(DISTINCT r.Restaurant_ID) AS Total_Italian_Restaurants_Rating_1
FROM 
    Restaurants r
JOIN 
    Restaurant_Cuisines rc ON r.Restaurant_ID = rc.Restaurant_ID
JOIN 
    Ratings ra ON r.Restaurant_ID = ra.Restaurant_ID
WHERE 
    rc.Cuisine = 'Italian' 
    AND ra.Overall_Rating = 1;

	------------------comparison

	SELECT
    (SELECT COUNT(DISTINCT r.Restaurant_ID) 
     FROM Restaurants r
     JOIN Restaurant_Cuisines rc ON r.Restaurant_ID = rc.Restaurant_ID
     JOIN Ratings ra ON r.Restaurant_ID = ra.Restaurant_ID
     WHERE rc.Cuisine = 'Mexican' AND ra.Overall_Rating = 1) AS Total_Mexican_Restaurants_Rating_1,
    
    (SELECT COUNT(DISTINCT r.Restaurant_ID) 
     FROM Restaurants r
     JOIN Restaurant_Cuisines rc ON r.Restaurant_ID = rc.Restaurant_ID
     JOIN Ratings ra ON r.Restaurant_ID = ra.Restaurant_ID
     WHERE rc.Cuisine = 'Italian' AND ra.Overall_Rating = 1) AS Total_Italian_Restaurants_Rating_1;

	 SELECT  Country FROM consumers


---(3) Calculate the average age of consumers who have given a 0 rating to the 'Service_rating' column.
SELECT 
	ROUND(AVG(c.Age), 0) AS Average_age
FROM Consumers c
JOIN Ratings ra
ON c.Consumer_id = ra.Consumer_id
WHERE ra.Service_Rating = 0;

-- (4) Write a query that returns the restaurants ranked by the youngest consumer.
SELECT 
   DISTINCT (r.Name) AS Restaurant_Name,
    ra.Food_Rating
FROM restaurants r
JOIN Ratings ra 
ON r.Restaurant_id = ra.Restaurant_id
JOIN (
    SELECT 
        Ratings.Restaurant_id,
        Ratings.Consumer_id,
        MIN(Consumers.Age) AS Min_Age
    FROM Ratings
    JOIN Consumers 
	ON Ratings.Consumer_id = Consumers.Consumer_id
    GROUP BY Ratings.Restaurant_id, Ratings.Consumer_id
) AS MinConsumerAge ON ra.Restaurant_id = MinConsumerAge.Restaurant_id AND ra.Consumer_id = MinConsumerAge.Consumer_id
WHERE ra.Food_Rating IS NOT NULL
ORDER BY ra.Food_Rating DESC;

---(5) Update the Service_rating of all restaurants to '2' if they have parking available, either as 'yes' or 'public'----

CREATE PROCEDURE UpdateServiceRatingWithParking
AS
BEGIN
    UPDATE Ratings
    SET Service_rating = '2'
    FROM Ratings
    JOIN Restaurants ON Ratings.Restaurant_ID = Restaurants.Restaurant_ID
    WHERE Restaurants.Parking IN ('yes', 'public');
END;


EXEC UpdateServiceRatingWithParking

SELECT Restaurants.Parking, Ratings.Service_rating
FROM Ratings
JOIN Restaurants ON Ratings.Restaurant_ID = Restaurants.Restaurant_ID
WHERE Restaurants.Parking IN ('yes', 'public');



SELECT * FROM RATINGS


---find the overall ratings where alcohol is not served and smoking is allowed using nested queries with EXISTS


SELECT Name AS Restaurant_Name, Overall_Rating
FROM Restaurants r
INNER JOIN Ratings ra ON r.Restaurant_ID = ra.Restaurant_ID
WHERE r.Alcohol_Service = 'None'
AND r.Smoking_Allowed = 'Yes'
AND EXISTS (
    SELECT 1
    FROM Ratings ra
    WHERE ra.Restaurant_ID = r.Restaurant_ID
);

--What are the names, cities, and countries of restaurants that offer low-priced meals, serve fast food Cusines, and have received a food rating of 2?"
--NESTED QUERY IN----
SELECT Name AS Restaurant_Name,City,Country
FROM Restaurants
WHERE Price = 'Low'
AND Restaurant_ID IN (
    SELECT r.Restaurant_ID
    FROM Restaurant_Cuisines rc
    JOIN Restaurants r ON rc.Restaurant_ID = r.Restaurant_ID
    WHERE rc.Cuisine = 'Fast Food'
)
AND Restaurant_ID IN (
    SELECT Restaurant_ID
    FROM Ratings 
    WHERE Food_Rating = 2
);


---"Find the unique names of restaurants along with their complete locations, where the overall rating is 2, sorted alphabetically by the restaurant names.

SELECT  DISTINCT
    UPPER(r.Name) AS Restaurant_Name,
    CONCAT(r.City, ', ', r.State, ', ', r.Country) AS Location
FROM
    Restaurants r
JOIN
    Ratings ra ON r.Restaurant_ID = ra.Restaurant_ID
WHERE
    ra.Overall_Rating = 2
ORDER BY
    UPPER(r.Name);
SELECT DISTINCT
    UPPER(r.Name) AS Restaurant_Name,
    CONCAT(r.City, ', ', r.State, ', ', r.Country) AS Location
FROM
    Restaurants r
JOIN
    Ratings ra ON r.Restaurant_ID = ra.Restaurant_ID
WHERE
    ra.Overall_Rating = 2
ORDER BY
    UPPER(r.Name);
----------

---"What are the top three cuisines preferred by employed consumers aged over 30, who have given restaurants serving those cuisines an overall rating of 2?"

SELECT TOP 3
    rc.Cuisine,
    COUNT(*) AS Total_Count
FROM
    Consumers c
JOIN
    Ratings ra ON c.Consumer_ID = ra.Consumer_ID
JOIN 
    Restaurant_Cuisines rc ON ra.Restaurant_ID = rc.Restaurant_ID
WHERE
    c.Age > 30
    AND c.Occupation = 'Employed'
    AND ra.Overall_Rating = 2
GROUP BY
    rc.Cuisine
HAVING
    COUNT(*) > 0
ORDER BY
    COUNT(*) DESC;

SELECT * FROM CONSUMERS


