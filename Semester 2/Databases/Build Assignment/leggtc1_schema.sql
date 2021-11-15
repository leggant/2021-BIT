-----------------------------------------------------------------------------
----------------------------LEGGTC1_SCHEMA.SQL-------------------------------
--------------------------Anthony Legg #03007276-----------------------------
-----------------------------------------------------------------------------
DROP Database IF EXISTS `leggtc1_sportclub`;
CREATE DATABASE IF NOT EXISTS `leggtc1_sportclub` 
DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `leggtc1_sportclub`;
-----------------------------------------------------------------------------
-- Table structure for table `player`
-----------------------------------------------------------------------------
DROP TABLE IF EXISTS player;
CREATE TABLE IF NOT EXISTS player (
  PlayerID INT(5) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  PlayerName VARCHAR(60) NOT NULL UNIQUE,
  PlayerEmail VARCHAR(80) NOT NULL UNIQUE,
  PlayerPhone VARCHAR(25) NOT NULL UNIQUE,
  DateOfBirth DATE DEFAULT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
DROP TRIGGER IF EXISTS INSERT_PlayerDOBValid;
DELIMITER //
CREATE TRIGGER INSERT_PlayerDOBValid BEFORE INSERT ON player
FOR EACH ROW
BEGIN
  DECLARE err CONDITION FOR SQLSTATE '02000';
  IF (TIMESTAMPDIFF(YEAR, NEW.DateOfBirth, CURDATE())) < 18 THEN
    SET NEW.DateOfBirth = NULL;
    SIGNAL err SET MESSAGE_TEXT = 'New players must be 18 and over';
  END IF;
END//
DELIMITER ;
-----------------------------------------------------------------------------
-- Table structure for table `team`
-----------------------------------------------------------------------------
DROP TABLE IF EXISTS team;
CREATE TABLE IF NOT EXISTS team (
  TeamID INT(5) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  TeamName VARCHAR(80) NOT NULL UNIQUE,
  ContactPersonName VARCHAR(50) NOT NULL UNIQUE,
  ContactPhone VARCHAR(25) NOT NULL UNIQUE,
  ContactEmail VARCHAR(50) NOT NULL UNIQUE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
-----------------------------------------------------------------------------
-- Table structure for table `teammember`
-----------------------------------------------------------------------------
DROP TABLE IF EXISTS teammember;
CREATE TABLE IF NOT EXISTS teammember (
  PlayerID INT(5) UNSIGNED NOT NULL,
  TeamID INT(5) UNSIGNED NOT NULL,
  JoiningDate DATE NOT NULL,
  LeavingDate DATE DEFAULT NULL,
  PRIMARY KEY (PlayerID, JoiningDate) USING BTREE,
  CONSTRAINT teammember_fk_team 
  FOREIGN KEY (TeamID) 
  REFERENCES team(TeamID) 
  ON DELETE RESTRICT 
  ON UPDATE RESTRICT,
  CONSTRAINT teammember_fk_player 
  FOREIGN KEY (PlayerID) 
  REFERENCES player(PlayerID) 
  ON DELETE RESTRICT 
  ON UPDATE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
CREATE INDEX I_team On teammember(TeamID) USING BTREE;
-----------------------------------------------------------------------------
-- Table structure for table `ground`
-----------------------------------------------------------------------------
DROP TABLE IF EXISTS ground;
CREATE TABLE IF NOT EXISTS ground (
  GroundID INT(5) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  GroundName VARCHAR(80) NOT NULL UNIQUE,
  GroundAddress VARCHAR(100) NOT NULL UNIQUE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
-----------------------------------------------------------------------------
-- Table structure for table `match`
-----------------------------------------------------------------------------
DROP TABLE IF EXISTS `match`;
CREATE TABLE IF NOT EXISTS `match` (
  MatchID INT(5) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  MatchGroundID INT(5) UNSIGNED NOT NULL,
  MatchStart DATETIME 
  NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  CONSTRAINT match_fk_ground 
  FOREIGN KEY (MatchGroundID) 
  REFERENCES ground(GroundID) 
  ON DELETE RESTRICT 
  ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
CREATE INDEX I_match_ground On `match`(MatchGroundID) USING BTREE;
-----------------------------------------------------------------------------
-- Table structure for table `umpire`
-----------------------------------------------------------------------------
DROP TABLE IF EXISTS umpire;
CREATE TABLE IF NOT EXISTS umpire (
  UmpireID INT(5) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  UmpireName VARCHAR(60) NOT NULL UNIQUE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
-----------------------------------------------------------------------------
-- Table structure for table `umpireduty`
-----------------------------------------------------------------------------
DROP TABLE IF EXISTS umpireduty;
CREATE TABLE IF NOT EXISTS umpireduty (
  MatchID INT(5) UNSIGNED NOT NULL,
  MatchUmpireID INT(5) UNSIGNED NOT NULL,
  PRIMARY KEY (MatchUmpireID, MatchID) USING BTREE,
  CONSTRAINT umpireduty_fk_umpire 
  FOREIGN KEY (MatchUmpireID) 
  REFERENCES umpire(UmpireID) 
  ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT umpireduty_fk_match 
  FOREIGN KEY (MatchID) 
  REFERENCES `match`(MatchID) 
  ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
CREATE INDEX I_umpire_match On umpireduty(MatchID) USING BTREE;
CREATE INDEX I_umpire On umpireduty(MatchUmpireID) USING BTREE;
-----------------------------------------------------------------------------
-- Table structure for table `teammatch`
-----------------------------------------------------------------------------
DROP TABLE IF EXISTS teammatch;
CREATE TABLE IF NOT EXISTS teammatch (
  TeamID INT(5) UNSIGNED NOT NULL,
  MatchID INT(5) UNSIGNED NOT NULL,
  PRIMARY KEY (TeamID, MatchID) USING BTREE,
  CONSTRAINT teammatch_fk_team 
  FOREIGN KEY (TeamID) 
  REFERENCES team(TeamID) 
  ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT teammatch_fk_match 
  FOREIGN KEY (MatchID) 
  REFERENCES `match`(MatchID) 
  ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
CREATE INDEX I_match_team On teammatch(TeamID);
CREATE INDEX I_match On teammatch(MatchID);
-----------------------------------------------------------------------------
-- Table structure for table `squadmember`
-----------------------------------------------------------------------------
DROP TABLE IF EXISTS squadmember;
CREATE TABLE IF NOT EXISTS squadmember (
  MatchID INT(5) UNSIGNED NOT NULL,
  PlayerID INT(5) UNSIGNED NOT NULL,
  TeamID INT(5) UNSIGNED NOT NULL,
  JoiningDate DATE NOT NULL,
  ShirtNumber ENUM(
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10'
  ) NOT NULL,
  PRIMARY KEY (MatchID, PlayerID) USING BTREE,
  CONSTRAINT squadmember_fk_teammatch 
  FOREIGN KEY (MatchID, TeamID) 
  REFERENCES teammatch(MatchID, TeamID) 
  ON DELETE RESTRICT 
  ON UPDATE CASCADE,
  CONSTRAINT squadmember_fk_teammember 
  FOREIGN KEY (PlayerID, JoiningDate) 
  REFERENCES teammember(PlayerID, JoiningDate) 
  ON DELETE RESTRICT 
  ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
CREATE INDEX I_join_date On squadmember(JoiningDate) USING BTREE;
CREATE INDEX I_squad_team On squadmember(TeamID) USING BTREE;
-----------------------------------------------------------------------------
-- Table structure for table `goal`
-----------------------------------------------------------------------------
DROP TABLE IF EXISTS goal;
CREATE TABLE IF NOT EXISTS goal (
  MatchID INT(5) UNSIGNED NOT NULL,
  PlayerID INT(5) UNSIGNED NOT NULL,
  GoalDateTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  PRIMARY KEY (MatchID, PlayerID, GoalDateTime) USING BTREE,
  CONSTRAINT goal_fk_player_match 
  FOREIGN KEY (MatchID, PlayerID) 
  REFERENCES squadmember(MatchID, PlayerID) 
  ON DELETE RESTRICT 
  ON UPDATE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
CREATE INDEX I_match On goal(MatchID) USING BTREE;
CREATE INDEX I_player On goal(PlayerID) USING BTREE;
-----------------------------------------------------------------------------
-- Table structure for table `accinjurytype`
-----------------------------------------------------------------------------
DROP TABLE IF EXISTS accinjurytype;
CREATE TABLE IF NOT EXISTS accinjurytype (
  ACCInjuryCode VARCHAR(11) PRIMARY KEY,
  InjuryTypeName VARCHAR(100) UNIQUE NOT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
-----------------------------------------------------------------------------
-- Table structure for table `injuryevent`
-----------------------------------------------------------------------------
DROP TABLE IF EXISTS injuryevent;
CREATE TABLE IF NOT EXISTS injuryevent (
  PlayerID INT(5) UNSIGNED NOT NULL,
  ACCInjuryCode VARCHAR(10) NOT NULL,
  InjuryEventDateTime 
  DATETIME NOT NULL 
  DEFAULT CURRENT_TIMESTAMP(),
  MatchID INT(5) UNSIGNED NOT NULL,
  PRIMARY KEY (PlayerID, ACCInjuryCode, InjuryEventDateTime),
  CONSTRAINT injuryevent_fk_code 
  FOREIGN KEY (ACCInjuryCode) 
  REFERENCES accinjurytype(ACCInjuryCode) 
  ON DELETE RESTRICT 
  ON UPDATE RESTRICT,
  CONSTRAINT injuryevent_fk_player 
  FOREIGN KEY (PlayerID) 
  REFERENCES squadmember(PlayerID) 
  ON DELETE RESTRICT 
  ON UPDATE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;
CREATE INDEX I_event_match On injuryevent(MatchID) USING BTREE;
-----------------------------------------------------------------------------
--------------------    END DATABASE DECLARATIONS   -------------------------
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
---------------------   START PROCEDURE DECLARATIONS   ----------------------
-----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS InsertPlayer;
DELIMITER $$
CREATE PROCEDURE InsertPlayer(
    IN playername VARCHAR(60), 
    IN email VARCHAR(80), 
    IN phone VARCHAR(25),
    IN dob DATE, 
    IN team INT(5),
    IN joinDate DATE,
    IN leaveDate DATE,
    OUT playersid INT(5)
    )
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'Add a new player to the database and to a team'
BEGIN 
DECLARE err CONDITION FOR SQLSTATE '02000';
DECLARE jd DATE DEFAULT CURDATE();
DECLARE ld DATE DEFAULT NULL;
IF leaveDate IS NOT NULL THEN
SET ld = leaveDate;
END IF;
IF joinDate IS NULL THEN
    SET joinDate = jd;
END IF;
IF joindate < dob THEN
    SIGNAL err SET MESSAGE_TEXT = 'The players joining date cannot be before the date they were born.';
END IF;
IF ld IS NOT NULL AND ld < joinDate THEN
    SIGNAL err SET MESSAGE_TEXT = 'The players leaving date cannot be before the date they joined.';
END IF;
INSERT INTO 
player(PlayerName, PlayerEmail, PlayerPhone, DateOfBirth) 
VALUES (playername, email, phone, dob);
SELECT LAST_INSERT_ID() INTO playersid;
IF leaveDate IS NULL THEN
    INSERT INTO
    teammember(PlayerID, TeamID, JoiningDate)
    VALUES (LAST_INSERT_ID(), team, joinDate);
ELSE
    INSERT INTO
    teammember(PlayerID, TeamID, JoiningDate, LeavingDate)
    VALUES (LAST_INSERT_ID(), team, joinDate, leaveDate);
END IF;
END $$
DELIMITER ;
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS GetInjury;
DELIMITER //
CREATE PROCEDURE `GetInjury`
(
    IN InjuryType VARCHAR(100),
    IN AnalysisStartDate DATETIME,
    IN AnalysisEndDate DATETIME
)
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Get all players subjected to a particular injury within a date range'
BEGIN 
DROP TEMPORARY TABLE IF EXISTS playerInjuries;
CREATE TEMPORARY TABLE if not exists playerInjuries (
    player VARCHAR(60) NOT NULL,
    injury VARCHAR(100) NOT NULL,
    dateofinjury DATETIME NOT NULL,
    referees VARCHAR(125) NOT NULL
);
INSERT INTO playerInjuries(
    player, injury, dateofinjury, referees
)
SELECT pl.PlayerName,
acc.InjuryTypeName,
ie.InjuryEventDateTime,
(
    SELECT GROUP_CONCAT(DISTINCT u.UmpireName SEPARATOR ' & ')
    FROM umpire u
    INNER JOIN umpireduty ud 
    ON u.UmpireID = ud.MatchUmpireID 
    WHERE ud.MatchID = ie.MatchID
)
FROM player pl
INNER JOIN teammember tmm
USING (PlayerID)
INNER JOIN squadmember sq
USING (PlayerID, TeamID, JoiningDate)
INNER JOIN injuryevent ie
USING (PlayerID, MatchID)
INNER JOIN accinjurytype acc
USING (ACCInjuryCode)
WHERE acc.InjuryTypeName = InjuryType
AND DATE(ie.InjuryEventDateTime) > AnalysisStartDate
AND DATE(ie.InjuryEventDateTime) < AnalysisEndDate
ORDER BY ie.InjuryEventDateTime DESC;
SELECT player AS 'Player Name',
injury AS 'Injury',
DATE_FORMAT(dateofinjury, '%d-%m-%Y %r') 
AS 'Date/Time of Injury',
referees AS 'Match Referees'
FROM playerInjuries;
END //
DELIMITER ;
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS GetGoalList;
DELIMITER //
CREATE PROCEDURE GetGoalList
(
    IN plName VARCHAR(60)
)
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'present a table of goals this player has scored'
BEGIN 
DECLARE xName VARCHAR(60) DEFAULT '';
SET xName = plName;
DROP TEMPORARY TABLE IF EXISTS playersGoals;
CREATE TEMPORARY TABLE if not exists playersGoals (
    player VARCHAR(60) NOT NULL,
    team VARCHAR(80) NOT NULL,
    matchdate DATETIME NOT NULL
);
INSERT INTO playersGoals(
    player, team, matchdate
)
SELECT p.PlayerName, 
t.TeamName, 
m.MatchStart
FROM player p
JOIN teammember tm 
ON p.PlayerID = tm.PlayerID
INNER JOIN squadmember sq 
ON tm.PlayerID = sq.PlayerID
AND tm.JoiningDate = sq.JoiningDate 
AND tm.TeamID = sq.TeamID
INNER JOIN teammatch tma 
ON sq.MatchID = tma.MatchID
AND sq.TeamID <> tma.TeamID 
JOIN team t
ON tma.TeamID = t.TeamID
JOIN goal g
ON g.MatchID = sq.MatchID 
AND g.PlayerID = sq.PlayerID 
JOIN `match` m 
ON m.MatchID = tma.matchID
WHERE p.PlayerName = xName
ORDER BY DATE(m.MatchStart);
SELECT pg.player AS 'Player Name', 
pg.team AS 'Team Scored Against', 
DATE_FORMAT(pg.matchdate, '%a, %D %b %Y %r') 
AS 'Match Date/Start Time'
FROM playersGoals pg;
END //
DELIMITER ;
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS Set_InitialSquadMember;
DELIMITER $$
CREATE PROCEDURE Set_InitialSquadMember
(IN Pid INT(5), IN JD DATE, IN shirt INT(2), 
IN team INT(5), IN game INT(5))
MODIFIES SQL DATA
SQL SECURITY INVOKER
COMMENT 'adds a player to a squad to play a match'
BEGIN 
SET FOREIGN_KEY_CHECKS=0;
INSERT INTO 
squadmember(PlayerID, JoiningDate, ShirtNumber, TeamID, MatchID) 
VALUE (Pid, JD, shirt, team, game);
SET FOREIGN_KEY_CHECKS=1;
END $$
DELIMITER ;
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS Set_InitalSquad;
DELIMITER $$
CREATE PROCEDURE Set_InitalSquad(IN xTeam INT, IN xMatch INT)
MODIFIES SQL DATA
SQL SECURITY DEFINER
COMMENT 'Procedure creates the initial squad data set'
BEGIN
    DECLARE xPlayer INT DEFAULT 0;
    DECLARE counter INT DEFAULT 1;
    DECLARE xEnd INT DEFAULT 0;
    DECLARE squad_cursor CURSOR FOR 
        SELECT DISTINCT PlayerID 
        FROM teammember 
        WHERE TeamID = xTeam 
        AND LeavingDate IS NULL 
        ORDER BY RAND() 
        LIMIT 10;
        DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET xEnd = 1;
            OPEN squad_cursor;
            getPlayerList: LOOP
                FETCH squad_cursor INTO xPlayer;
                IF xEnd = 1 THEN
                    LEAVE getPlayerList;
                END IF;
                CALL Set_InitialSquadMember (xPlayer, GetJoinDate(xPlayer), 
                counter, GetPlayersTeam(xTeam), xMatch);
                SET counter = counter + 1;
        END LOOP getPlayerList;
    CLOSE squad_cursor;
END $$
DELIMITER ;
-----------------------------------------------------------------------------
--------------------    START FUNCTON DECLARATIONS   ------------------------
-----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS GetPlayersTeam;
DELIMITER $$
CREATE FUNCTION GetPlayersTeam(pid INT(5)) 
RETURNS INT(5)
    DETERMINISTIC
    SQL SECURITY INVOKER
BEGIN
    DECLARE p INT(5);
    SET p = (
    SELECT leggtc1_sportclub.teammember.TeamID 
    FROM leggtc1_sportclub.teammember
    WHERE leggtc1_sportclub.teammember.PlayerID=pid
);
RETURN p;
END $$
DELIMITER ;
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
DROP FUNCTION IF EXISTS GetJoinDate;
DELIMITER $$
CREATE FUNCTION GetJoinDate(pid INT(5)) 
RETURNS DATE
    DETERMINISTIC
    SQL SECURITY INVOKER
BEGIN
    DECLARE jd DATE;
    SET jd = (
    SELECT leggtc1_sportclub.teammember.JoiningDate 
    FROM leggtc1_sportclub.teammember
    WHERE leggtc1_sportclub.teammember.PlayerID=pid
);
RETURN jd;
END $$
DELIMITER ;
-----------------------------------------------------------------------------
--------------------    START TRIGGER DECLARATIONS   ------------------------
-----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS INSERT_LeavingDateIsValid;
DELIMITER //
CREATE TRIGGER INSERT_LeavingDateIsValid 
BEFORE INSERT ON teammember
FOR EACH ROW BEGIN
IF NEW.LeavingDate IS NOT NULL 
AND New.LeavingDate < NEW.JoiningDate THEN
    SET NEW.LeavingDate = NULL;
    END IF;
END//
DELIMITER ;
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS INSERT_TeamMember_JoiningDateIsValid;
DELIMITER //
CREATE TRIGGER INSERT_TeamMember_JoiningDateIsValid 
BEFORE INSERT ON teammember
FOR EACH ROW BEGIN
DECLARE err CONDITION FOR SQLSTATE '02000';
IF New.LeavingDate < NEW.JoiningDate THEN
    SET NEW.LeavingDate = NULL;
    SIGNAL err SET MESSAGE_TEXT = 'The players leaving date cannot be before the 
      date they joined. Resetting to previous value.';
    END IF;
END //
DELIMITER ;
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS UPDATE_NullLeavingDateIfJoined;
DELIMITER //
CREATE TRIGGER UPDATE_NullLeavingDateIfJoined 
BEFORE UPDATE ON teammember
FOR EACH ROW
BEGIN
    IF NEW.JoiningDate BETWEEN OLD.JoiningDate AND (CURDATE() + INTERVAL 1 Year)
    AND OLD.LeavingDate IS NOT NULL 
    OR NEW.JoiningDate = CURDATE() 
    AND OLD.LeavingDate IS NOT NULL THEN
        SET NEW.LeavingDate = NULL;
    END IF;
END//
DELIMITER ;
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS UPDATE_LeavingDateIsValid;
DELIMITER // 
CREATE TRIGGER UPDATE_LeavingDateIsValid 
BEFORE UPDATE ON teammember
  FOR EACH ROW 
  BEGIN 
    DECLARE err CONDITION FOR SQLSTATE '02000';
    IF NEW.LeavingDate IS NOT NULL 
    AND New.LeavingDate < Old.JoiningDate THEN
    SET NEW.LeavingDate = Old.LeavingDate;
    SIGNAL err SET MESSAGE_TEXT = 'The players leaving date cannot be before the 
      date they joined. Resetting to previous value.';
    END IF;
END // 
DELIMITER ;
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS UPDATE_JoinDateIsValid;
DELIMITER //
CREATE TRIGGER UPDATE_JoinDateIsValid BEFORE UPDATE ON teammember
FOR EACH ROW
BEGIN
  DECLARE err CONDITION FOR SQLSTATE '02000';
  IF NEW.JoiningDate < OLD.JoiningDate THEN
    SET NEW.JoiningDate = OLD.JoiningDate;
    SIGNAL err SET MESSAGE_TEXT = 'New Join Date Cannot Be Before The Old Join Date. Date reset to the previous value';
    ELSEIF New.JoiningDate > (CURDATE() + INTERVAL 1 MONTH) THEN
    SET NEW.JoiningDate = OLD.JoiningDate;
    SIGNAL err SET MESSAGE_TEXT = 'Join Date More Than 1 Month In the Future. Date Reset to The previous value.';
    END IF;
END//
DELIMITER ;
-----------------------------------------------------------------------------
----------------------    START VIEW DECLARATIONS   -------------------------
-----------------------------------------------------------------------------
DROP VIEW IF EXISTS CurrentPlayerList;
CREATE VIEW CurrentPlayerList
AS 
SELECT 
    pl.PlayerName AS 'Player_Name', 
    TIMESTAMPDIFF(YEAR, pl.DateOfBirth, CURDATE()) AS 'Age',
    pl.PlayerEmail AS 'Email', 
    pl.PlayerPhone AS 'Phone_#', 
    t.TeamName AS 'Team_Name',
    DATE_FORMAT(tm.JoiningDate, '%d-%m-%Y') As 'Joining_Date'
FROM team AS t
JOIN teammember tm
ON t.TeamID = tm.TeamID
JOIN player pl
ON tm.PlayerID = pl.PlayerID
AND tm.LeavingDate IS NULL;
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
DROP VIEW IF EXISTS PlayerGoalCount;
CREATE VIEW PlayerGoalCount AS 
SELECT
    p.PlayerName AS 'Player_Name',
    t.TeamName AS 'Team_Name',
    DATE(g.GoalDateTime) AS 'Match_Date',
    COUNT(g.PlayerID) AS 'Goal_Count',
    GROUP_CONCAT(DATE_FORMAT(TIME(g.GoalDateTime),'%h:%i %p') SEPARATOR ', ') AS 'Goal_Time(s)'
FROM squadmember AS sq
INNER JOIN goal AS g
ON sq.MatchID = g.MatchID
AND sq.PlayerID = g.PlayerID
JOIN teammember tm
ON sq.PlayerID = tm.PlayerID 
AND sq.TeamID = tm.TeamID
JOIN team t 
ON tm.TeamID = t.TeamID
JOIN player p
ON tm.PlayerID = p.PlayerID
GROUP BY sq.PlayerID,
g.PlayerID,g.MatchID,sq.MatchID
ORDER BY p.PlayerName;
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
DROP VIEW IF EXISTS MembershipDuration;
CREATE VIEW IF NOT EXISTS MembershipDuration
AS
SELECT 
    t.TeamName AS 'Team_Name',
    ROUND(
      AVG(
        (
          CASE WHEN tm.LeavingDate IS NULL 
              THEN TIMESTAMPDIFF(DAY,tm.JoiningDate,CURDATE())
              ELSE TIMESTAMPDIFF(DAY,tm.JoiningDate,tm.LeavingDate)
          END
        )
      ),
    0) AS 'Average_Membership_Days'
FROM team t
INNER JOIN teammember tm
ON t.TeamID = tm.TeamID
GROUP BY tm.TeamID;
-----------------------------------------------------------------------------
-------------------END LEGGTC1_SCHEMA.SQL DECLARATIONS-----------------------
-----------------------------------------------------------------------------