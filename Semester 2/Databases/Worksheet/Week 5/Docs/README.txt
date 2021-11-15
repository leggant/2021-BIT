To use this in sqlite
This is assuming the .sql files are the same directory that you want the sqlite database
NB the greater-than character ">" indicates a prompt - do not type this

1) create the database:
> sqlite3.exe bookRatings.sqlite

2) Read in the schema file
> .read bookRating.sql



4) confirm that the tables are created
> .tables

5) check the data exists in the tables
> select * from Book;
etc
 
5).headers on
.mode column
.width 20 20 20 20 