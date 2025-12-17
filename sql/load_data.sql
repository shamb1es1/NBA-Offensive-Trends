SET GLOBAL local_infile = 1;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/player_bio_common.csv'
INTO TABLE players
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    player_id, @first_namem last_name           
);

DROP TABLE IF EXISTS passes_temp;
CREATE TABLE passes_temp (
    player_id INT,
    team_id INT,
    season VARCHAR(9),
    made                  DECIMAL(6,1),
    received              DECIMAL(6,1),
    assists               DECIMAL(4,1),
    secondary_assists     DECIMAL(4,1),
    potential_assists     DECIMAL(4,1),
    assist_points_created DECIMAL(6,1),
    assists_to_pass_pct   DECIMAL(6,3)
);

select * from players;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/tracking_passing.csv'
INTO TABLE passes
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    player_id, @player_name, team_id, @team_abbrev, @gp, @w, @l, @min, made, received, assists, @ft_ast,         
    secondary_assists, potential_assists, assist_points_created, @ast_adj, assists_to_pass_pct,   
    @ast_to_pass_pct_adj, season, @pt_measure_type, @team_name              
);

insert into seasons 
select distinct season 
from passes_temp;

LOAD DATA LOCAL INFILE "C:\Users\juwri\Downloads\NBA Project\team_information.csv"
INTO TABLE teams
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
  @id,
  @full_name,
  @abbreviation,
  @nickname,
  @city,
  @state,
  @year_founded
)
SET
  team_id       = @id,
  team_name     = @full_name,
  team_abbrev   = @abbreviation,
  team_nickname = @nickname,
  team_location = @city;