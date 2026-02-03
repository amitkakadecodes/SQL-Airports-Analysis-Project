USE airport_db;

#Q1. List the top 5 busiest airports by passengers in 2020
SELECT Airport, Country, Passengers FROM airports
WHERE Year = 2020
ORDER BY Passengers DESC
LIMIT 5;



#Q2. Find total passangers handled by each country in the given year
SELECT Country, SUM(Passengers) AS total_passengers
FROM airports
WHERE Year = 2019
GROUP BY Country
ORDER BY total_passengers DESC;



#Q3. Find the average number of passangers per airport across all years
SELECT Airport, AVG(Passengers) AS avg_passengers
FROM airports
GROUP BY Airport;



#Q4. Find airports that appeared in rankings for more than 4 years
SELECT Airport, COUNT(DISTINCT Year) AS years_count
FROM airports
GROUP BY Airport
HAVING COUNT(DISTINCT Year) > 4;



#Q5. Rank airports by passangers within each year
SELECT Airport, Year, Passengers, RANK() OVER (PARTITION BY Year ORDER BY Passengers DESC) AS yearly_rank
FROM airports;



#Q6. Find the year when each airport had its highest passanger traffic
SELECT Airport, Year, Passengers
FROM airports a
WHERE Passengers = (
    SELECT MAX(Passengers)
    FROM airports
    WHERE Airport = a.Airport
);



#Q7. Retrieve airport name, country, service type, and annual revenue only for airports that have services registered.

CREATE TABLE airport_services(
Code VARCHAR(10),
Service_Type VARCHAR(50),
Annual_Revenue BIGINT);

INSERT INTO airport_services (Code, Service_Type, Annual_Revenue) 
VALUES ('ATL/KATL', 'Duty Free', 50000000),
('ATL/KATL', 'Lounge', 30000000),
('DXB/OMDB', 'Duty Free', 70000000),
('LHR/EGLL', 'Lounge', 45000000),
('HND/RJTT', 'Parking', 20000000);

SELECT * FROM airport_services;


SELECT a.Airport, a.Country, s.Service_Type, s.Annual_Revenue
FROM airports a
INNER JOIN airport_services s ON a.Code = s.Code;



#Q8. Retrieve all airports along with their service type and revenue.
SELECT a.Airport, a.Country, s.Service_Type, s.Annual_Revenue
FROM airports a
LEFT JOIN airport_services s ON a.Code = s.Code;



#Q9. Find airports whose passenger count increased for 3 consecutive years (recursive CTE)
WITH RECURSIVE growth AS (
SELECT Airport, Year, Passengers
FROM airports

UNION ALL

SELECT a.Airport, a.Year, a.Passengers
FROM airports a

JOIN growth g
ON a.Airport = g.Airport
AND a.Year = g.Year + 1
AND a.Passengers > g.Passengers
)
SELECT Airport
FROM growth
GROUP BY Airport
HAVING COUNT(*) >= 3;



#Q10. Create a temporary table for top 10 airports by passengers (latest year)
CREATE TEMPORARY TABLE top_airports AS
SELECT *
FROM airports
WHERE Year = (SELECT MAX(Year) FROM airports)
ORDER BY Passengers DESC
LIMIT 10;



#Q11. Use the temporary table to find total passengers by country
SELECT Country, SUM(Passengers) AS total_passengers
FROM top_airports
GROUP BY Country;



#Q12. Stored procedure: get airport details by airport code
DELIMITER //

CREATE PROCEDURE get_airport_by_code(IN airport_code VARCHAR(10))
BEGIN
    SELECT *
    FROM airports
    WHERE Code = airport_code;
END //

DELIMITER ;



#Q13. Stored procedure: get top N airports for a given year
DELIMITER //

CREATE PROCEDURE top_n_airports(IN input_year INT, IN n INT)
BEGIN
    SELECT Airport, Country, Passengers
    FROM airports
    WHERE Year = input_year
    ORDER BY Passengers DESC
    LIMIT n;
END //

DELIMITER ;



#Q14. Trigger: prevent inserting negative passenger values
DELIMITER //

CREATE TRIGGER check_passengers_before_insert
BEFORE INSERT ON airports
FOR EACH ROW
BEGIN
    IF NEW.Passengers < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Passenger count cannot be negative';
    END IF;
END //

DELIMITER ;

SHOW TRIGGERS;



#Q15. Trigger: automatically update rank based on passengers (before insert)
DELIMITER //

CREATE TRIGGER auto_rank
BEFORE INSERT ON airports
FOR EACH ROW
BEGIN
    SET NEW.Rank_ = (
        SELECT COUNT(*) + 1
        FROM airports
        WHERE Year = NEW.Year
          AND Passengers > NEW.Passengers
    );
END //

DELIMITER ;



#Q16. Find airports that dropped in rank compared to the previous year
SELECT a.Airport, a.Year, a.Rank_ AS current_rank, b.Rank_ AS previous_rank
FROM airports a
JOIN airports b ON a.Airport = b.Airport
AND a.Year = b.Year + 1
WHERE a.Rank_ > b.Rank_;



#Q17. Find the percentage share of each airport in total passengers for a year
SELECT Airport, (Passengers * 100.0 / (SELECT SUM(Passengers) FROM airports WHERE Year = 2019)) AS passenger_share
FROM airports
WHERE Year = 2019;



#Q18. Find airports that consistently stayed in top 10 ranks across all years
SELECT Airport
FROM airports
GROUP BY Airport
HAVING MAX(Rank_) <= 10;



#Q19. Find the first year each airport appeared in the ranking
SELECT Airport, MIN(Year) AS first_appearance
FROM airports
GROUP BY Airport;

