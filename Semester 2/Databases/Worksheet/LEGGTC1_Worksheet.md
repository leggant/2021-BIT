# SQL Worksheet Assignment

This worksheet is worth 10% of your course. Submit a single text document (readable either by MS‐Word or notepad) named YOURUSERNAME  to your IN605 Git repository by September 10th 11:59pm with the statements to do the tasks listed below.

## Book Rating Database

You've started a new book‐rating website. You've been collecting data on reviewers' ratings of various books. There's not much data yet, but you can still try out some interesting queries. The scripts to create this database in SQLite are on the I: drive. A printout of the data is on the last page

### Schema:

**Book:** ( bID, title, published, author, genre ) Explanation: There is a book with ID number bID, a title, a first published year, a director and a genre.

**Reviewer:** ( rID, name ) Explanation: The reviewer with ID number rID has a certain name.

**Rating:** ( rID, bID, ratings, ratingDate ) Explanation: The reviewer rID gave the book bID a number of ratings (1‐5) on a certain ratingDate.

## Tasks

**Create SQL statements to achieve the following:**
*Use the techniques taught in class - zero marks for using a NATURAL JOIN or USING instead of ON*

### Queries

1. Find the titles and the genre of all books written by Harper Lee.
```sql
SELECT title, genre
FROM Book
WHERE author LIKE "harper lee";
```
2. Find all years that have a book that received a rating of 4 or 5, and sort them in increasing order.
```sql
SELECT DISTINCT bk.published
FROM Rating ra
JOIN Book bk
ON ra.bID = bk.bID
WHERE ra.ratings BETWEEN 4 AND 5
AND ra.ratingDate IS NOT NULL
ORDER BY ratingDate;
```
3. Find the names of all reviewers who rated To Kill a Mocking Bird.
```sql
SELECT DISTINCT rev.name
FROM Reviewer rev
JOIN Rating ra
ON rev.rID = ra.rID
Join Book bk
ON ra.bID = bk.bID
WHERE bk.title LIKE "To Kill a Mocking Bird";
```
4. Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date
```sql
SELECT DISTINCT rev.name
FROM Reviewer rev
JOIN Rating ra
ON rev.rID = ra.rID
WHERE ra.ratingDate IS NULL;
```
5. For any rating where the reviewer is the same as the author of any book, return the reviewer name, book, title, and the ratings
```sql
SELECT rev.name, bk.title, ra.ratings
FROM Reviewer rev
JOIN Rating ra
ON rev.rID = ra.rID
Join Book bk
ON ra.bID = bk.bID
where bk.author = rev.name;
```
6. Write a query to return the rating data in a more readable format (usings titles): reviewer name, book title, ratings, and ratingDate. Also, sort the data, first by reviewer name, then by book title, and lastly by ratings.
```sql
SELECT 
'Reviewer: ' || re.name 'Reviewer',
'Book Title: ' || bk.title 'Book Reviewed',
'Reviewed On: ' || ra.ratingDate 'Review Date', 
'Rating: ' || ra.ratings || ' out of 5.' 'Review'
FROM Rating ra
JOIN Book bk
ON ra.bID = bk.bID
JOIN Reviewer re
ON ra.rID = re.rID
ORDER BY re.name, bk.title, ra.ratings, ra.ratingDate;

SELECT 
re.name 'Reviewer Name', 
bk.title 'Book Title', 
'Rating: ' || ra.ratings 'Reviewer Rating', 
'Reviewed: ' || ra.ratingDate 'Review Date'
FROM Rating ra
JOIN Book bk
ON ra.bID = bk.bID
JOIN Reviewer re
ON ra.rID = re.rID
ORDER BY re.name, bk.title, ra.ratings, ra.ratingDate;
```
7. For all cases where the same reviewer rated the same book twice and gave it a higher rating the second time, return the reviewer's name and the title of the book.
```sql
SELECT rev.name, bk.title
FROM Rating AS r1 
JOIN Rating r2 ON r1.rID = r2.rID AND r1.bID = r2.bID
JOIN Reviewer rev ON r1.rID = rev.rid 
JOIN Book bk ON r1.bID = bk.bID
WHERE r1.ratingDate < r2.ratingDate AND r1.ratings < r2.ratings;
```
8. For each book that has at least one rating, find the highest rating that book received. Return the book title and the rating. Sort by book title.
```sql
SELECT 
    bk.title AS "Book Title",
	MAX(ra.ratings) AS "Max Rating"
FROM
    Book AS bk
JOIN Rating ra ON bk.bID = ra.bID
WHERE ra.ratingDate IS NOT NULL
GROUP BY bk.title
HAVING 
    ra.ratings > 1
ORDER BY bk.title;
```
9. For each book, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that book. Sort by rating spread from highest to lowest, then by book title.
```sql
SELECT 
    bk.title AS "Book Title",
	MAX(ra.ratings) - MIN(ra.ratings) AS "Rating Spread"
FROM
    Book AS bk
JOIN Rating ra ON bk.bID = ra.bID
GROUP BY bk.title
HAVING 
    ra.ratings
ORDER BY "Rating Spread" DESC, bk.title;
```
10. Find the difference between the average rating of books released before 1970 and the average rating of books released after 1970. (Make sure to calculate the average rating for each book, then the average of those averages for books before 1970 and books after. Don't just calculate the overall average rating before and after 1970.)
```sql
SELECT AVG(AV1) - AVG(AV2) average_rating_diff
FROM (select AVG(ratings) AS AV1
FROM Rating
JOIN Book ON Rating.bID = Book.bID
WHERE published < '1970'
GROUP BY Book.bID),
(select AVG(ratings) AS AV2
FROM Rating
JOIN Book ON Rating.bID = Book.bID
WHERE published > '1970'
GROUP BY Book.bID);
```
## Modification 

11. Add the reviewer John Green to your database, with an rID of 209.
```sql
INSERT INTO Reviewer (rID, name) VALUES (209, "John Green");
```
12. Insert 5‐star ratings by Daniel Lewis for all books in the database. Leave the review date as NULL. Do Not write five insert statements.
```sql
INSERT INTO Rating (rID, bID, ratings)
SELECT (SELECT rID FROM Reviewer 
        WHERE name = "Daniel Lewis"),
bID, "5" FROM Book;
```
13. For all books that have an average rating of 4 or higher, add 25 to the published year. (Update the existing Rows; don't insert new Rows.)
```sql
UPDATE Book
SET published = published + 25
WHERE Book.bID IN
(Select Book.bID FROM (SELECT bk.bID, AVG(ra.ratings) avgRating FROM Book bk
JOIN Rating ra ON bk.bID = ra.bID
GROUP BY bk.title) Where avgRating >= 4);
```
14. Remove all ratings where the book year is before 1970 or after 2000, and the rating is fewer than 4.
```sql
DELETE FROM Rating
WHERE Rating.bID IN
(SELECT bID FROM book bk 
WHERE (bk.published < 1970 OR bk.published > 2000)) 
AND Rating.ratings < 4;
```

