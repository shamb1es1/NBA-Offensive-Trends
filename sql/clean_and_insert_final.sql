DELIMITER //

# Function to verify primary key of player_id + team_id + season valid
DROP FUNCTION IF EXISTS valid_player_team_season//
CREATE FUNCTION valid_player_team_season(
	player_id VARCHAR(50),
    team_id   VARCHAR(50),
    season    VARCHAR(50)
)
RETURNS TINYINT(1)
DETERMINISTIC
BEGIN
	# Create variables to cast data types
    DECLARE pid INT UNSIGNED;
    DECLARE tid INT UNSIGNED;

	# Verify data types
	IF player_id IS NULL OR player_id = '' OR player_id NOT REGEXP '^[0-9]+$'
    THEN RETURN 0; END IF;
    IF team_id IS NULL OR team_id = '' OR team_id NOT REGEXP '^[0-9]+$'
    THEN RETURN 0; END IF;
    IF season IS NULL OR season = '' OR season NOT REGEXP '^[0-9]{4}-[0-9]{2}$'
    THEN RETURN 0; END IF;

    SET pid = CAST(player_id AS UNSIGNED);
    SET tid = CAST(team_id AS UNSIGNED);
    
    # Make sure player exists
    IF NOT EXISTS (SELECT * FROM staging_players WHERE staging_players.PERSON_ID = pid)
    THEN RETURN 0; END IF;
    
    # Make sure team exists
    IF NOT EXISTS (SELECT * FROM staging_teams WHERE staging_teams.id = tid)
    THEN RETURN 0; END IF;
    
    # Make sure season exists
    IF NOT EXISTS (SELECT * FROM seasons WHERE seasons.season = season)
    THEN RETURN 0; END IF;
    
    RETURN 1;
END//
DELIMITER ;

# staging_players ////////////////////////////////////////////////////////////////////

UPDATE staging_players
SET
    PERSON_ID = NULLIF(TRIM(PERSON_ID), ''),
    FIRST_NAME = NULLIF(TRIM(FIRST_NAME), ''),
    LAST_NAME = NULLIF(TRIM(LAST_NAME), ''),
    HEIGHT = NULLIF(TRIM(HEIGHT), ''),
    WEIGHT = NULLIF(TRIM(WEIGHT), ''),
    POSITION = NULLIF(TRIM(POSITION), '');

# Remove values with differences in primary position
# Just list what positions they play
UPDATE staging_players
SET POSITION = 'Guard/Forward'
WHERE POSITION IN('Forward-Guard','Guard-Forward');
UPDATE staging_players
SET POSITION = 'Forward/Center'
WHERE POSITION IN('Center-Forward','Forward-Center');

# Multiple rows with null id, height and weight
DELETE FROM staging_players
WHERE PERSON_ID IS NULL OR WEIGHT IS NULL OR HEIGHT IS NULL;

# Player Nene legally doesn't have a first name, but this is general solution
UPDATE staging_players
SET FIRST_NAME = LAST_NAME
WHERE FIRST_NAME = '' OR FIRST_NAME IS NULL;

INSERT INTO players (player_id, first_name, last_name, height, weight, position)
SELECT PERSON_ID, FIRST_NAME, LAST_NAME, HEIGHT, WEIGHT, POSITION
FROM staging_players;

# staging_teams //////////////////////////////////////////////////////////////////////

# Can see all teams present no need for nullif()
UPDATE staging_teams
SET
    id = TRIM(id),
    full_name = TRIM(full_name),
    abbreviation = TRIM(abbreviation),
    nickname = TRIM(nickname),
    city = TRIM(city);
    
INSERT INTO teams (team_id, team_name, team_abbrev, team_nickname, team_location)
SELECT id, full_name, abbreviation, nickname, city
FROM staging_teams;

# staging_shot_zones /////////////////////////////////////////////////////////////////

UPDATE staging_shot_zones
SET
    SEASON = NULLIF(TRIM(SEASON), ''),
    TEAM_ID = NULLIF(TRIM(TEAM_ID), ''),
    PLAYER_ID = NULLIF(TRIM(PLAYER_ID), ''),
    SHOT_ZONE_BASIC = NULLIF(TRIM(SHOT_ZONE_BASIC), ''),
    SHOT_ZONE_AREA = NULLIF(TRIM(SHOT_ZONE_AREA), ''),
    SHOT_ZONE_RANGE = NULLIF(TRIM(SHOT_ZONE_RANGE), '');

# Simpler value name
UPDATE staging_shot_zones
SET SHOT_ZONE_BASIC = 'Non-RA Paint'
WHERE SHOT_ZONE_BASIC = 'In The Paint (Non-RA)';

# Get rid of parenthesis
UPDATE staging_shot_zones
SET SHOT_ZONE_AREA = REGEXP_REPLACE(SHOT_ZONE_AREA, '\\([^)]*\\)', '');

# Change shot zone values
UPDATE staging_shot_zones
SET SHOT_ZONE_RANGE = REPLACE(SHOT_ZONE_RANGE, ' ft.', '');
UPDATE staging_shot_zones
SET SHOT_ZONE_RANGE = REPLACE(SHOT_ZONE_RANGE, 'Less Than ', '<');
UPDATE staging_shot_zones
SET SHOT_ZONE_RANGE = REPLACE(SHOT_ZONE_RANGE, '+', '<');
UPDATE staging_shot_zones
SET SHOT_ZONE_RANGE = REPLACE(SHOT_ZONE_RANGE, ' Shot', '');

# Get rid of players that don't exist in staging_players
DELETE FROM staging_shot_zones
WHERE PLAYER_ID NOT IN (SELECT DISTINCT PERSON_ID FROM staging_players);

INSERT INTO shot_zones (player_id, team_id, season, general_zone, zone_area,
	zone_range, fgm, fga
)
SELECT PLAYER_ID, TEAM_ID, SEASON, SHOT_ZONE_BASIC, SHOT_ZONE_AREA, SHOT_ZONE_RANGE,
    FGM, FGA
FROM staging_shot_zones;

# staging_team_advanced_stats ////////////////////////////////////////////////////////

UPDATE staging_team_advanced_stats
SET
    TEAM_ID = NULLIF(TRIM(TEAM_ID), ''),
    SEASON  = NULLIF(TRIM(SEASON), '');

# Found return carriages at the end of the season values
UPDATE staging_team_advanced_stats
SET SEASON = REPLACE(SEASON, '\r', '');
    
INSERT INTO team_advanced_stats (team_id, season, wins, losses, off_rating,
def_rating, assist_to_ratio, efg_pct, true_shooting_pct, pace, pace_per_40,
possessions
)
SELECT TEAM_ID, SEASON, W, L, OFF_RATING, DEF_RATING, AST_TO, EFG_PCT, TS_PCT, PACE,
PACE_PER40, POSS
FROM staging_team_advanced_stats;

# staging_speed_distance /////////////////////////////////////////////////////////////

# If statements replace valid rows with no reported data with default 0 values
UPDATE staging_speed_distance
SET
    PLAYER_ID = NULLIF(TRIM(PLAYER_ID), ''),
    TEAM_ID   = NULLIF(TRIM(TEAM_ID), ''),
    MIN = IF(TRIM(MIN) = '' OR MIN IS NULL, 0.0, MIN),
    DIST_MILES = IF(TRIM(DIST_MILES) = '' OR DIST_MILES IS NULL, 0.0, DIST_MILES),
    DIST_MILES_OFF = IF(TRIM(DIST_MILES_OFF) = '' OR DIST_MILES_OFF IS NULL, 0.0, DIST_MILES_OFF),
    AVG_SPEED = IF(TRIM(AVG_SPEED) = '' OR AVG_SPEED IS NULL, 0.0, AVG_SPEED),
    AVG_SPEED_OFF = IF(TRIM(AVG_SPEED_OFF) = '' OR AVG_SPEED_OFF IS NULL, 0.0, AVG_SPEED_OFF),
    AVG_SPEED_DEF = IF(TRIM(AVG_SPEED_DEF) = '' OR AVG_SPEED_DEF IS NULL, 0.0, AVG_SPEED_DEF);
    
# Get rid of players that don't exist in staging_players
DELETE FROM staging_speed_distance
WHERE PLAYER_ID NOT IN (SELECT DISTINCT PERSON_ID FROM staging_players);

INSERT INTO speed_distance (
    player_id, team_id, season, minutes_played, miles_traveled,
    offensive_miles_traveled, average_speed, offensive_average_speed,
    defensive_average_speed
)
SELECT
    PLAYER_ID, TEAM_ID, SEASON, MIN, DIST_MILES, DIST_MILES_OFF, AVG_SPEED,
    AVG_SPEED_OFF, AVG_SPEED_DEF
FROM staging_speed_distance;

# staging_pull_ups ///////////////////////////////////////////////////////////////////

UPDATE staging_pull_ups
SET
    PLAYER_ID = NULLIF(TRIM(PLAYER_ID), ''),
    TEAM_ID = NULLIF(TRIM(TEAM_ID), ''),
    PULL_UP_FGM = IF(PULL_UP_FGM IS NULL OR TRIM(PULL_UP_FGM) = '', 0.0, PULL_UP_FGM),
    PULL_UP_FGA = IF(PULL_UP_FGA IS NULL OR TRIM(PULL_UP_FGA) = '', 0.0, PULL_UP_FGA),
    PULL_UP_PTS = IF(PULL_UP_PTS IS NULL OR TRIM(PULL_UP_PTS) = '', 0.0, PULL_UP_PTS),
    PULL_UP_FG3M = IF(PULL_UP_FG3M IS NULL OR TRIM(PULL_UP_FG3M) = '', 0.0, PULL_UP_FG3M),
    PULL_UP_FG3A = IF(PULL_UP_FG3A IS NULL OR TRIM(PULL_UP_FG3A) = '', 0.0, PULL_UP_FG3A),
    PULL_UP_EFG_PCT = IF(PULL_UP_EFG_PCT IS NULL OR TRIM(PULL_UP_EFG_PCT) = '', 0.000, PULL_UP_EFG_PCT);

DELETE FROM staging_pull_ups
WHERE PLAYER_ID NOT IN (SELECT DISTINCT PERSON_ID FROM staging_players);

INSERT INTO pull_ups (
    player_id, team_id, season, fgm, fga, ppg, fgm_3, fga_3, efg_pct
)
SELECT
    PLAYER_ID, TEAM_ID, SEASON, PULL_UP_FGM, PULL_UP_FGA, PULL_UP_PTS, PULL_UP_FG3M,
    PULL_UP_FG3A, PULL_UP_EFG_PCT
FROM staging_pull_ups;

# staging_drives /////////////////////////////////////////////////////////////////////

UPDATE staging_drives
SET
    PLAYER_ID = NULLIF(TRIM(PLAYER_ID), ''),
    TEAM_ID   = NULLIF(TRIM(TEAM_ID), '');
    
DELETE FROM staging_drives
WHERE PLAYER_ID NOT IN (SELECT DISTINCT PERSON_ID FROM staging_players);

INSERT INTO drives (
    player_id, team_id, season, attempts, fgm, fga, ftm, fta, ppg, points_per_drive,
    passes, pass_pct, assists, assist_pct, turnovers, turnover_pct
)
SELECT
    PLAYER_ID, TEAM_ID, SEASON, DRIVES, DRIVE_FGM, DRIVE_FGA, DRIVE_FTM, DRIVE_FTA, 
    DRIVE_PTS, DRIVE_PTS_PCT, DRIVE_PASSES, DRIVE_PASSES_PCT, DRIVE_AST, DRIVE_AST_PCT,
    DRIVE_TOV, DRIVE_TOV_PCT
FROM staging_drives;

# staging_catch_and_shoots ///////////////////////////////////////////////////////////

UPDATE staging_drives
SET
    PLAYER_ID = NULLIF(TRIM(PLAYER_ID), ''),
    TEAM_ID   = NULLIF(TRIM(TEAM_ID), '');

DELETE FROM staging_catch_and_shoots
WHERE PLAYER_ID NOT IN (SELECT DISTINCT PERSON_ID FROM staging_players);

UPDATE staging_catch_and_shoots
SET
	CATCH_SHOOT_FG3M = IF(CATCH_SHOOT_FG3M IS NULL OR TRIM(CATCH_SHOOT_FG3M) = '', 0.0, CATCH_SHOOT_FG3M),
	CATCH_SHOOT_FG3A = IF(CATCH_SHOOT_FG3A IS NULL OR TRIM(CATCH_SHOOT_FG3A) = '', 0.0, CATCH_SHOOT_FG3A),
	CATCH_SHOOT_EFG_PCT = IF(CATCH_SHOOT_EFG_PCT IS NULL OR TRIM(CATCH_SHOOT_EFG_PCT) = '', 0.000, CATCH_SHOOT_EFG_PCT);

INSERT INTO catch_and_shoots (
    player_id, team_id, season, fgm, fga, ppg, fgm_3, fga_3, efg_pct
)
SELECT
    PLAYER_ID, TEAM_ID, SEASON, CATCH_SHOOT_FGM, CATCH_SHOOT_FGA, CATCH_SHOOT_PTS,
    CATCH_SHOOT_FG3M, CATCH_SHOOT_FG3A, CATCH_SHOOT_EFG_PCT
FROM staging_catch_and_shoots;

# staging_post_touches ///////////////////////////////////////////////////////////////

UPDATE staging_post_touches
SET
    PLAYER_ID = NULLIF(TRIM(PLAYER_ID), ''),
    TEAM_ID   = NULLIF(TRIM(TEAM_ID), '');
    
DELETE FROM staging_post_touches
WHERE PLAYER_ID NOT IN (SELECT DISTINCT PERSON_ID FROM staging_players);

INSERT INTO post_touches (
    player_id, team_id, season, touches, fgm, fga, ftm, fta, ppg, passes, pass_pct,
    assists, assist_pct, turnovers, turnover_pct
)
SELECT
    PLAYER_ID, TEAM_ID, SEASON, POST_TOUCHES, POST_TOUCH_FGM, POST_TOUCH_FGA,
    POST_TOUCH_FTM, POST_TOUCH_FTA, POST_TOUCH_PTS, POST_TOUCH_PASSES,
    POST_TOUCH_PASSES_PCT, POST_TOUCH_AST, POST_TOUCH_AST_PCT, POST_TOUCH_TOV,
    POST_TOUCH_TOV_PCT
FROM staging_post_touches;

# staging_elbow_touches //////////////////////////////////////////////////////////////

UPDATE staging_elbow_touches
SET
    PLAYER_ID = NULLIF(TRIM(PLAYER_ID), ''),
    TEAM_ID   = NULLIF(TRIM(TEAM_ID), '');
    
DELETE FROM staging_elbow_touches
WHERE PLAYER_ID NOT IN (SELECT DISTINCT PERSON_ID FROM staging_players);

INSERT INTO elbow_touches (
    player_id, team_id, season, touches, fgm, fga, ftm, fta, ppg, passes, pass_pct,
    assists, assist_pct, turnovers, turnover_pct
)
SELECT
    PLAYER_ID, TEAM_ID, SEASON, ELBOW_TOUCHES, ELBOW_TOUCH_FGM, ELBOW_TOUCH_FGA,
    ELBOW_TOUCH_FTM, ELBOW_TOUCH_FTA, ELBOW_TOUCH_PTS, ELBOW_TOUCH_PASSES,
    ELBOW_TOUCH_PASSES_PCT, ELBOW_TOUCH_AST, ELBOW_TOUCH_AST_PCT, ELBOW_TOUCH_TOV,
    ELBOW_TOUCH_TOV_PCT
FROM staging_elbow_touches;

# staging_passes /////////////////////////////////////////////////////////////////////

UPDATE staging_passes
SET
    PLAYER_ID = NULLIF(TRIM(PLAYER_ID), ''),
    TEAM_ID   = NULLIF(TRIM(TEAM_ID), '');

DELETE FROM staging_passes
WHERE PLAYER_ID NOT IN (SELECT DISTINCT PERSON_ID FROM staging_players);

INSERT INTO passes (
    player_id, team_id, season,
    made, received,
    assists, secondary_assists, potential_assists,
    assist_points_created, assists_to_pass_pct
)
SELECT
    PLAYER_ID, TEAM_ID, SEASON,
    PASSES_MADE, PASSES_RECEIVED,
    AST, SECONDARY_AST, POTENTIAL_AST,
    AST_POINTS_CREATED, AST_TO_PASS_PCT
FROM staging_passes;

# staging_possessions ////////////////////////////////////////////////////////////////

UPDATE staging_possessions
SET
    PLAYER_ID = NULLIF(TRIM(PLAYER_ID), ''),
    TEAM_ID   = NULLIF(TRIM(TEAM_ID), '');

DELETE FROM staging_possessions
WHERE PLAYER_ID NOT IN (SELECT DISTINCT PERSON_ID FROM staging_players);

INSERT INTO possessions (
    player_id, team_id, season, touches, front_court_touches, time_of_possessions,
    sec_per_touch, dribble_per_touch, pts_per_touch
)
SELECT
    PLAYER_ID, TEAM_ID, SEASON, TOUCHES, FRONT_CT_TOUCHES, TIME_OF_POSS,
    AVG_SEC_PER_TOUCH, AVG_DRIB_PER_TOUCH, PTS_PER_TOUCH
FROM staging_possessions;

# staging_paint_touches //////////////////////////////////////////////////////////////

UPDATE staging_paint_touches
SET
    PLAYER_ID = NULLIF(TRIM(PLAYER_ID), ''),
    TEAM_ID   = NULLIF(TRIM(TEAM_ID), '');

DELETE FROM staging_paint_touches
WHERE PLAYER_ID NOT IN (SELECT DISTINCT PERSON_ID FROM staging_players);

INSERT INTO paint_touches (
    player_id, team_id, season, touches, fgm, fga, ftm, fta, ppg, passes, pass_pct,
    assists, assist_pct, turnovers, turnover_pct
)
SELECT
    PLAYER_ID, TEAM_ID, SEASON, PAINT_TOUCHES, PAINT_TOUCH_FGM, PAINT_TOUCH_FGA,
    PAINT_TOUCH_FTM, PAINT_TOUCH_FTA, PAINT_TOUCH_PTS, PAINT_TOUCH_PASSES,
    PAINT_TOUCH_PASSES_PCT, PAINT_TOUCH_AST, PAINT_TOUCH_AST_PCT, PAINT_TOUCH_TOV,
    PAINT_TOUCH_TOV_PCT
FROM staging_paint_touches;

# staging_efficiency /////////////////////////////////////////////////////////////////

UPDATE staging_efficiency
SET
    PLAYER_ID = NULLIF(TRIM(PLAYER_ID), ''),
    TEAM_ID   = NULLIF(TRIM(TEAM_ID), '');

DELETE FROM staging_efficiency
WHERE PLAYER_ID NOT IN (SELECT DISTINCT PERSON_ID FROM staging_players);

INSERT INTO efficiency (
    player_id, team_id, season, ppg, efg
)
SELECT
    PLAYER_ID, TEAM_ID, SEASON, POINTS, EFF_FG_PCT
FROM staging_efficiency;









