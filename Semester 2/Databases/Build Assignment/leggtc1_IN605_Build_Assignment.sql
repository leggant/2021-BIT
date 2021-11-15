-----------------------------------------------------------------------------
---------------------leggtc1_IN605_Build_Assignment--------------------------
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

-----------------------------------------------------------------------------
-------------------START LEGGTC1_DATA.SQL DECLARATIONS-----------------------
-----------------------------------------------------------------------------
USE `leggtc1_sportclub`;
-- --------------------------------------------------------
--
-- INSERT DATA INTO TEAM TABLE
--
INSERT INTO team 
(TeamName, ContactPersonName, ContactPhone, ContactEmail) 
VALUES 
('Pannier Home Ing', 'Alexandro Shoobridge', '021-9204753', 'ashoobridge0@gmail.co.nz'),
('Latlux Viva', 'Aileen Bryers', '025-0784196', 'abryers1@gmail.co.nz'),
('Span Bitchip', 'Lock Hast', '025-6669003', 'lhast2@gmail.co.nz'),
('Voyatouch Greenlam', 'Sarge Capnerhurst', '029-2863053', 'scapnerhurst3@gmail.co.nz'),
('It Home Ing', 'Howie Gurery', '029-7694131', 'hgurery4@gmail.co.nz'),
('Wrapsafe Otcom', 'Dodi Pentercost', '027-0250888', 'dpentercost5@gmail.co.nz'),
('Zathin FINTOne', 'Pepe Spratt', '027-2681647', 'pspratt6@gmail.co.nz'),
('Aerified Span', 'Alvan Denholm', '029-6940738', 'adenholm7@gmail.co.nz'),
('FINTOne Span', 'Jory Lohrensen', '029-7255959', 'jlohrensen8@gmail.co.nz'),
('Subin Redhold', 'Dyann Farre', '029-8344799', 'dfarre9@gmail.co.nz');

-- --------------------------------------------------------
--
-- INSERT DATA INTO UMPIRE TABLE
--

INSERT INTO umpire (UmpireName) 
VALUES
('Roseanne Matuszynski'),
('Cedric Oselton'),
('Mattie Guthrum'),
('Merline Aldrin'),
('Rosalinda Cornwell'),
('Ilaire Kochl'),
('Patricio Desantis'),
('Timothy Talton'),
('Lilllie Farnan'),
('Clarine Stoak'),
('Lil Eland'),
('Vladimir Gaspar'),
('Alverta Raddin'),
('Hyacintha Eckery'),
('Basilius Lapere'),
('Lian McTurlough'),
('Putnam Vallentin'),
('Sena Gorick'),
('Jenn Grimwad'),
('Tadio Midson');

-- --------------------------------------------------------
--
-- INSERT DATA INTO GROUNDS TABLE
--

INSERT INTO ground (GroundName, GroundAddress) 
VALUES 
('Runolfsdottir-Parisian Sports Ground', '82 Ridgeway Drive, Timaru'),
('Okuneva, McLaughlin and Collins Sports Ground', '82 Forster Alley, Oamaru'),
('Collins, Kub and Schaefer Sports Ground', '51153 Dunning Point, Dunedin'),
('Hagenes Group Indoor Sports', '03697 Autumn Leaf Junction, Dunedin'),
('West LLC Stadium', '039 Rigney Avenue, Dunedin'),
('Konopelski-Kuvalis Center', '28 Schlimgen Plaza, Dunedin'),
('Lindgren, Corwin and Huels Stadium', '79 Mitchell Drive, Queenstown'),
('Marvin, Powlowski and Padberg Center', '0875 Clove Street, Dunedin'),
('Langworth, Dare and Kozey Center', '2728 Sunnyside Street, Christchurch'),
('Berge-Lynch Sports Ground', '0 Hooker Drive, Christchurch'),
('Wisozk, Lind and Zboncak Stadium', '2872 7th Place, Queenstown'),
('Jacobs and Sons Center', '06219 Mayer Park, Oamaru'),
('Shields, Bailey and Funk Indoor Sports', '472 Sutteridge Way, Invercargill'),
('Casper Group Center', '59 Rieder Crossing, Invercargill'),
('Frami LLC Center', '224 Tennyson Point, Christchurch'),
('Price Inc Indoor Sports', '97 Ryan Place, Timaru'),
('Heathcote, Wilderman and Borer Indoor Sports', '3 Birchwood Pass, Invercargill'),
('Berge-Satterfield Indoor Sports', '63 Autumn Leaf Terrace, Queenstown'),
('Lockman Group Center', '8 Banding Terrace, Queenstown'),
('McDermott Inc Indoor Sports', '95 Butternut Terrace, Oamaru'),
('Howe, O''Reilly and D''Amore Center', '3061 Harbort Avenue, Invercargill'),
('Mann, Hartmann and Hayes Indoor Sports', '54351 Hudson Junction, Christchurch'),
('Emmerich-Turner Center', '631 Sunbrook Terrace, Christchurch'),
('Gleichner, Cruickshank and Reilly Stadium', '1 Packers Way, Oamaru'),
('Swaniawski-Fay Indoor Sports', '6 Fordem Junction, Dunedin'),
('Ernser-Weber Center', '19426 Armistice Lane, Invercargill'),
('Hamill, Hartmann and Schmidt Stadium', '098 Meadow Valley Drive, Invercargill'),
('Homenick, Leannon and Stiedemann Stadium', '6296 Drewry Plaza, Dunedin'),
('Streich and Sons Indoor Sports', '86 Loftsgordon Center, Christchurch'),
('Ebert-Grady Indoor Sports', '913 Lakewood Gardens Center, Dunedin');

-- --------------------------------------------------------

--
-- INSERT DATA INTO PLAYER TABLE
--

CALL InsertPlayer (
    'Constantina Dechelette',
    'cdechelette@gmail.co.nz',
    '025-0846262',
    '1992-07-29',
    1,
    '2016-10-25',
    NULL,
    @id
);

CALL InsertPlayer (
    'La verne Dreye',
    'lverne1@gmail.co.nz',
    '021-3981514',
    '2000-11-23',
    2,
    '2019-08-14',
    NULL,
    @id
);

CALL InsertPlayer (
    'Rand Berggren',
    'rberggren2@gmail.co.nz',
    '027-3968638',
    '1999-06-21',
    3,
    '2011-12-17',
    NULL,
    @id
);

CALL InsertPlayer (
    'Colene Cork',
    'ccork3@gmail.co.nz',
    '027-3528555',
    '1998-07-10',
    4,
    '2019-05-15',
    NULL,
    @id
);

CALL InsertPlayer (
    'Alexander Burnet',
    'aburnet4@gmail.co.nz',
    '027-0023255',
    '2001-05-21',
    5,
    '2018-11-14',
    NULL,
    @id
);

CALL InsertPlayer (
    'Ansley Ragless',
    'aragless5@gmail.co.nz',
    '021-1071626',
    '2000-05-22',
    6,
    '2017-05-27',
    '2018-05-28',
    @id
);

CALL InsertPlayer (
    'Thorvald Rabbitt',
    'trabbitt6@gmail.co.nz',
    '025-4935107',
    '2000-04-05',
    7,
    '2016-02-15',
    NULL,
    @id
);

CALL InsertPlayer (
    'Elmer Behrens',
    'ebehrens7@gmail.co.nz',
    '029-5462323',
    '2000-01-21',
    8,
    '2016-05-26',
    NULL,
    @id
);

CALL InsertPlayer (
    'Genevieve Lorait',
    'glorait8@gmail.co.nz',
    '029-6604665',
    '2000-04-17',
    9,
    '2014-05-22',
    NULL,
    @id
);

CALL InsertPlayer (
    'Niko Perllman',
    'nperllman9@gmail.co.nz',
    '029-8028622',
    '2002-01-05',
    10,
    '2014-12-07',
    NULL,
    @id
);

CALL InsertPlayer (
    'Dietrich Askell',
    'daskella@gmail.co.nz',
    '025-6802709',
    '1992-12-19',
    1,
    '2018-06-26',
    NULL,
    @id
);

CALL InsertPlayer (
    'Lola Luter',
    'lluterb@gmail.co.nz',
    '029-8829727',
    '1993-09-24',
    2,
    '2012-02-05',
    NULL,
    @id
);

CALL InsertPlayer (
    'Nessi McGarry',
    'nmcgarryc@gmail.co.nz',
    '027-0871417',
    '2003-09-03',
    3,
    '2019-10-05',
    NULL,
    @id
);

CALL InsertPlayer (
    'Blanche Mattia',
    'bmattiad@gmail.co.nz',
    '029-5124382',
    '2001-06-08',
    4,
    '2010-10-24',
    NULL,
    @id
);

CALL InsertPlayer (
    'Silvie Le Brum',
    'slee@gmail.co.nz',
    '025-3117169',
    '1991-12-10',
    5,
    '2019-05-13',
    NULL,
    @id
);

CALL InsertPlayer (
    'Killy Bexon',
    'kbexonf@gmail.co.nz',
    '029-8163660',
    '1997-05-21',
    6,
    '2020-07-25',
    NULL,
    @id
);

CALL InsertPlayer (
    'Jesselyn Zoppo',
    'jzoppog@gmail.co.nz',
    '029-0631651',
    '1995-09-14',
    7,
    '2010-10-25',
    NULL,
    @id
);

CALL InsertPlayer (
    'Gian Lacky',
    'glackyh@gmail.co.nz',
    '029-6166024',
    '1993-05-21',
    8,
    '2016-10-27',
    '2019-03-31',
    @id
);

CALL InsertPlayer (
    'Gothart Loving',
    'glovingi@gmail.co.nz',
    '027-0384662',
    '1994-11-27',
    9,
    '2021-06-13',
    NULL,
    @id
);

CALL InsertPlayer (
    'Carlo Clewley',
    'cclewleyj@gmail.co.nz',
    '025-4450342',
    '1993-04-06',
    10,
    '2014-01-26',
    NULL,
    @id
);

CALL InsertPlayer (
    'Shae Mc Andrew',
    'smck@gmail.co.nz',
    '029-8739702',
    '2002-03-21',
    1,
    '2013-02-16',
    '2016-02-27',
    @id
);

CALL InsertPlayer (
    'Vally Clibbery',
    'vclibberyl@gmail.co.nz',
    '029-7296659',
    '1993-11-12',
    2,
    '2020-12-25',
    NULL,
    @id
);

CALL InsertPlayer (
    'Bink Pote',
    'bpotem@gmail.co.nz',
    '029-8715117',
    '1998-03-08',
    3,
    '2010-08-21',
    NULL,
    @id
);

CALL InsertPlayer (
    'Charmane Drews',
    'cdrewsn@gmail.co.nz',
    '029-0946033',
    '1996-10-10',
    4,
    '2017-04-23',
    '2019-01-20',
    @id
);

CALL InsertPlayer (
    'Abbie Delahunty',
    'adelahuntyo@gmail.co.nz',
    '029-1341106',
    '2002-02-11',
    5,
    '2014-08-05',
    '2017-03-18',
    @id
);

CALL InsertPlayer (
    'Leighton Razzell',
    'lrazzellp@gmail.co.nz',
    '021-9226810',
    '2002-08-18',
    6,
    '2014-11-12',
    NULL,
    @id
);

CALL InsertPlayer (
    'Iormina Venable',
    'ivenableq@gmail.co.nz',
    '027-8389396',
    '1997-07-28',
    7,
    '2021-10-02',
    NULL,
    @id
);

CALL InsertPlayer (
    'Annecorinne Gauntley',
    'agauntleyr@gmail.co.nz',
    '021-1015809',
    '1992-09-27',
    8,
    '2013-08-30',
    NULL,
    @id
);

CALL InsertPlayer (
    'Tana Downie',
    'tdownies@gmail.co.nz',
    '025-6041448',
    '2003-07-15',
    9,
    '2021-07-26',
    NULL,
    @id
);

CALL InsertPlayer (
    'Gabriel Mauser',
    'gmausert@gmail.co.nz',
    '029-1895354',
    '2003-02-09',
    10,
    '2014-01-22',
    NULL,
    @id
);

CALL InsertPlayer (
    'Nesta Mokes',
    'nmokesu@gmail.co.nz',
    '029-4741912',
    '2002-08-14',
    1,
    '2014-07-09',
    NULL,
    @id
);

CALL InsertPlayer (
    'Sarine Mathieu',
    'smathieuv@gmail.co.nz',
    '029-4294554',
    '1997-09-16',
    2,
    '2013-10-21',
    NULL,
    @id
);

CALL InsertPlayer (
    'Marve Murrill',
    'mmurrillw@gmail.co.nz',
    '029-2660985',
    '1996-09-22',
    3,
    '2013-03-27',
    '2021-12-20',
    @id
);

CALL InsertPlayer (
    'Starlin Roskruge',
    'sroskrugex@gmail.co.nz',
    '029-5445330',
    '2002-04-28',
    4,
    '2020-07-24',
    NULL,
    @id
);

CALL InsertPlayer (
    'Nydia House',
    'nhousey@gmail.co.nz',
    '025-6385382',
    '2001-01-15',
    5,
    '2013-10-20',
    NULL,
    @id
);

CALL InsertPlayer (
    'Deane MacMarcuis',
    'dmacmarcuisz@gmail.co.nz',
    '025-4926148',
    '2002-05-27',
    6,
    '2010-01-02',
    NULL,
    @id
);

CALL InsertPlayer (
    'Melodie Bebbell',
    'mbebbell10@gmail.co.nz',
    '021-4534591',
    '1993-05-27',
    7,
    '2020-12-15',
    NULL,
    @id
);

CALL InsertPlayer (
    'Leontine Warbrick',
    'lwarbrick11@gmail.co.nz',
    '025-7284995',
    '1994-11-20',
    8,
    '2013-11-09',
    NULL,
    @id
);

CALL InsertPlayer (
    'Jacky Bankhurst',
    'jbankhurst12@gmail.co.nz',
    '029-9996973',
    '2003-07-06',
    9,
    '2011-09-19',
    '2019-01-21',
    @id
);

CALL InsertPlayer (
    'Cicely McFayden',
    'cmcfayden13@gmail.co.nz',
    '029-8842738',
    '2002-06-19',
    10,
    '2014-08-09',
    NULL,
    @id
);

CALL InsertPlayer (
    'Marcello Starr',
    'mstarr14@gmail.co.nz',
    '029-2118739',
    '1996-04-02',
    1,
    '2018-03-04',
    NULL,
    @id
);

CALL InsertPlayer (
    'Leontine Tanzer',
    'ltanzer15@gmail.co.nz',
    '025-0432983',
    '2003-02-01',
    2,
    '2011-09-21',
    NULL,
    @id
);

CALL InsertPlayer (
    'Markos Gee',
    'mgee16@gmail.co.nz',
    '021-4227799',
    '2000-12-16',
    3,
    '2016-09-22',
    NULL,
    @id
);

CALL InsertPlayer (
    'Adah Aldiss',
    'aaldiss17@gmail.co.nz',
    '025-6931852',
    '2003-04-26',
    4,
    '2012-07-01',
    NULL,
    @id
);

CALL InsertPlayer (
    'Collen Mioni',
    'cmioni18@gmail.co.nz',
    '025-4569506',
    '1993-01-30',
    5,
    '2020-08-12',
    NULL,
    @id
);

CALL InsertPlayer (
    'Timothy Jencken',
    'tjencken19@gmail.co.nz',
    '027-7728119',
    '2000-05-06',
    6,
    '2021-03-14',
    NULL,
    @id
);

CALL InsertPlayer (
    'Gwendolen Garey',
    'ggarey1a@gmail.co.nz',
    '029-7098045',
    '2001-12-24',
    7,
    '2021-08-04',
    NULL,
    @id
);

CALL InsertPlayer (
    'Evita Coleford',
    'ecoleford1b@gmail.co.nz',
    '029-0133875',
    '1996-05-08',
    8,
    '2020-12-21',
    NULL,
    @id
);

CALL InsertPlayer (
    'Corliss Bollom',
    'cbollom1c@gmail.co.nz',
    '025-9967614',
    '1994-09-11',
    9,
    '2017-08-13',
    NULL,
    @id
);

CALL InsertPlayer (
    'Gayel Gosalvez',
    'ggosalvez1d@gmail.co.nz',
    '029-6817232',
    '1996-12-12',
    10,
    '2016-04-27',
    NULL,
    @id
);

CALL InsertPlayer (
    'Sande Gunstone',
    'sgunstone1e@gmail.co.nz',
    '029-4897404',
    '1991-10-17',
    1,
    '2021-02-26',
    NULL,
    @id
);

CALL InsertPlayer (
    'Dill Bonny',
    'dbonny1f@gmail.co.nz',
    '025-3613853',
    '1995-09-21',
    2,
    '2017-09-08',
    NULL,
    @id
);

CALL InsertPlayer (
    'Monti Godbert',
    'mgodbert1g@gmail.co.nz',
    '029-2483624',
    '2000-10-29',
    3,
    '2017-12-13',
    NULL,
    @id
);

CALL InsertPlayer (
    'Darrel Quested',
    'dquested1h@gmail.co.nz',
    '029-6644442',
    '2003-08-18',
    4,
    '2016-11-09',
    NULL,
    @id
);

CALL InsertPlayer (
    'Cecilla Dowsey',
    'cdowsey1i@gmail.co.nz',
    '029-3800473',
    '2002-03-25',
    5,
    '2014-10-16',
    NULL,
    @id
);

CALL InsertPlayer (
    'Melonie Dullaghan',
    'mdullaghan1j@gmail.co.nz',
    '029-1045336',
    '1993-06-18',
    6,
    '2014-03-27',
    NULL,
    @id
);

CALL InsertPlayer (
    'Nelie Perillo',
    'nperillo1k@gmail.co.nz',
    '029-9679878',
    '2001-09-15',
    7,
    '2010-02-13',
    NULL,
    @id
);

CALL InsertPlayer (
    'Kally Cuberley',
    'kcuberley1l@gmail.co.nz',
    '029-2026581',
    '1994-07-31',
    8,
    '2016-04-29',
    '2019-05-20',
    @id
);

CALL InsertPlayer (
    'Sasha Standbrook',
    'sstandbrook1m@gmail.co.nz',
    '029-3790925',
    '2002-06-30',
    9,
    '2014-06-04',
    '2016-03-07',
    @id
);

CALL InsertPlayer (
    'Jackelyn Parkman',
    'jparkman1n@gmail.co.nz',
    '029-3499358',
    '2001-10-01',
    10,
    '2014-05-24',
    '2016-06-19',
    @id
);

CALL InsertPlayer (
    'Elisha Emmerson',
    'eemmerson1o@gmail.co.nz',
    '029-0180232',
    '2001-12-09',
    1,
    '2021-05-06',
    NULL,
    @id
);

CALL InsertPlayer (
    'Annmarie Grindell',
    'agrindell1p@gmail.co.nz',
    '029-9622936',
    '1993-02-07',
    2,
    '2018-10-12',
    '2020-07-14',
    @id
);

CALL InsertPlayer (
    'Uriah Carlin',
    'ucarlin1q@gmail.co.nz',
    '025-4843160',
    '2001-01-01',
    3,
    '2016-09-23',
    '2018-08-20',
    @id
);

CALL InsertPlayer (
    'Mersey Napoleon',
    'mnapoleon1r@gmail.co.nz',
    '025-5484442',
    '2003-08-02',
    4,
    '2014-04-02',
    '2015-10-07',
    @id
);

CALL InsertPlayer (
    'Euphemia Kinglake',
    'ekinglake1s@gmail.co.nz',
    '029-5940784',
    '1997-01-31',
    5,
    '2016-01-06',
    '2016-09-15',
    @id
);

CALL InsertPlayer (
    'Pauli Vescovo',
    'pvescovo1t@gmail.co.nz',
    '025-8771086',
    '1996-07-10',
    6,
    '2020-12-13',
    NULL,
    @id
);

CALL InsertPlayer (
    'Sada Massow',
    'smassow1u@gmail.co.nz',
    '027-0904578',
    '1994-05-04',
    7,
    '2018-03-06',
    NULL,
    @id
);

CALL InsertPlayer (
    'Cal Vasic',
    'cvasic1v@gmail.co.nz',
    '029-8930441',
    '1994-11-20',
    8,
    '2012-09-12',
    NULL,
    @id
);

CALL InsertPlayer (
    'Cherice le Keux',
    'cle1w@gmail.co.nz',
    '029-9222780',
    '1998-01-13',
    9,
    '2018-06-04',
    NULL,
    @id
);

CALL InsertPlayer (
    'Nicol Beckerleg',
    'nbeckerleg1x@gmail.co.nz',
    '025-4977947',
    '1998-08-23',
    10,
    '2015-07-16',
    NULL,
    @id
);

CALL InsertPlayer (
    'Sibby Skeath',
    'sskeath1y@gmail.co.nz',
    '027-5019798',
    '1992-03-10',
    1,
    '2021-03-18',
    NULL,
    @id
);

CALL InsertPlayer (
    'Cam Layson',
    'clayson1z@gmail.co.nz',
    '029-6821962',
    '1994-01-22',
    2,
    '2018-05-19',
    NULL,
    @id
);

CALL InsertPlayer (
    'Sophi Wethey',
    'swethey20@gmail.co.nz',
    '027-1655989',
    '2003-03-19',
    3,
    '2016-08-19',
    NULL,
    @id
);

CALL InsertPlayer (
    'Aubrette Lorincz',
    'alorincz21@gmail.co.nz',
    '021-9314457',
    '1991-12-26',
    4,
    '2021-03-02',
    NULL,
    @id
);

CALL InsertPlayer (
    'Erma Yeabsley',
    'eyeabsley22@gmail.co.nz',
    '027-4999480',
    '2002-09-28',
    5,
    '2012-07-27',
    NULL,
    @id
);

CALL InsertPlayer (
    'Cassandra Coole',
    'ccoole23@gmail.co.nz',
    '027-5931747',
    '1998-10-30',
    6,
    '2018-04-07',
    NULL,
    @id
);

CALL InsertPlayer (
    'Chevy Bedome',
    'cbedome24@gmail.co.nz',
    '029-2442825',
    '2001-01-22',
    7,
    '2012-07-09',
    NULL,
    @id
);

CALL InsertPlayer (
    'Bron Broxton',
    'bbroxton25@gmail.co.nz',
    '029-1423696',
    '2000-12-07',
    8,
    '2017-08-01',
    NULL,
    @id
);

CALL InsertPlayer (
    'Valeda Perin',
    'vperin26@gmail.co.nz',
    '029-4525353',
    '1993-08-11',
    9,
    '2020-06-28',
    NULL,
    @id
);

CALL InsertPlayer (
    'Maurise Seilmann',
    'mseilmann27@gmail.co.nz',
    '027-8643942',
    '1990-01-28',
    10,
    '2017-03-30',
    NULL,
    @id
);

CALL InsertPlayer (
    'Elianora Kleinhaus',
    'ekleinhaus28@gmail.co.nz',
    '029-3842849',
    '1990-03-03',
    1,
    '2020-01-27',
    NULL,
    @id
);

CALL InsertPlayer (
    'Dame Luxton',
    'dluxton29@gmail.co.nz',
    '021-3731735',
    '2002-11-27',
    2,
    '2018-12-12',
    NULL,
    @id
);

CALL InsertPlayer (
    'Lief Vedyaev',
    'lvedyaev2a@gmail.co.nz',
    '029-3396455',
    '2002-02-28',
    3,
    '2018-05-18',
    '2019-10-27',
    @id
);

CALL InsertPlayer (
    'Fonsie Yanez',
    'fyanez2b@gmail.co.nz',
    '029-5851533',
    '1991-05-10',
    4,
    '2015-11-17',
    NULL,
    @id
);

CALL InsertPlayer (
    'Bourke Cotilard',
    'bcotilard2c@gmail.co.nz',
    '029-6003257',
    '1992-04-12',
    5,
    '2013-06-06',
    '2013-09-16',
    @id
);

CALL InsertPlayer (
    'Daryl Rearden',
    'drearden2d@gmail.co.nz',
    '029-4401502',
    '1997-12-18',
    6,
    '2017-05-24',
    '2019-11-12',
    @id
);

CALL InsertPlayer (
    'Alphard Lumbly',
    'alumbly2e@gmail.co.nz',
    '029-2964173',
    '2002-07-09',
    7,
    '2010-12-31',
    NULL,
    @id
);

CALL InsertPlayer (
    'Duff Tuhy',
    'dtuhy2f@gmail.co.nz',
    '025-5371905',
    '2002-05-25',
    8,
    '2014-03-09',
    NULL,
    @id
);

CALL InsertPlayer (
    'Anallise Kirimaa',
    'akirimaa2g@gmail.co.nz',
    '021-6909201',
    '1996-11-06',
    9,
    '2015-09-18',
    NULL,
    @id
);

CALL InsertPlayer (
    'Glori Slora',
    'gslora2h@gmail.co.nz',
    '029-9818998',
    '2002-06-14',
    10,
    '2018-03-25',
    NULL,
    @id
);

CALL InsertPlayer (
    'Halsey Neads',
    'hneads2i@gmail.co.nz',
    '029-4551173',
    '2001-10-23',
    1,
    '2015-11-02',
    NULL,
    @id
);

CALL InsertPlayer (
    'Lizbeth Fossick',
    'lfossick2j@gmail.co.nz',
    '029-0430668',
    '1999-01-03',
    2,
    '2015-08-06',
    '2018-01-09',
    @id
);

CALL InsertPlayer (
    'Cecilia Stansbie',
    'cstansbie2k@gmail.co.nz',
    '025-9555086',
    '2002-11-29',
    3,
    '2015-05-29',
    NULL,
    @id
);

CALL InsertPlayer (
    'Link Jemmison',
    'ljemmison2l@gmail.co.nz',
    '027-1743552',
    '2001-11-21',
    4,
    '2015-05-27',
    NULL,
    @id
);

CALL InsertPlayer (
    'Anetta Tinton',
    'atinton2m@gmail.co.nz',
    '029-3560419',
    '2000-07-03',
    5,
    '2020-04-02',
    NULL,
    @id
);

CALL InsertPlayer (
    'Georgianne Felix',
    'gfelix2n@gmail.co.nz',
    '025-6090173',
    '1993-04-14',
    6,
    '2012-07-22',
    NULL,
    @id
);

CALL InsertPlayer (
    'Phillie Witz',
    'pwitz2o@gmail.co.nz',
    '027-0622723',
    '2002-05-25',
    7,
    '2012-11-02',
    NULL,
    @id
);

CALL InsertPlayer (
    'Giorgio O''Dennehy',
    'godennehy2p@gmail.co.nz',
    '029-4269129',
    '1993-03-23',
    8,
    '2019-03-19',
    NULL,
    @id
);

CALL InsertPlayer (
    'Devin Frary',
    'dfrary2q@gmail.co.nz',
    '025-2849365',
    '1997-05-07',
    9,
    '2014-09-07',
    '2019-06-20',
    @id
);

CALL InsertPlayer (
    'Neille Bentame',
    'nbentame2r@gmail.co.nz',
    '025-9690581',
    '1991-07-11',
    10,
    '2012-11-24',
    NULL,
    @id
);

CALL InsertPlayer (
    'Jennette Culverhouse',
    'jculverhouse2s@gmail.co.nz',
    '029-0456034',
    '2002-12-22',
    1,
    '2016-06-25',
    '2020-09-12',
    @id
);

CALL InsertPlayer (
    'Pegeen Meier',
    'pmeier2t@gmail.co.nz',
    '025-8728652',
    '1995-08-07',
    2,
    '2018-02-12',
    NULL,
    @id
);

CALL InsertPlayer (
    'Melloney Clemmen',
    'mclemmen2u@gmail.co.nz',
    '025-9961657',
    '2000-04-30',
    3,
    '2014-02-27',
    NULL,
    @id
);

CALL InsertPlayer (
    'Lainey Bax',
    'lbax2v@gmail.co.nz',
    '021-2983837',
    '1998-08-22',
    4,
    '2012-07-09',
    NULL,
    @id
);

CALL InsertPlayer (
    'Fran Josephov',
    'fjosephov2w@gmail.co.nz',
    '029-5769536',
    '2002-07-29',
    5,
    '2017-04-09',
    NULL,
    @id
);

CALL InsertPlayer (
    'Evangelina Boaler',
    'eboaler2x@gmail.co.nz',
    '029-8830791',
    '1995-12-16',
    6,
    '2013-07-26',
    NULL,
    @id
);

CALL InsertPlayer (
    'Alphonse Burker',
    'aburker2y@gmail.co.nz',
    '027-7779271',
    '1995-08-29',
    7,
    '2010-06-24',
    NULL,
    @id
);

CALL InsertPlayer (
    'Edy Kield',
    'ekield2z@gmail.co.nz',
    '029-6981327',
    '2002-02-16',
    8,
    '2015-03-13',
    NULL,
    @id
);

CALL InsertPlayer (
    'Derby Clarage',
    'dclarage30@gmail.co.nz',
    '029-7865654',
    '1991-11-21',
    9,
    '2020-02-04',
    NULL,
    @id
);

CALL InsertPlayer (
    'Amata Aime',
    'aaime31@gmail.co.nz',
    '029-5087276',
    '1998-08-24',
    10,
    '2010-09-19',
    NULL,
    @id
);

CALL InsertPlayer (
    'Ingeberg Urey',
    'iurey32@gmail.co.nz',
    '027-5376960',
    '1996-09-04',
    1,
    '2021-12-01',
    NULL,
    @id
);

CALL InsertPlayer (
    'Grayce Rove',
    'grove33@gmail.co.nz',
    '025-5813211',
    '2001-03-23',
    2,
    '2016-10-12',
    '2019-08-21',
    @id
);

CALL InsertPlayer (
    'Kit Jowling',
    'kjowling34@gmail.co.nz',
    '021-0195244',
    '2002-07-02',
    3,
    '2018-07-22',
    NULL,
    @id
);

CALL InsertPlayer (
    'Corrina Fradgley',
    'cfradgley35@gmail.co.nz',
    '025-6846229',
    '2002-06-06',
    4,
    '2021-10-02',
    NULL,
    @id
);

CALL InsertPlayer (
    'Germana Adnett',
    'gadnett36@gmail.co.nz',
    '029-6086999',
    '2001-10-15',
    5,
    '2011-04-10',
    NULL,
    @id
);

CALL InsertPlayer (
    'Mattie Sellner',
    'msellner37@gmail.co.nz',
    '029-5590241',
    '2002-10-29',
    6,
    '2011-12-02',
    NULL,
    @id
);

CALL InsertPlayer (
    'Olenka Samwaye',
    'osamwaye38@gmail.co.nz',
    '029-3020562',
    '1999-10-30',
    7,
    '2011-10-18',
    '2014-07-27',
    @id
);

CALL InsertPlayer (
    'Patrice Danelutti',
    'pdanelutti39@gmail.co.nz',
    '025-8717303',
    '1990-01-05',
    8,
    '2017-08-10',
    NULL,
    @id
);

CALL InsertPlayer (
    'Daniella Stannus',
    'dstannus3a@gmail.co.nz',
    '029-1028469',
    '1998-06-10',
    9,
    '2021-06-05',
    NULL,
    @id
);

CALL InsertPlayer (
    'Itch Di Giacomo',
    'idi3b@gmail.co.nz',
    '029-5870420',
    '1998-07-24',
    10,
    '2015-10-22',
    '2018-07-19',
    @id
);
-- --------------------------------------------------------
--
-- INSERT DATA INTO MATCH TABLE
--
INSERT INTO `match` (MatchID, MatchGroundID, MatchStart) 
VALUES
(1, 5, '2021-07-20 15:00:00'),
(2, 11, '2021-07-19 14:00:00'),
(3, 4, '2021-01-24 09:00:00'),
(4, 17, '2021-08-23 10:00:00'),
(5, 8, '2021-01-14 15:00:00'),
(6, 1, '2020-06-13 09:00:00'),
(7, 23, '2021-06-06 13:00:00'),
(8, 5, '2020-09-25 13:00:00'),
(9, 14, '2021-02-21 17:30:00'),
(10, 30, '2021-01-11 16:00:00');
-- --------------------------------------------------------
--
-- INSERT DATA INTO UMPIRE DUTY TABLE
--
INSERT INTO
    umpireduty (MatchID, MatchUmpireID)
VALUES
(1, 7),(2, 14),(3, 16),(4, 13),(5, 4),(6, 7),(7, 15),(8, 18),(9, 15),(10, 13),
(1, 15),(2, 4),(3, 18),(4, 8),(5, 11),(6, 8),(7, 18),(8, 20),(9, 3),(10, 20);
-- --------------------------------------------------------
--
-- INSERT DATA INTO TEAM MATCH TABLE
--
INSERT INTO teammatch (MatchID, TeamID) 
VALUES 
(1, 4),(1, 7),
(2, 5),(2, 10),
(3, 5),(3, 3),
(4, 8),(4, 6),
(5, 8),(5, 9),
(6, 1),(6, 3),
(7, 10),(7, 1),
(8, 8),(8, 1),
(9, 7),(9, 2),
(10, 3),(10, 4);
-- --------------------------------------------------------
--
-- INSERT DATA INTO ACCInjuryType TABLE
--
INSERT INTO
    accinjurytype (ACCInjuryCode, InjuryTypeName)
VALUES
    ('2100313679', 'Ankle Sprain'),
    ('3182824898', 'Hamstring strain'),
    ('7330101800', 'Shin Splints'),
    ('9816527540', 'Knee injury'),
    ('9494128377', 'Tennis elbow '),
    ('7851384485', 'Fracture'),
    ('1363394030', 'Concussion'),
    ('5090358566', 'Dislocated Shoulder'),
    ('3299606695', 'Spinal Injury'),
    ('2183332084', 'Neck Fracture'),
    ('6758896818', 'Broken Leg'),
    ('1431923222', 'Anterior Cruciate Ligament (ACL)'),
    ('4730264977', 'Rotator Cuff Injury'),
    ('1667733809', 'Hip Flexor Injury');
------------------------------------------------------------------------------------------------
--- INSERT DATA INTO SQUAD MEMBER TABLE
------------------------------------------------------------------------------------------------
--- Match 1
CALL Set_InitalSquad(4, 1);
CALL Set_InitalSquad(7, 1);
--- Match 2
CALL Set_InitalSquad(5, 2);
CALL Set_InitalSquad(10, 2);
--- Match 3
CALL Set_InitalSquad(3, 3);
CALL Set_InitalSquad(5, 3);
--- Match 4
CALL Set_InitalSquad(6, 4);
CALL Set_InitalSquad(8, 4);
--- Match 5
CALL Set_InitalSquad(8, 5);
CALL Set_InitalSquad(9, 5);
--- Match 6
CALL Set_InitalSquad(1, 6);
CALL Set_InitalSquad(3, 6);
--- Match 7
CALL Set_InitalSquad(1, 7);
CALL Set_InitalSquad(10, 7);
--- Match 8
CALL Set_InitalSquad(2, 8);
CALL Set_InitalSquad(5, 8);
--- Match 9
CALL Set_InitalSquad(3, 9);
CALL Set_InitalSquad(7, 9);
--- Match 10
CALL Set_InitalSquad(6, 10);
CALL Set_InitalSquad(2, 10);
------------------------------------------------------------------------------------------------
--- INSERT DATA INTO Goal Table
------------------------------------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;
INSERT INTO
    goal(MatchID, PlayerID, GoalDateTime)
VALUES
(1, 4, '2021-07-20 15:53:00'),
(1, 7, '2021-07-20 15:40:00'),
(1, 14, '2021-07-20 15:42:00'),
(1, 57, '2021-07-20 15:29:00'),
(1, 84, '2021-07-20 15:27:00'),
(1, 97, '2021-07-20 15:30:00'),
(1, 114, '2021-07-20 15:52:00'),
(2, 35, '2021-07-19 14:08:00'),
(2, 55, '2021-07-19 14:45:00'),
(2, 75, '2021-07-19 14:23:00'),
(2, 100, '2021-07-19 14:03:00'),
(2, 110, '2021-07-19 14:10:00'),
(3, 3, '2021-01-24 10:08:00'),
(3, 15, '2021-01-24 10:16:00'),
(3, 35, '2021-01-24 10:17:00'),
(3, 43, '2021-01-24 10:27:00'),
(3, 63, '2021-01-24 10:22:00'),
(3, 73, '2021-01-24 10:17:00'),
(4, 48, '2021-08-23 11:04:00'),
(4, 88, '2021-08-23 11:12:00'),
(4, 8, '2021-08-23 10:42:00'),
(4, 26, '2021-08-23 10:48:00'),
(4, 38, '2021-08-23 10:05:00'),
(4, 96, '2021-08-23 10:58:00'),
(4, 118, '2021-08-23 11:26:00'),
(5, 38, '2021-01-14 15:23:00'),
(5, 68, '2021-01-14 15:30:00'),
(5, 108, '2021-01-14 15:47:00'),
(5, 28, '2021-01-14 15:51:00'),
(5, 49, '2021-01-14 15:24:00'),
(5, 119, '2021-01-14 15:28:00'),
(6, 1, '2020-06-13 09:33:00'),
(6, 2, '2020-06-13 10:24:00'),
(6, 41, '2020-06-13 10:13:00'),
(6, 43, '2020-06-13 09:24:00'),
(6, 103, '2020-06-13 10:01:00'),
(6, 101, '2020-06-13 09:08:00'),
(7, 1, '2021-06-06 13:14:00'),
(7, 40, '2021-06-06 13:54:00'),
(7, 61, '2021-06-06 13:03:00'),
(7, 100, '2021-06-06 14:29:00'),
(7, 1, '2021-06-06 14:10:00'),
(7, 30, '2021-06-06 14:25:00'),
(7, 70, '2021-06-06 13:23:00'),
(7, 91, '2021-06-06 14:28:00'),
(7, 100, '2021-06-06 13:36:00'),
(8, 2, '2020-09-25 13:22:00'),
(8, 5, '2020-09-25 13:08:00'),
(8, 12, '2020-09-25 13:27:00'),
(8, 42, '2020-09-25 13:55:00'),
(8, 62, '2020-09-25 13:45:00'),
(8, 82, '2020-09-25 13:23:00'),
(8, 92, '2020-09-25 13:02:00'),
(8, 115, '2020-09-25 14:14:00'),
(8, 2, '2020-09-25 14:09:00'),
(8, 22, '2020-09-25 14:13:00'),
(8, 52, '2020-09-25 14:02:00'),
(8, 55, '2020-09-25 13:31:00'),
(8, 115, '2020-09-25 13:18:00'),
(9, 7, '2021-02-21 18:49:00'),
(9, 13, '2021-02-21 18:43:00'),
(9, 53, '2021-02-21 17:52:00'),
(9, 57, '2021-02-21 18:35:00'),
(9, 93, '2021-02-21 17:49:00'),
(9, 33, '2021-02-21 17:51:00'),
(9, 37, '2021-02-21 18:40:00'),
(9, 73, '2021-02-21 17:59:00'),
(9, 93, '2021-02-21 18:30:00'),
(10, 2, '2021-01-11 16:41:00'),
(10, 12, '2021-01-11 16:04:00'),
(10, 46, '2021-01-11 16:19:00'),
(10, 82, '2021-01-11 16:37:00'),
(10, 86, '2021-01-11 16:54:00'),
(10, 26, '2021-01-11 16:17:00'),
(10, 62, '2021-01-11 16:35:00'),
(10, 66, '2021-01-11 16:03:00'),
(10, 102, '2021-01-11 16:44:00'),
(10, 106, '2021-01-11 16:48:00'),
(10, 116, '2021-01-11 16:19:00');
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS=0;
INSERT INTO injuryevent
(PlayerID, MatchID, InjuryEventDateTime, ACCInjuryCode) 
VALUES 
(35, 3, '2021-01-24 09:30:00', '2100313679'),
(100, 2, '2021-07-19 14:45:00', '9816527540'),
(84, 1, '2021-07-20 15:15:00', '3299606695'),
(108, 5, '2021-01-14 15:45:00', '3299606695'),
(41, 6, '2020-06-13 09:18:00', '1363394030'),
(101, 7, '2021-06-06 13:52:00', '4730264977'),
(55, 8, '2020-09-25 13:26:00', '1667733809'),
(93, 9, '2021-02-21 17:46:00', '1363394030');
SET FOREIGN_KEY_CHECKS=1;
-----------------------------------------------------------------------------
--Create Triggers to Check Match Data After The Initial Dataset Is Created---
-----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS INSERT_MatchDateIsValid;
DELIMITER //
CREATE TRIGGER INSERT_MatchDateIsValid BEFORE INSERT ON `match`
FOR EACH ROW
BEGIN
    DECLARE err CONDITION FOR SQLSTATE '02000';
    IF NEW.MatchStart < (CURRENT_TIMESTAMP() - INTERVAL 24 HOUR) THEN
        SIGNAL err
            SET MESSAGE_TEXT = 'WARNING: A New Match Date Cannot Be Created If 
            It Was Played More Than 24 Hours In The Past.';
    END IF;
    IF TIME(NEW.MatchStart) NOT BETWEEN '09:00:00' AND '20:30:00' THEN
        SIGNAL err
        SET MESSAGE_TEXT = 'WARNING: Matches Can Only Be Played Between 9am and 8.30pm.';
    END IF;
END//
DELIMITER ;
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS UPDATE_MatchDateIsValid;
DELIMITER //
CREATE TRIGGER UPDATE_MatchDateIsValid BEFORE UPDATE ON `match`
FOR EACH ROW
BEGIN
    DECLARE err CONDITION FOR SQLSTATE '02000';
    IF NEW.MatchStart < (CURRENT_TIMESTAMP() - INTERVAL 24 HOUR) 
    AND NEW.MatchStart < (OLD.MatchStart- INTERVAL 24 HOUR) THEN
        SET New.MatchStart = Old.MatchStart;
        SIGNAL err
            SET MESSAGE_TEXT = 'Warning: Changed Date Cannot Be Inserted. 
            Date occurs before both the current date and the previous entries date. Reset to previous value.';
    END IF;
    IF TIME(NEW.MatchStart) NOT BETWEEN '09:00:00' AND '20:30:00' THEN
        SET New.MatchStart = Old.MatchStart;
        SIGNAL err
        SET MESSAGE_TEXT = 'Warning: Changed Start time is not between 9am and 8.30pm. Reset to previous value.';
    END IF;
END//
DELIMITER ;
-----------------------------------------------------------------------------
------------------------------Test DB Queries--------------------------------
-----------------------------------------------------------------------------

-- CALL GetGoalList('Colene Cork');
-- CALL GetGoalList('Leontine Warbrick');
-- CALL GetGoalList('Cecilla Dowsey');
-- CALL GetGoalList('Edy Kield');
-- CALL GetGoalList('Patrice Danelutti');
--
-- CALL GetInjury('Concussion', '2019-01-01', '2021-03-10');
-- CALL GetInjury('Knee injury', '2019-01-01', CURDATE());
-- CALL GetInjury('Spinal Injury', '2019-01-01', '2021-03-10');
--
-- CALL InsertPlayer('Yogi Legg', 'yogi@gmail.com', '02712558324', '2009-09-07', 5, NULL, NULL, @playerid1);
-- CALL InsertPlayer('Bella Legg', 'bella@gmail.com', '02112558324', '2016-09-07', 5, '2021-08-01', '2019-08-01', @playerid2);
-- CALL InsertPlayer('Bella Legg', 'bella@gmail.com', '02112558324', '2016-09-07', 5, '2012-08-01', NULL, @playerid2);
-- CALL InsertPlayer('Yogi Legg', 'yogi@gmail.com', '02712558324', '2001-09-07', 5, NULL, NULL, @playerid1);
-- CALL InsertPlayer('Bella Legg', 'bella@gmail.com', '02112558324', '2001-09-07', 5, '2021-08-01', NULL, @playerid2);
-- 
-- SELECT @playerid1 AS Player_ID_1;
-- SELECT @playerid2 AS Player_ID_2;
-- 
-- SELECT * FROM MembershipDuration;
-- SELECT * FROM MembershipDuration WHERE Average_Membership_Days > 1500;
-- SELECT * FROM MembershipDuration WHERE Team_Name IN ('Latlux Viva', 'Voyatouch Greenlam');
-- 
-- SELECT * FROM PlayerGoalCount;
-- SELECT * FROM PlayerGoalCount WHERE Match_Date < '2021-06-01';
-- SELECT * FROM PlayerGoalCount WHERE Match_Date < '2021-06-01' AND Goal_Count > 1;
-- SELECT * FROM CurrentPlayerList;
-- SELECT * FROM CurrentPlayerList ORDER BY Team_Name;
-- SELECT * FROM CurrentPlayerList WHERE Team_Name IN('Wrapsafe Otcom', 'Voyatouch Greenlam', 'Aerified Span');
--
