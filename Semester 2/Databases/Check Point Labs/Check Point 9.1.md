# Check Point 9.1

## Routines

1. Write a routine which prints:
   - "Good Morning" if the time is before noon
   - "Good Afternoon" if the time is between 12pm and 5pm 
   - "Good Evening" if the time is between 5pm and midnight
   *If you declare a variable of type TIME then you can set it using the CURTIME method. The format of the variable of type TIME is ‘12:00:00’*
```sql
DELIMITER $$
CREATE FUNCTION `greeting`() 
RETURNS varchar(30) 
CHARSET utf8mb4
    DETERMINISTIC
    CONTAINS SQL
    SQL SECURITY INVOKER
BEGIN 
		DECLARE result VARCHAR(30);
        DECLARE now TIME DEFAULT CURTIME();
		IF now < '12:00:00' THEN 
			SET result = 'Good Morning';
        ELSEIF now BETWEEN '12:00:00' AND '17:00:00' THEN
            SET result = 'Good Afternoon';
        ELSEIF now BETWEEN '17:00:00' AND '00:00:00' THEN
            SET result = 'Good Evening';
		END IF;
		RETURN result;
	END$$
DELIMITER ;
```

## Fibonacci

Write a routine which prints a single string listing the Fibonacci sequence (each number is the sum of the previous two) 

- The first two numbers are always 0, 1
- The parameter is the number of digits to print Call fib(6) prints '0, 1, 1, 2, 3, 5'

You might need to concatenate strings

- Concate('B', 'an', 'ana’) 
- Makes 'Banana'

```sql
USE sakila;
DROP PROCEDURE IF EXISTS fib;
DELIMITER $$
CREATE PROCEDURE fib
(IN MyNum INT(4) UNSIGNED)
SQL SECURITY INVOKER
CONTAINS SQL
BEGIN
    DECLARE x INT DEFAULT 0;
    DECLARE y INT DEFAULT 1;
    DECLARE res INT DEFAULT 0;
    DECLARE Results VARCHAR(255);
    SELECT CONCAT(x, ', ', y) INTO Results;
    WHILE res <= MyNum DO 
        SET res = x + y;
        IF res <= MyNum THEN
            SELECT CONCAT(Results, ', ', res) INTO Results;
        END IF;
        SET x = y;
        SET y = res;
    END WHILE;
    SELECT Results AS Fibonacci;
END $$
DELIMITER ;
```
```sql
USE sakila;
SET @x = 20;
CALL fib(@x);
SELECT @result AS Fibonacci;
```