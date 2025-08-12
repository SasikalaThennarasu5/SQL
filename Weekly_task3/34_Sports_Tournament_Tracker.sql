-- Sports Tournament Tracker
CREATE TABLE teams (
    id INT PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE matches (
    id INT PRIMARY KEY,
    team1_id INT,
    team2_id INT,
    match_date DATE
);

CREATE TABLE scores (
    match_id INT,
    team_id INT,
    score INT
);

-- Leaderboard (wins/draws/losses)
WITH paired AS (
  SELECT s.match_id, s.team_id, s.score,
         CASE WHEN s.score > opp.score THEN 'win'
              WHEN s.score = opp.score THEN 'draw' ELSE 'loss' END AS result
  FROM scores s
  JOIN scores opp ON s.match_id = opp.match_id AND s.team_id <> opp.team_id
)
SELECT t.id, t.name,
 SUM(CASE WHEN p.result = 'win' THEN 1 ELSE 0 END) AS wins,
 SUM(CASE WHEN p.result = 'draw' THEN 1 ELSE 0 END) AS draws,
 SUM(CASE WHEN p.result = 'loss' THEN 1 ELSE 0 END) AS losses
FROM teams t
LEFT JOIN paired p ON t.id = p.team_id
GROUP BY t.id, t.name
ORDER BY wins DESC, draws DESC;
