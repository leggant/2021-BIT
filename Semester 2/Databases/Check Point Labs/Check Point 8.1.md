# Check Point 8.1

## P.1

1. Create a procedure circle_area which has an IN parameter for radius and an OUT parameter for the area of a circle
   - Circle area = (pi()*R)*R where R isRadius
   - Use the PI() inbuilt function
```sql
DROP PROCEDURE IF EXISTS `circle_area`;
DELIMITER //
CREATE PROCEDURE 
circle_area(IN radius DOUBLE, OUT area DOUBLE)
SQL SECURITY INVOKER
CONTAINS SQL
BEGIN
    SELECT ((pi()*radius)*radius) INTO area;
END//
DELIMITER ;
```

```sql
SET @area=0.0, @radius=20.5;
CALL circle_area(@radius, @area);
SELECT CONCAT(ROUND(@area, 2), LOWER(' CMS')) AS 'Total Area';
```

2. Create another procedure which uses a single session variable as an INOUT parameter to calculate the area of a circle

```sql
DROP PROCEDURE IF EXISTS `circle_area_inout`;
DELIMITER //
CREATE PROCEDURE 
circle_area_inout(INOUT next_area DOUBLE)
SQL SECURITY INVOKER
CONTAINS SQL
BEGIN
    SELECT ((pi()*next_area)*next_area) INTO next_area;
END //
DELIMITER ;
```
```sql
SET @next_area=10.5;
CALL circle_area_inout(@next_area);
SELECT CONCAT(ROUND(@next_area, 2), LOWER(' CMS')) AS 'Total Area';
```

3. Create a function to do the same job (area of circle)
```sql
DROP FUNCTION IF EXISTS `get_area`;
DELIMITER $$
CREATE
FUNCTION get_area(newArea DOUBLE) 
RETURNS double UNSIGNED
DETERMINISTIC
SQL SECURITY INVOKER
NO SQL
COMMENT 'returns a double datatype;calculates an area'
BEGIN
    RETURN ((pi()*newArea)*newArea);
END$$
DELIMITER ;
```
```sql
SELECT ROUND(get_area(20.5),2) AS Area_Result;
```

## P.2

4. Create a function age(birthDate DATE) which returns the number of years between now() and birthDate
```sql
DELIMITER $$
CREATE
FUNCTION get_years(birth YEAR(4)) 
RETURNS int(3) UNSIGNED
    DETERMINISTIC
    NO SQL
    SQL SECURITY INVOKER
    COMMENT 'calculates years between birth and now'
BEGIN
    RETURN (YEAR(NOW()) - birth);
END$$
DELIMITER ;
```
```sql
SELECT get_years(1981) AS 'Birth <> Now';
```