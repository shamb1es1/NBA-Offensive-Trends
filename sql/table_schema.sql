SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS speed_distance;
DROP TABLE IF EXISTS team_advanced_stats;
DROP TABLE IF EXISTS shot_zones;
DROP TABLE IF EXISTS players;
DROP TABLE IF EXISTS teams;
DROP TABLE IF EXISTS seasons;
DROP TABLE IF EXISTS pull_ups;
DROP TABLE IF EXISTS drives;
DROP TABLE IF EXISTS catch_and_shoots;
DROP TABLE IF EXISTS post_touches;
DROP TABLE IF EXISTS elbow_touches;
DROP TABLE IF EXISTS passes;
DROP TABLE IF EXISTS possessions;
DROP TABLE IF EXISTS paint_touches;
DROP TABLE IF EXISTS efficiency;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE players (
	player_id INT,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    height VARCHAR(5) NOT NULL CHECK (height REGEXP '^[5-7]-[0-9]{1,2}$'),
    weight INT(3) NOT NULL CHECK (weight <= 400 AND weight >= 100),
    position VARCHAR(25) NOT NULL,
    PRIMARY KEY (player_id)
);

CREATE TABLE teams (
	team_id INT,
    team_name VARCHAR(50) UNIQUE NOT NULL,
    team_abbrev VARCHAR(3) UNIQUE NOT NULL,
    team_nickname VARCHAR(50) UNIQUE NOT NULL,
    team_location VARCHAR(50) NOT NULL,
    PRIMARY KEY (team_id),
    CHECK (LENGTH(team_name) > LENGTH(team_nickname)),
    CHECK (LENGTH(team_name) > LENGTH(team_location))
);

CREATE TABLE seasons (
    season VARCHAR(9) CHECK (season REGEXP '^[0-9]{4}-[0-9]{2}$') PRIMARY KEY
);

CREATE TABLE shot_zones (
	player_id INT,
    team_id INT,
    season VARCHAR(9),
    general_zone VARCHAR(25) NOT NULL,
    zone_area VARCHAR(25) NOT NULL,
    zone_range VARCHAR(25) NOT NULL,
    fgm INT,
    fga INT,
    PRIMARY KEY (player_id, team_id, season, general_zone, zone_area, zone_range),
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    FOREIGN KEY (team_id) REFERENCES teams(team_id),
    FOREIGN KEY (season) REFERENCES seasons(season)
);

CREATE TABLE team_advanced_stats (
	team_id INT,
    season VARCHAR(9),
    wins INT CHECK (wins >= 0 AND wins <= 82) NOT NULL,
    losses INT CHECK (losses >= 0 AND losses <= 82) NOT NULL,
    off_rating DECIMAL(4, 1) NOT NULL,
    def_rating DECIMAL(4, 1) NOT NULL,
    assist_to_ratio DECIMAL(3, 2) NOT NULL,
    efg_pct DECIMAL(4, 3) NOT NULL,
    true_shooting_pct DECIMAL(4, 3) NOT NULL,
    pace DECIMAL(4, 2) NOT NULL,
    PRIMARY KEY (team_id, season),
    FOREIGN KEY (team_id) REFERENCES teams(team_id),
    FOREIGN KEY (season) REFERENCES seasons(season)
);

CREATE TABLE speed_distance (
	player_id INT,
    team_id INT,
    season VARCHAR(9),
    minutes_played DECIMAL(3, 2) CHECK(minutes_played > 0),
    miles_traveled DECIMAL(2, 1) NOT NULL,
    offensive_miles_traveled DECIMAL(2, 1) NOT NULL,
    average_speed DECIMAL(4, 2) NOT NULL,
    offensive_average_speed DECIMAL(4, 2) NOT NULL,
    defensive_average_speed DECIMAL(4, 2) NOT NULL,
	PRIMARY KEY (player_id, team_id, season),
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    FOREIGN KEY (team_id) REFERENCES teams(team_id),
    FOREIGN KEY (season) REFERENCES seasons(season)
);

CREATE TABLE pull_ups (
	player_id INT,
    team_id INT,
    season VARCHAR(9),
    fgm DECIMAL(2, 1) NOT NULL DEFAULT 0.0, 
    fga DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    ppg DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    fgm_3 DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    fga_3 DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    efg_pct DECIMAL(4, 3) NOT NULL DEFAULT 0.000,
    PRIMARY KEY (player_id, team_id, season),
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    FOREIGN KEY (team_id) REFERENCES teams(team_id),
    FOREIGN KEY (season) REFERENCES seasons(season)
);

CREATE TABLE drives (
	player_id INT,
    team_id INT,
    season VARCHAR(9),
    attempts DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    fgm DECIMAL(2, 1) NOT NULL DEFAULT 0.0, 
    fga DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    ppg DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    fgm_3 DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    fga_3 DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    efg_pct DECIMAL(4, 3) NOT NULL DEFAULT 0.000,
    ftm DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    fta DECIMAL(2, 1) NOT NULL DEFAULT 0.0, 
    points_per_poss DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    passes DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    pass_pct DECIMAL(4, 3) NOT NULL DEFAULT 0.000,
    assists DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    assist_pct DECIMAL(4, 3) NOT NULL DEFAULT 0.000,
    turnovers DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    turnover_pct DECIMAL(4, 3) NOT NULL DEFAULT 0.000,
    PRIMARY KEY (player_id, team_id, season),
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    FOREIGN KEY (team_id) REFERENCES teams(team_id),
    FOREIGN KEY (season) REFERENCES seasons(season)
);

CREATE TABLE catch_and_shoots (
	player_id INT,
    team_id INT,
    season VARCHAR(9),
    fgm DECIMAL(2, 1) NOT NULL DEFAULT 0.0, 
    fga DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    ppg DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    fgm_3 DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    fga_3 DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    efg_pct DECIMAL(4, 3) NOT NULL DEFAULT 0.000,
    PRIMARY KEY (player_id, team_id, season),
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    FOREIGN KEY (team_id) REFERENCES teams(team_id),
    FOREIGN KEY (season) REFERENCES seasons(season)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/tracking_catchshoot.csv'
INTO TABLE catch_and_shoots
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

CREATE TABLE post_touches (
	player_id INT,
    team_id INT,
    season VARCHAR(9),
    touches DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    fgm DECIMAL(2, 1) NOT NULL DEFAULT 0.0, 
    fga DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    ftm DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    fta DECIMAL(2, 1) NOT NULL DEFAULT 0.0, 
    ppg DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    passes DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    pass_pct DECIMAL(4, 3) NOT NULL DEFAULT 0.000,
    assists DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    assist_pct DECIMAL(4, 3) NOT NULL DEFAULT 0.000,
    turnovers DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    turnover_pct DECIMAL(4, 3) NOT NULL DEFAULT 0.000,
    PRIMARY KEY (player_id, team_id, season),
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    FOREIGN KEY (team_id) REFERENCES teams(team_id),
    FOREIGN KEY (season) REFERENCES seasons(season)
);

CREATE TABLE elbow_touches (
	player_id INT,
    team_id INT,
    season VARCHAR(9),
    touches DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    fgm DECIMAL(2, 1) NOT NULL DEFAULT 0.0, 
    fga DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    ftm DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    fta DECIMAL(2, 1) NOT NULL DEFAULT 0.0, 
    ppg DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    passes DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    pass_pct DECIMAL(4, 3) NOT NULL DEFAULT 0.000,
    assists DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    assist_pct DECIMAL(4, 3) NOT NULL DEFAULT 0.000,
    turnovers DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    turnover_pct DECIMAL(4, 3) NOT NULL DEFAULT 0.000,
    PRIMARY KEY (player_id, team_id, season),
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    FOREIGN KEY (team_id) REFERENCES teams(team_id),
    FOREIGN KEY (season) REFERENCES seasons(season)
);

CREATE TABLE passes (
	player_id INT,
    team_id INT,
    season VARCHAR(9),
	made DECIMAL(3, 1) NOT NULL DEFAULT 00.0,
    received DECIMAL(3, 1) NOT NULL DEFAULT 00.0,
    assists DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    secondary_assists DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    potential_assists DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    assist_points_created DECIMAL(3, 1) NOT NULL DEFAULT 00.0,
    assists_to_pass_pct DECIMAL(4, 3) NOT NULL DEFAULT 0.000,
	PRIMARY KEY (player_id, team_id, season),
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    FOREIGN KEY (team_id) REFERENCES teams(team_id),
    FOREIGN KEY (season) REFERENCES seasons(season)
);

CREATE TABLE possessions (
	player_id INT,
    team_id INT,
    season VARCHAR(9),
    touches DECIMAL(3, 1) NOT NULL DEFAULT 00.0,
    front_court_touches DECIMAL(3, 1) NOT NULL DEFAULT 00.0,
    time_of_possessions DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    sec_per_touch DECIMAL(3, 2) NOT NULL DEFAULT 0.00,
    dribble_per_touch DECIMAL(3, 2) NOT NULL DEFAULT 0.00,
    pts_per_touch DECIMAL(4, 3) NOT NULL DEFAULT 0.000,
    PRIMARY KEY (player_id, team_id, season),
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    FOREIGN KEY (team_id) REFERENCES teams(team_id),
    FOREIGN KEY (season) REFERENCES seasons(season)
);

CREATE TABLE paint_touches (
	player_id INT,
    team_id INT,
    season VARCHAR(9),
    touches DECIMAL(3, 1) NOT NULL DEFAULT 00.0,
    fgm DECIMAL(2, 1) NOT NULL DEFAULT 0.0, 
    fga DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    ftm DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    fta DECIMAL(2, 1) NOT NULL DEFAULT 0.0, 
    ppg DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    passes DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    pass_pct DECIMAL(4, 3) NOT NULL DEFAULT 0.000,
    assists DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    assist_pct DECIMAL(4, 3) NOT NULL DEFAULT 0.000,
    turnovers DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    turnover_pct DECIMAL(4, 3) NOT NULL DEFAULT 0.000,
    PRIMARY KEY (player_id, team_id, season),
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    FOREIGN KEY (team_id) REFERENCES teams(team_id),
    FOREIGN KEY (season) REFERENCES seasons(season)
);

CREATE TABLE efficiency (
	player_id INT,
    team_id INT,
    season VARCHAR(9),
    ppg DECIMAL(3, 1) NOT NULL DEFAULT 00.0,
    efg DECIMAL(4, 3) NOT NULL DEFAULT 0.000,
    PRIMARY KEY (player_id, team_id, season),
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    FOREIGN KEY (team_id) REFERENCES teams(team_id),
    FOREIGN KEY (season) REFERENCES seasons(season)
);