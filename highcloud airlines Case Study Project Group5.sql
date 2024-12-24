use airline;
show tables;
select * from maindata;
desc maindata;

----- updating cloumn name ----
ALTER TABLE MAINDATA
CHANGE `Month (#)` month_number INT;

------ adding date_cloumn-------
ALTER TABLE maindata
ADD date_column DATE;
UPDATE maindata
SET date_column = STR_TO_DATE(CONCAT(Year, '-', month_number, '-', Day), '%Y-%m-%d');

SET sql_safe_updates = 0; --- safe_mode---

------ adding month_name-------
alter table maindata add Month_Name Varchar(15); 
update maindata set Month_Name = monthname(date_column);

------ adding Quarter-------
ALTER TABLE maindata
ADD Quarter varchar(5);
UPDATE maindata
SET quarter = CONCAT('QTR',' ', QUARTER(date_column));

------ adding Weekname-------
Alter table maindata
add Weekname varchar(10);
update maindata
SET weekname = dayname(date_column);

------ adding Weekday Weekend-------
Alter table maindata
add Weekday_vs_Weekend varchar(10);
update maindata
set Weekday_vs_Weekend = case 
when dayofweek(date_column) IN (1,7) THEN "Weekend"
else "Weekday"
end;

alter table maindata
change `# Transported Passengers` Transported_Passengers int,
change `# Available Seats` Available_Seats int;

------ calculating Load_Factor-------
alter table maindata
add Load_Factor int;
update maindata
set Load_Factor = CASE 
        WHEN Available_Seats = 0 THEN NULL
        ELSE (Transported_Passengers/Available_Seats)
        end;
Select date_column,Quarter,Month_name,Weekname,Weekday_vs_Weekend from maindata;

-- LF Yearly          
select year,
concat(round((SUM(Load_Factor) / (SELECT SUM(Load_Factor) FROM maindata)) * 100,2),'%') AS Load_Factor_Percentage
FROM maindata 
group by year; 

-- LF Quarterly
select Quarter,
concat(round((SUM(Load_Factor) / (SELECT SUM(Load_Factor) FROM maindata)) * 100,2),'%') AS Load_Factor_Percentage
FROM maindata 
group by Quarter; 

-- LF Monthly
select Month_Name, 
concat(round((SUM(Load_Factor) / (SELECT SUM(Load_Factor) FROM maindata)) * 100,2),'%') AS Load_Factor_Percentage
FROM maindata 
group by Month_Name;

-- LF Yearly,Quarterly,Monthly
select Year,Quarter,Month_Name,sum(Load_Factor) AS total_load_factor, 
concat(round((SUM(Load_Factor) / (SELECT SUM(Load_Factor) FROM maindata)) * 100,2),'%') AS Load_Factor_Percentage
FROM maindata 
group by Year,Quarter,Month_Name;

-- Top 10 Passeneger preferred Airlines
use airline;
select `Carrier Name`,CONCAT(FORMAT(SUM(`Transported_Passengers`) / 1000000, 0), ' ','M') As Total_Passengers_Travelled
from maindata
group by `Carrier Name`
order by sum(`Transported_Passengers`) desc
limit 10;

-- Top Routes Based on No of Flights
use airline;
select `From - To City`, count(`%Airline ID`) as No_Of_Flights from maindata
group by `From - To City`
order by count(`%Airline ID`) desc
limit 10;

-- Load Factor by Carrier Name
SELECT 
    `Carrier Name`,
    SUM(Load_Factor) AS total_load_factor,
    concat(round((SUM(Load_Factor) / (SELECT SUM(Load_Factor) FROM maindata)) * 100,2),'%') AS Load_Factor_Percentage
FROM maindata
group by `Carrier Name`
order by sum(load_Factor) desc
limit 10;

-- No of Flights Based on Distance Group
CREATE TABLE distance_groups (
    Distance_Group_ID INT PRIMARY KEY,
    Distance_Interval VARCHAR(255)
);

INSERT INTO distance_groups (Distance_Group_ID, Distance_Interval)
VALUES
(1, 'Less Than 500 Miles'),
(2, '500-999 Miles'),
(3, '1000-1499 Miles'),
(4, '1500-1999 Miles'),
(5, '2000-2499 Miles'),
(6, '2500-2999 Miles'),
(7, '3000-3499 Miles'),
(8, '3500-3999 Miles'),
(9, '4000-4499 Miles'),
(10, '4500-4999 Miles'),
(11, '5000-5499 Miles'),
(12, '5500-5999 Miles'),
(13, '6000-6499 Miles'),
(14, '6500-6999 Miles'),
(15, '7000-7499 Miles'),
(16, '7500-7999 Miles'),
(17, '8000-8499 Miles'),
(18, '8500-8999 Miles'),
(19, '9000-9499 Miles'),
(20, '9500-9999 Miles'),
(21, '10000-10499 Miles'),
(22, '10500-10999 Miles'),
(23, '11000-11499 Miles'),
(24, '11500-11999 Miles'),
(25, '12000 Miles and Greater');
UPDATE distance_groups
SET Distance_Interval = CASE Distance_Group_ID
    WHEN 1 THEN 'Less Than 500 Miles'
    WHEN 2 THEN '500-999 Miles'
    WHEN 3 THEN '1000-1499 Miles'
    WHEN 4 THEN '1500-1999 Miles'
    WHEN 5 THEN '2000-2499 Miles'
    WHEN 6 THEN '2500-2999 Miles'
    WHEN 7 THEN '3000-3499 Miles'
    WHEN 8 THEN '3500-3999 Miles'
    WHEN 9 THEN '4000-4499 Miles'
    WHEN 10 THEN '4500-4999 Miles'
    WHEN 11 THEN '5000-5499 Miles'
    WHEN 12 THEN '5500-5999 Miles'
    WHEN 13 THEN '6000-6499 Miles'
    WHEN 14 THEN '6500-6999 Miles'
    WHEN 15 THEN '7000-7499 Miles'
    WHEN 16 THEN '7500-7999 Miles'
    WHEN 17 THEN '8000-8499 Miles'
    WHEN 18 THEN '8500-8999 Miles'
    WHEN 19 THEN '9000-9499 Miles'
    WHEN 20 THEN '9500-9999 Miles'
    WHEN 21 THEN '10000-10499 Miles'
    WHEN 22 THEN '10500-10999 Miles'
    WHEN 23 THEN '11000-11499 Miles'
    WHEN 24 THEN '11500-11999 Miles'
    WHEN 25 THEN '12000 Miles and Greater'
END;

SELECT dg.Distance_Interval, COUNT(DISTINCT md.`unique carrier`) AS No_of_Flights
FROM maindata md
INNER JOIN `airline`.`distance_groups` dg
    ON md.Distance_Group_ID = dg.Distance_Group_ID  -- Joining on the relevant field
GROUP BY dg.Distance_Interval -- Grouping by Distance_Group_ID
ORDER BY No_of_Flights DESC;  -- Ordering by the count of unique carriers

-- Load Factor Weekday_vs_Weekend
SELECT 
    weekday_vs_weekend,
    concat(round((SUM(Load_Factor) / (SELECT SUM(Load_Factor) FROM maindata)) * 100,2),'%') AS Load_Factor_Percentage
FROM maindata
GROUP BY weekday_vs_weekend;







