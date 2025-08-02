-- 1. Create tables
CREATE TABLE artists (
    artist_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE songs (
    song_id INT PRIMARY KEY,
    title VARCHAR(100),
    artist_id INT,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    username VARCHAR(100)
);

CREATE TABLE play_history (
    play_id INT PRIMARY KEY,
    user_id INT,
    song_id INT,
    play_time DATETIME,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (song_id) REFERENCES songs(song_id)
);

-- 2. JOIN to show who listened to which song
SELECT u.username, s.title AS song_title, a.name AS artist_name, ph.play_time
FROM play_history ph
JOIN users u ON ph.user_id = u.user_id
JOIN songs s ON ph.song_id = s.song_id
JOIN artists a ON s.artist_id = a.artist_id;

-- 3. GROUP BY + COUNT() to get top songs
SELECT s.title AS song_title, COUNT(*) AS play_count
FROM play_history ph
JOIN songs s ON ph.song_id = s.song_id
GROUP BY s.title
ORDER BY play_count DESC;

-- 4. ORDER BY for most played artists
SELECT a.name AS artist_name, COUNT(*) AS total_plays
FROM play_history ph
JOIN songs s ON ph.song_id = s.song_id
JOIN artists a ON s.artist_id = a.artist_id
GROUP BY a.artist_id, a.name
ORDER BY total_plays DESC;

-- 5. Subquery to get users who listened to the same artist >10 times
SELECT user_id, artist_id, total_plays
FROM (
  SELECT u.user_id, a.artist_id, COUNT(*) AS total_plays
  FROM play_history ph
  JOIN users u ON ph.user_id = u.user_id
  JOIN songs s ON ph.song_id = s.song_id
  JOIN artists a ON s.artist_id = a.artist_id
  GROUP BY u.user_id, a.artist_id
) AS user_artist_plays
WHERE total_plays > 10;

-- 6. CASE to label users as “Light”, “Moderate”, “Heavy” listeners
SELECT u.user_id, u.username, COUNT(*) AS total_plays,
  CASE
    WHEN COUNT(*) > 100 THEN 'Heavy'
    WHEN COUNT(*) BETWEEN 51 AND 100 THEN 'Moderate'
    ELSE 'Light'
  END AS listener_type
FROM users u
JOIN play_history ph ON u.user_id = ph.user_id
GROUP BY u.user_id, u.username;

-- 7. LIKE '%Love%' to filter romantic songs
SELECT s.song_id, s.title, a.name AS artist
FROM songs s
JOIN artists a ON s.artist_id = a.artist_id
WHERE s.title LIKE '%Love%';
