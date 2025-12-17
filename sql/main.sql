# Goal:
# To analyze the evolution of NBA offensive behavior, looking at tracking data to
# find trends in areas such as shot distribution, ball movement, pace, and other 
# team and player related data

# Efficiency by shot zone for all players

SELECT season,
    ROUND(AVG(CASE WHEN general_zone = 'Above the Break 3' AND fga > 0
    THEN (fgm/fga)*100 END),1) AS above_break_3,
    ROUND(AVG(CASE WHEN general_zone = 'Left Corner 3' AND fga > 0
    THEN (fgm/fga)*100 END),1) AS left_corner_3,
    ROUND(AVG(CASE WHEN general_zone = 'Right Corner 3' AND fga > 0
    THEN (fgm/fga)*100 END),1) AS right_corner_3,
    ROUND(AVG(CASE WHEN general_zone = 'Mid-Range' AND fga > 0
    THEN (fgm/fga)*100 END),1) AS midrange,
    ROUND(AVG(CASE WHEN general_zone = 'Restricted Area' AND fga > 0
    THEN (fgm/fga)*100 END),1) AS restricted,
    ROUND(AVG(CASE WHEN general_zone = 'Non-RA Paint' AND fga > 0
    THEN (fgm/fga)*100 END),1) AS non_ra_paint
FROM shot_zones
GROUP BY season
ORDER BY season;

# Basic look at pace over the years

SELECT season, ROUND(AVG(pace),2) AS pace, ROUND(AVG(pace_per_40),2) AS pace_per_40,
ROUND(AVG(off_rating), 2) AS off_rating, ROUND(AVG(true_shooting_pct),2) AS 'TS%'
FROM team_advanced_stats
GROUP BY season;

# Average amount of shots by distance per team per season

SELECT
    tt.season,
    ROUND(AVG(CASE WHEN tt.zone_range = '<8' THEN tt.team_fga / tt.games_played END), 1) AS '<8',
    ROUND(AVG(CASE WHEN tt.zone_range = '8-16' THEN tt.team_fga / tt.games_played END), 1) AS '8-16',
    ROUND(AVG(CASE WHEN tt.zone_range = '16-24' THEN tt.team_fga / tt.games_played END), 1) AS '16-24',
    ROUND(AVG(CASE WHEN tt.zone_range = '24<' THEN tt.team_fga / tt.games_played END), 1) AS '24<'
FROM (
    SELECT sz.team_id, sz.season, sz.zone_range, SUM(sz.fga) AS team_fga,
	MAX(ta.wins + ta.losses) AS games_played
    FROM shot_zones sz
    JOIN team_advanced_stats ta USING (team_id, season)
    GROUP BY sz.team_id, sz.season, sz.zone_range
) AS tt
GROUP BY tt.season
ORDER BY tt.season;

# Average shots per game by distance band for players who average 30+ minutes

SELECT sz.season,
	ROUND(AVG(CASE WHEN sz.zone_range = '<8' THEN sz.fga / (ta.wins + ta.losses) END), 2) AS fga_pg_lt8,
    ROUND(AVG(CASE WHEN sz.zone_range = '8-16' THEN sz.fga / (ta.wins + ta.losses) END), 2) AS fga_pg_8_16,
    ROUND(AVG(CASE WHEN sz.zone_range = '16-24' THEN sz.fga / (ta.wins + ta.losses) END), 2) AS fga_pg_16_24,
    ROUND(AVG(CASE WHEN sz.zone_range = '24<' THEN sz.fga / (ta.wins + ta.losses) END), 2) AS fga_pg_24_plus
FROM shot_zones sz
JOIN speed_distance sd USING (player_id, team_id, season)
JOIN team_advanced_stats ta USING (team_id, season)
WHERE sd.minutes_played >= 30
  AND (ta.wins + ta.losses) > 0
GROUP BY sz.season
ORDER BY sz.season;

# Get the shot length distribution % of pure centers (with 10+ min/game) over time

SELECT
    season,
    ROUND(100*SUM(CASE WHEN zone_range = '<8' THEN fga ELSE 0 END)/SUM(fga),1) AS '<8',
    ROUND(100*SUM(CASE WHEN zone_range = '8-16' THEN fga END)/SUM(fga),1) AS '8-16',
    ROUND(100*SUM(CASE WHEN zone_range = '16-24' THEN fga END)/SUM(fga),1) AS '16-24',
    ROUND(100*SUM(CASE WHEN zone_range = '24<' THEN fga END)/SUM(fga),1) AS '24<'
FROM shot_zones
JOIN speed_distance USING(player_id, team_id, season)
JOIN players ON shot_zones.player_id = players.player_id
WHERE minutes_played >= 10 AND position = 'Center'
GROUP BY season
ORDER BY season;

# Pace-adjusted FGA per 100 possessions for each general zone
WITH team_totals AS (
    SELECT team_id, season, general_zone, SUM(fga) AS team_fga
    FROM shot_zones
    GROUP BY team_id, season, general_zone
),
team_with_pace AS (
    SELECT tt.team_id, tt.season, tt.general_zone, tt.team_fga, tas.pace,
	tas.wins + tas.losses AS gp
    FROM team_totals tt
    JOIN team_advanced_stats tas
	ON tt.team_id = tas.team_id AND tt.season  = tas.season
),
pace_adjusted AS (
    SELECT team_id, season, general_zone,
	(team_fga / NULLIF(gp, 0)) / NULLIF(pace / 100, 0) AS fga_per_100_pos
    FROM team_with_pace
)
SELECT season,
    ROUND(AVG(CASE WHEN general_zone = 'Above the Break 3' THEN fga_per_100_pos END), 2) AS 'Above the Break 3',
    ROUND(AVG(CASE WHEN general_zone = 'Left Corner 3' THEN fga_per_100_pos END), 2) AS 'Left Corner 3',
    ROUND(AVG(CASE WHEN general_zone = 'Right Corner 3' THEN fga_per_100_pos END), 2) AS 'Right Corner 3',
    ROUND(AVG(CASE WHEN general_zone = 'Mid-Range' THEN fga_per_100_pos END), 2) AS 'Mid-Range',
    ROUND(AVG(CASE WHEN general_zone = 'Restricted Area' THEN fga_per_100_pos END), 2) AS 'Restricted Area',
    ROUND(AVG(CASE WHEN general_zone = 'Non-RA Paint' THEN fga_per_100_pos END), 2) AS 'Non-RA Paint'
FROM pace_adjusted
GROUP BY season
ORDER BY season;

# Get the average amount of touches per position

SELECT possessions.season, 
    ROUND(AVG(CASE WHEN position = 'Guard' THEN touches END), 1) AS Guard,
    ROUND(AVG(CASE WHEN position = 'Guard/Forward' THEN touches END), 1) AS `Guard/Forward`,
    ROUND(AVG(CASE WHEN position = 'Forward' THEN touches END), 1) AS Forward,
    ROUND(AVG(CASE WHEN position = 'Forward/Center' THEN touches END), 1) AS `Forward/Center`,
    ROUND(AVG(CASE WHEN position = 'Center' THEN touches END), 1) AS Center
    FROM possessions
JOIN players ON possessions.player_id = players.player_id
JOIN speed_distance
ON possessions.player_id = speed_distance.player_id AND possessions.team_id = speed_distance.team_id
AND possessions.season = speed_distance.season
WHERE minutes_played >= 10
GROUP BY possessions.season
ORDER BY possessions.season;

# Get the average amount of touches per position

SELECT possessions.season, 
    ROUND(AVG(CASE WHEN position LIKE 'Guard' THEN touches END), 1) 'Guard',
    ROUND(AVG(CASE WHEN position LIKE 'Guard/Forward' THEN touches END), 1) AS 'Gaurd/Forward',
    ROUND(AVG(CASE WHEN position LIKE 'Forward' THEN touches END), 1) AS 'Forward',
    ROUND(AVG(CASE WHEN position LIKE 'Forward/Center' THEN touches END), 1) AS 'Forward/Center',
    ROUND(AVG(CASE WHEN position = 'Center' THEN touches END), 1) AS 'Center'
FROM possessions
JOIN players ON possessions.player_id = players.player_id
JOIN speed_distance
ON possessions.player_id = speed_distance.player_id
AND possessions.team_id = speed_distance.team_id
AND possessions.season = speed_distance.season
WHERE minutes_played >= 10
GROUP BY possessions.season
ORDER BY possessions.season;

# Average passes made per game by position (players with 10+ min/game)

SELECT pa.season, 
    ROUND(AVG(CASE WHEN pl.position = 'Guard' THEN pa.made END), 1) AS 'Guard',
    ROUND(AVG(CASE WHEN pl.position = 'Guard/Forward' THEN pa.made END), 1) AS 'Guard/Forward',
    ROUND(AVG(CASE WHEN pl.position = 'Forward' THEN pa.made END), 1) AS 'Forward',
    ROUND(AVG(CASE WHEN pl.position = 'Forward/Center' THEN pa.made END), 1) AS 'Forward/Center',
    ROUND(AVG(CASE WHEN pl.position = 'Center' THEN pa.made END), 1) AS 'Center'
FROM passes pa
JOIN players pl ON pa.player_id = pl.player_id
JOIN speed_distance sd
ON pa.player_id = sd.player_id AND pa.team_id = sd.team_id AND pa.season = sd.season
WHERE sd.minutes_played >= 10
GROUP BY pa.season
ORDER BY pa.season;

# Average seconds per touch by position (players with 10+ min/game)

SELECT pos.season, 
    ROUND(AVG(CASE WHEN pl.position = 'Guard' THEN pos.sec_per_touch END), 2) AS 'Guard',
    ROUND(AVG(CASE WHEN pl.position = 'Guard/Forward' THEN pos.sec_per_touch END), 2) AS 'Guard/Forward',
    ROUND(AVG(CASE WHEN pl.position = 'Forward' THEN pos.sec_per_touch END), 2) AS 'Forward',
    ROUND(AVG(CASE WHEN pl.position = 'Forward/Center' THEN pos.sec_per_touch END), 2) AS 'Forward/Center',
    ROUND(AVG(CASE WHEN pl.position = 'Center' THEN pos.sec_per_touch END), 2) AS 'Center'
FROM possessions pos
JOIN players pl ON pos.player_id = pl.player_id
JOIN speed_distance sd ON pos.player_id = sd.player_id AND pos.team_id = sd.team_id
AND pos.season = sd.season
WHERE sd.minutes_played >= 10
GROUP BY pos.season
ORDER BY pos.season;

# Average catch-and-shoot attempts per game by position (players with 10+ min/game)

SELECT cs.season,
    ROUND(AVG(CASE WHEN pl.position = 'Guard' THEN cs.fga END), 2) AS Guard,
    ROUND(AVG(CASE WHEN pl.position = 'Guard/Forward' THEN cs.fga END), 2) AS `Guard/Forward`,
    ROUND(AVG(CASE WHEN pl.position = 'Forward' THEN cs.fga END), 2) AS Forward,
    ROUND(AVG(CASE WHEN pl.position = 'Forward/Center' THEN cs.fga END), 2) AS `Forward/Center`,
    ROUND(AVG(CASE WHEN pl.position = 'Center' THEN cs.fga END), 2) AS Center
FROM catch_and_shoots cs
JOIN players pl 
ON cs.player_id = pl.player_id
JOIN speed_distance sd
ON cs.player_id = sd.player_id AND cs.team_id = sd.team_id AND cs.season = sd.season
WHERE sd.minutes_played >= 10
GROUP BY cs.season
ORDER BY cs.season;

# Pace-adjusted catch-and-shoot attempts per 100 possessions by position

WITH team_pos_totals AS (
    SELECT cs.team_id, cs.season, pl.position, SUM(cs.fga) AS team_pos_cas_fga_per_game
    FROM catch_and_shoots cs
    JOIN players pl
	ON cs.player_id = pl.player_id
    JOIN speed_distance sd
	ON cs.player_id = sd.player_id AND cs.team_id = sd.team_id AND cs.season = sd.season
    WHERE sd.minutes_played >= 10
    GROUP BY cs.team_id, cs.season, pl.position
),
team_with_pace AS (
    SELECT tpt.team_id, tpt.season, tpt.position, tpt.team_pos_cas_fga_per_game,
	tas.pace
    FROM team_pos_totals tpt
    JOIN team_advanced_stats tas
	ON tpt.team_id = tas.team_id AND tpt.season  = tas.season
),
pace_adjusted AS (
    SELECT team_id, season, position,
	team_pos_cas_fga_per_game / NULLIF(pace / 100, 0) AS cas_fga_per_100_pos
    FROM team_with_pace
)
SELECT season,
    ROUND(AVG(CASE WHEN position = 'Guard' THEN cas_fga_per_100_pos END), 2) AS 'Guard',
    ROUND(AVG(CASE WHEN position = 'Guard/Forward' THEN cas_fga_per_100_pos END), 2) AS 'Guard/Forward',
    ROUND(AVG(CASE WHEN position = 'Forward' THEN cas_fga_per_100_pos END), 2) AS 'Forward',
    ROUND(AVG(CASE WHEN position = 'Forward/Center' THEN cas_fga_per_100_pos END), 2) AS 'Forward/Center',
    ROUND(AVG(CASE WHEN position = 'Center' THEN cas_fga_per_100_pos END), 2) AS 'Center'
FROM pace_adjusted
GROUP BY season
ORDER BY season;

# Average pull_ups attempts per game by position (players with 10+ min/game)

SELECT ps.season,
    ROUND(AVG(CASE WHEN pl.position = 'Guard' THEN ps.fga END), 2) AS Guard,
    ROUND(AVG(CASE WHEN pl.position = 'Guard/Forward' THEN ps.fga END), 2) AS `Guard/Forward`,
    ROUND(AVG(CASE WHEN pl.position = 'Forward' THEN ps.fga END), 2) AS Forward,
    ROUND(AVG(CASE WHEN pl.position = 'Forward/Center' THEN ps.fga END), 2) AS `Forward/Center`,
    ROUND(AVG(CASE WHEN pl.position = 'Center' THEN ps.fga END), 2) AS Center
FROM pull_ups ps
JOIN players pl 
ON ps.player_id = pl.player_id
JOIN speed_distance sd
ON ps.player_id = sd.player_id AND ps.team_id = sd.team_id AND ps.season = sd.season
WHERE sd.minutes_played >= 10
GROUP BY ps.season
ORDER BY ps.season;

# Pace-adjusted pull-up attempts per 100 possessions by position

WITH team_pos_totals AS (
    SELECT ps.team_id, ps.season, pl.position, SUM(ps.fga) AS team_pos_ps_fga_per_game
    FROM pull_ups ps
    JOIN players pl
	ON ps.player_id = pl.player_id
    JOIN speed_distance sd
	ON ps.player_id = sd.player_id AND ps.team_id = sd.team_id AND ps.season = sd.season
    WHERE sd.minutes_played >= 10
    GROUP BY ps.team_id, ps.season, pl.position
),
team_with_pace AS (
    SELECT tpt.team_id, tpt.season, tpt.position, tpt.team_pos_ps_fga_per_game,
	tas.pace
    FROM team_pos_totals tpt
    JOIN team_advanced_stats tas
	ON tpt.team_id = tas.team_id AND tpt.season  = tas.season
),
pace_adjusted AS (
    SELECT team_id, season, position,
	team_pos_ps_fga_per_game / NULLIF(pace / 100, 0) AS ps_fga_per_100_pos
    FROM team_with_pace
)
SELECT season,
    ROUND(AVG(CASE WHEN position = 'Guard' THEN ps_fga_per_100_pos END), 2) AS 'Guard',
    ROUND(AVG(CASE WHEN position = 'Guard/Forward' THEN ps_fga_per_100_pos END), 2) AS 'Guard/Forward',
    ROUND(AVG(CASE WHEN position = 'Forward' THEN ps_fga_per_100_pos END), 2) AS 'Forward',
    ROUND(AVG(CASE WHEN position = 'Forward/Center' THEN ps_fga_per_100_pos END), 2) AS 'Forward/Center',
    ROUND(AVG(CASE WHEN position = 'Center' THEN ps_fga_per_100_pos END), 2) AS 'Center'
FROM pace_adjusted
GROUP BY season
ORDER BY season;

# Average dribbles per touch by position (players with 10+ min/game)

SELECT 
    pos.season, 
    ROUND(AVG(CASE WHEN pl.position = 'Guard' THEN pos.dribble_per_touch END), 2) AS 'Guard',
    ROUND(AVG(CASE WHEN pl.position = 'Guard/Forward' THEN pos.dribble_per_touch END), 2) AS 'Guard/Forward',
    ROUND(AVG(CASE WHEN pl.position = 'Forward' THEN pos.dribble_per_touch END), 2) AS 'Forward',
    ROUND(AVG(CASE WHEN pl.position = 'Forward/Center' THEN pos.dribble_per_touch END), 2) AS 'Forward/Center',
    ROUND(AVG(CASE WHEN pl.position = 'Center' THEN pos.dribble_per_touch END), 2) AS 'Center'
FROM possessions pos
JOIN players pl
ON pos.player_id = pl.player_id
JOIN speed_distance sd
ON pos.player_id = sd.player_id AND pos.team_id = sd.team_id AND pos.season= sd.season
WHERE sd.minutes_played >= 10
GROUP BY pos.season
ORDER BY pos.season;

# Miles traveled per player in mpg by position (players with 10+ min/game)

SELECT sd.season,
    ROUND(AVG(CASE WHEN pl.position = 'Guard' THEN sd.offensive_miles_traveled END), 2) AS Guard_miles,
    ROUND(AVG(CASE WHEN pl.position = 'Guard/Forward' THEN sd.offensive_miles_traveled END), 2) AS `Guard/Forward_miles`,
    ROUND(AVG(CASE WHEN pl.position = 'Forward' THEN sd.offensive_miles_traveled END), 2) AS Forward_miles,
    ROUND(AVG(CASE WHEN pl.position = 'Forward/Center' THEN sd.offensive_miles_traveled END), 2) AS `Forward/Center_miles`,
    ROUND(AVG(CASE WHEN pl.position = 'Center' THEN sd.offensive_miles_traveled END), 2) AS Center_miles
FROM speed_distance sd
JOIN players pl
ON sd.player_id = pl.player_id
WHERE sd.minutes_played >= 10
GROUP BY sd.season
ORDER BY sd.season;

# Average speed per player in mpg by position (players with 10+ min/game)

SELECT
    ROUND(AVG(CASE WHEN pl.position = 'Guard' THEN sd.average_speed END), 3) AS Guard_speed,
    ROUND(AVG(CASE WHEN pl.position = 'Guard/Forward' THEN sd.average_speed END), 3) AS `Guard/Forward_speed`,
    ROUND(AVG(CASE WHEN pl.position = 'Forward' THEN sd.average_speed END), 3) AS Forward_speed,
    ROUND(AVG(CASE WHEN pl.position = 'Forward/Center' THEN sd.average_speed END), 3) AS `Forward/Center_speed`,
    ROUND(AVG(CASE WHEN pl.position = 'Center' THEN sd.average_speed END), 3) AS Center_speed
FROM speed_distance sd
JOIN players pl
ON sd.player_id = pl.player_id
WHERE sd.minutes_played >= 10
GROUP BY sd.season
ORDER BY sd.season;

# 3PA rate vs offensive rating by team and season

WITH team_shot_mix AS (
    SELECT 
        sz.team_id,
        sz.season,
        SUM(sz.fga) AS total_fga,
        SUM(
            CASE 
			WHEN sz.general_zone IN ('Above the Break 3', 'Left Corner 3', 'Right Corner 3')
			THEN sz.fga ELSE 0 END) AS three_fga
    FROM shot_zones sz
    GROUP BY sz.team_id, sz.season
)
SELECT tsm.season,
    ROUND(AVG(tsm.three_fga / NULLIF(tsm.total_fga, 0) * 100), 2) AS `3pt_share_pct`,
    ROUND(AVG(tas.off_rating), 2) AS avg_off_rating,
    ROUND(AVG(tas.efg_pct), 2) AS avg_efg_pct, 
    ROUND(AVG(tas.pace), 2) AS avg_pace
FROM team_shot_mix tsm
JOIN team_advanced_stats tas
ON tsm.team_id = tas.team_id AND tsm.season = tas.season
GROUP BY tsm.season
ORDER BY tsm.season;

