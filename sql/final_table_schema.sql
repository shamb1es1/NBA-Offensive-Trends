SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS speed_distance;
DROP TABLE IF EXISTS team_advanced_stats;
DROP TABLE IF EXISTS shot_zones;
DROP TABLE IF EXISTS players;
DROP TABLE IF EXISTS teams;
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
    pace DECIMAL(5, 2) NOT NULL,
    pace_per_40 DECIMAL(4, 2) NOT NULL,
    possessions INT,
    PRIMARY KEY (team_id, season),
    FOREIGN KEY (team_id) REFERENCES teams(team_id),
    FOREIGN KEY (season) REFERENCES seasons(season)
);

CREATE TABLE speed_distance (
	player_id INT,
    team_id INT,
    season VARCHAR(9),
    minutes_played DECIMAL(3, 1) CHECK(minutes_played > 0),
    miles_traveled DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    offensive_miles_traveled DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    average_speed DECIMAL(4, 2) NOT NULL DEFAULT 0.00,
    offensive_average_speed DECIMAL(4, 2) NOT NULL DEFAULT 0.00,
    defensive_average_speed DECIMAL(4, 2) NOT NULL DEFAULT 0.00,
	PRIMARY KEY (player_id, team_id, season),
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    FOREIGN KEY (team_id) REFERENCES teams(team_id),
    FOREIGN KEY (season) REFERENCES seasons(season)
);

CREATE TABLE pull_ups (
	player_id INT,
    team_id INT,
    season VARCHAR(9),
    fgm DECIMAL(3, 1) NOT NULL DEFAULT 0.0, 
    fga DECIMAL(3, 1) NOT NULL DEFAULT 0.0,
    ppg DECIMAL(3, 1) NOT NULL DEFAULT 0.0,
    fgm_3 DECIMAL(3, 1) NOT NULL DEFAULT 0.0,
    fga_3 DECIMAL(3, 1) NOT NULL DEFAULT 0.0,
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
    attempts DECIMAL(3, 1) NOT NULL DEFAULT 0.0,
    fgm DECIMAL(3, 1) NOT NULL DEFAULT 0.0, 
    fga DECIMAL(3, 1) NOT NULL DEFAULT 0.0,
    ppg DECIMAL(3, 1) NOT NULL DEFAULT 0.0,
    points_per_drive DECIMAL(4, 3) NOT NULL DEFAULT 0.000,
    ftm DECIMAL(3, 1) NOT NULL DEFAULT 0.0,
    fta DECIMAL(3, 1) NOT NULL DEFAULT 0.0, 
    passes DECIMAL(3, 1) NOT NULL DEFAULT 0.0,
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
    fgm DECIMAL(3, 1) NOT NULL DEFAULT 0.0, 
    fga DECIMAL(3, 1) NOT NULL DEFAULT 0.0,
    ppg DECIMAL(3, 1) NOT NULL DEFAULT 0.0,
    fgm_3 DECIMAL(3, 1) NOT NULL DEFAULT 0.0,
    fga_3 DECIMAL(3, 1) NOT NULL DEFAULT 0.0,
    efg_pct DECIMAL(4, 3) NOT NULL DEFAULT 0.000,
    PRIMARY KEY (player_id, team_id, season),
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    FOREIGN KEY (team_id) REFERENCES teams(team_id),
    FOREIGN KEY (season) REFERENCES seasons(season)
);

CREATE TABLE post_touches (
	player_id INT,
    team_id INT,
    season VARCHAR(9),
    touches DECIMAL(3, 1) NOT NULL DEFAULT 0.0,
    fgm DECIMAL(3, 1) NOT NULL DEFAULT 0.0, 
    fga DECIMAL(3, 1) NOT NULL DEFAULT 0.0,
    ftm DECIMAL(3, 1) NOT NULL DEFAULT 0.0,
    fta DECIMAL(3, 1) NOT NULL DEFAULT 0.0, 
    ppg DECIMAL(3, 1) NOT NULL DEFAULT 0.0,
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
    touches DECIMAL(3, 1) NOT NULL DEFAULT 0.0,
    fgm DECIMAL(3, 1) NOT NULL DEFAULT 0.0, 
    fga DECIMAL(3, 1) NOT NULL DEFAULT 0.0,
    ftm DECIMAL(3, 1) NOT NULL DEFAULT 0.0,
    fta DECIMAL(3, 1) NOT NULL DEFAULT 0.0, 
    ppg DECIMAL(3, 1) NOT NULL DEFAULT 0.0,
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
    assists DECIMAL(3, 1) NOT NULL DEFAULT 0.0,
    secondary_assists DECIMAL(3, 1) NOT NULL DEFAULT 0.0,
    potential_assists DECIMAL(3, 1) NOT NULL DEFAULT 0.0,
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
    touches DECIMAL(4, 1) NOT NULL DEFAULT 00.0,
    front_court_touches DECIMAL(3, 1) NOT NULL DEFAULT 00.0,
    time_of_possessions DECIMAL(2, 1) NOT NULL DEFAULT 0.0,
    sec_per_touch DECIMAL(4, 2) NOT NULL DEFAULT 0.00,
    dribble_per_touch DECIMAL(4, 2) NOT NULL DEFAULT 0.00,
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
    fgm DECIMAL(3, 1) NOT NULL DEFAULT 0.0, 
    fga DECIMAL(3, 1) NOT NULL DEFAULT 0.0,
    ftm DECIMAL(3, 1) NOT NULL DEFAULT 0.0,
    fta DECIMAL(3, 1) NOT NULL DEFAULT 0.0, 
    ppg DECIMAL(3, 1) NOT NULL DEFAULT 0.0,
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

CREATE INDEX idx_players_last_first
    ON players(last_name, first_name);

CREATE INDEX idx_team_advanced_stats_season
    ON team_advanced_stats(season);

CREATE INDEX idx_shot_zones_team_season
    ON shot_zones(team_id, season);

CREATE INDEX idx_shot_zones_season
    ON shot_zones(season);

CREATE INDEX idx_speed_distance_team_season
    ON speed_distance(team_id, season);

CREATE INDEX idx_speed_distance_season
    ON speed_distance(season);

CREATE INDEX idx_pull_ups_team_season
    ON pull_ups(team_id, season);

CREATE INDEX idx_pull_ups_season
    ON pull_ups(season);

CREATE INDEX idx_drives_team_season
    ON drives(team_id, season);

CREATE INDEX idx_drives_season
    ON drives(season);

CREATE INDEX idx_catch_and_shoots_team_season
    ON catch_and_shoots(team_id, season);

CREATE INDEX idx_catch_and_shoots_season
    ON catch_and_shoots(season);

CREATE INDEX idx_post_touches_team_season
    ON post_touches(team_id, season);

CREATE INDEX idx_post_touches_season
    ON post_touches(season);

CREATE INDEX idx_elbow_touches_team_season
    ON elbow_touches(team_id, season);

CREATE INDEX idx_elbow_touches_season
    ON elbow_touches(season);

CREATE INDEX idx_passes_team_season
    ON passes(team_id, season);

CREATE INDEX idx_passes_season
    ON passes(season);

CREATE INDEX idx_possessions_team_season
    ON possessions(team_id, season);

CREATE INDEX idx_possessions_season
    ON possessions(season);

CREATE INDEX idx_paint_touches_team_season
    ON paint_touches(team_id, season);

CREATE INDEX idx_paint_touches_season
    ON paint_touches(season);

CREATE INDEX idx_efficiency_team_season
    ON efficiency(team_id, season);

CREATE INDEX idx_efficiency_season
    ON efficiency(season);
