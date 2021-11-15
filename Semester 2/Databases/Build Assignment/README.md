# Anthony Legg IN605 Database Build Assignment

## Database Procedures

#### **GetGoalList**
```sql
CALL GetGoalList('Colene Cork');
CALL GetGoalList('Leontine Warbrick');
CALL GetGoalList('Cecilla Dowsey');
```
```sql
CALL GetGoalList('Edy Kield');
CALL GetGoalList('Patrice Danelutti');
```
#### **InsertPlayer**
```sql
CALL InsertPlayer(
  'Yogi Legg', 'yogi@gmail.com',
  '02712558324', '2009-09-07', 5,
  NULL, NULL,  @playerid1
);
```
```sql
CALL InsertPlayer(
  'Bella Legg', 'bella@gmail.com', 
  '02112558324', '2016-09-07', 5, 
  '2021-08-01', '2019-08-01', 
  @playerid2);
```
```sql
CALL InsertPlayer(
  'Bella Legg', 
  'bella@gmail.com', '02112558324', 
  '2016-09-07', 5, '2012-08-01', 
  NULL, @playerid2);
```
```sql
CALL InsertPlayer(
  'Yogi Legg', 'yogi@gmail.com', 
  '02712558324', '2001-09-07', 
  5, NULL, NULL, @playerid1);
```
```sql
CALL InsertPlayer(
  'Bella Legg', 'bella@gmail.com', 
  '02112558324', '2001-09-07', 
  5, '2021-08-01', NULL, @playerid2);
```
```sql
SELECT @playerid1 AS Player_ID_1;
SELECT @playerid2 AS Player_ID_2;
```
#### GetInjury
```sql
CALL GetInjury('Concussion', '2019-01-01', '2021-03-10');
CALL GetInjury('Knee injury', '2019-01-01', CURDATE());
CALL GetInjury('Spinal Injury', '2019-01-01', '2021-03-10');
```

## Database Views
```sql
SELECT * FROM MembershipDuration 
WHERE Average_Membership_Days > 1500;
```
```sql
SELECT * FROM MembershipDuration 
WHERE Team_Name IN ('Latlux Viva', 'Voyatouch Greenlam');
```
```sql
SELECT * FROM MembershipDuration;
```
```sql
SELECT * FROM PlayerGoalCount;
```
```sql
SELECT * FROM PlayerGoalCount WHERE Match_Date < '2021-06-01';
```
```sql
SELECT * FROM PlayerGoalCount WHERE Match_Date < '2021-06-01' AND Goal_Count > 1;
```
```sql
SELECT * FROM CurrentPlayerList;
```
```sql
SELECT * FROM CurrentPlayerList ORDER BY Team_Name;
```
```sql
SELECT * FROM CurrentPlayerList WHERE Team_Name 
IN('Wrapsafe Otcom', 'Voyatouch Greenlam', 'Aerified Span');
```

## Extras
Created two additional procedures, two functions and 8 triggers to help me to ensure the players in my initial dataset were correctly assigned to teams and that the data in my set made sense.
### Functions

- GetJoinDate
  ```sql
  SET @pID=20; 
  SELECT GetJoinDate(@pid) AS 'Player Join Date';
  ```
- GePlayersTeam
  ```sql
  SET @pid=98; 
  SELECT GetPlayersTeam(@pid) AS 'Players Team ID';
  ```
### Procedures
- Set_InitialSquad
- Set_InitialSquadMember 