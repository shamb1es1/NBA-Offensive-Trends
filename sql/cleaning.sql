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

SELECT * FROM staging_players;

UPDATE staging_players
SET
    PLAYER_ID = TRIM(PLAYER_ID),
    FIRST_NAME = TRIM(FIRST_NAME),
    LAST_NAME = TRIM(LAST_NAME),
    HEIGHT = TRIM(HEIGHT),
    WEIGHT = TRIM(WEIGHT),
    POSITION = TRIM(POSITION);

UPDATE staging_players
SET
    PLAYER_ID = NULLIF(PLAYER_ID, ''),
    FIRST_NAME = NULLIF(FIRST_NAME, ''),
    LAST_NAME = NULLIF(LAST_NAME, ''),
    HEIGHT = NULLIF(HEIGHT, ''),
    WEIGHT = NULLIF(WEIGHT, ''),
    POSITION = NULLIF(POSITION, '');


SELECT DISTINCT POSITION
FROM staging_players;








