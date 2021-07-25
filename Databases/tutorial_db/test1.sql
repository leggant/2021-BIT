SELECT * FROM users;
INSERT INTO users(first_name, last_name, email, password, location, dept, is_admin, register_date)
VALUES ('Yogi', 'Legg', 'yogi@gmail.com', 'test123', 'Dunedin', 'HR', 1, now());
SELECT * FROM users;
INSERT INTO users (first_name, last_name, email, password, location, dept,  is_admin, register_date) 
values ('Fred', 'Smith', 'fred@gmail.com', '123456', 'New York', 'design', 0, now()), 
('Sara', 'Watson', 'sara@gmail.com', '123456', 'New York', 'design', 0, now()),
('Will', 'Jackson', 'will@yahoo.com', '123456', 'Rhode Island', 'development', 1, now()),
('Paula', 'Johnson', 'paula@yahoo.com', '123456', 'Massachusetts', 'sales', 0, now()),
('Tom', 'Spears', 'tom@yahoo.com', '123456', 'Massachusetts', 'sales', 0, now());
SELECT * FROM users;
SELECT first_name, last_name FROM users;
SELECT * FROM users WHERE location='New York' AND dept='sales';
SELECT * FROM users WHERE is_admin > 0;
SELECT * FROM users WHERE is_admin = 0;
DELETE FROM users WHERE id = 6;
SELECT * FROM users;
UPDATE users SET email = 'freddy@gmail.com' WHERE id = 2;
ALTER TABLE users ADD age VARCHAR(3);
ALTER TABLE users MODIFY COLUMN age INT; 
SELECT * FROM users;
SELECT * FROM users ORDER BY last_name ASC;
SELECT * FROM users ORDER BY last_name DESC;
SELECT CONCAT(first_name,' ',last_name) AS 'NAME', dept, is_admin FROM users ORDER BY last_name ASC;
SELECT DISTINCT location FROM users;
SELECT * FROM users WHERE age BETWEEN 20 AND 50;
SELECT * FROM users WHERE dept LIKE 'dev%';
SELECT * FROM users WHERE dept LIKE '%t';
SELECT * FROM users WHERE dept LIKE '%es%';
SELECT * FROM users WHERE dept NOT LIKE '%es%';
SELECT * FROM users WHERE dept IN('design', 'sales');
CREATE INDEX LIndex on users(location);
DROP INDEX LIndex ON users;
CREATE TABLE posts(
	id INT AUTO_INCREMENT,
    user_id INT,
    title VARCHAR(100),
    body LONGTEXT,
    publish_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(id),
    FOREIGN KEY(user_id) REFERENCES users(id)
);
INSERT INTO posts(user_id, title, body) 
VALUES 
(1, 'Post One', 'This is post one'),
(3, 'Post Two', 'This is post two'),
(1, 'Post Three', 'This is post three'),
(2, 'Post Four', 'This is post four'),
(5, 'Post Five', 'This is post five'),
(4, 'Post Six', 'This is post six'),
(2, 'Post Seven', 'This is post seven'),
(1, 'Post Eight', 'This is post eight'),
(3, 'Post Nine', 'This is post none'),
(4, 'Post Ten', 'This is post ten');
SELECT *  FROM posts;
