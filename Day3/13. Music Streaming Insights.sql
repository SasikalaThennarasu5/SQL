-- Create Tables
CREATE TABLE artists (
    artist_id INT PRIMARY KEY,
    artist_name VARCHAR(100)
);

CREATE TABLE songs (
    song_id INT PRIMARY KEY,
    title VARCHAR(100),
    artist_id INT,
    genre VARCHAR(50),
    duration INT, -- duration in seconds
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

CREATE TABLE listeners (
    listener_id INT PRIMARY KEY,
    listener_name VARCHAR(100),
    preferred_genre VARCHAR(50)
);

CREATE TABLE plays (
    play_id INT PRIMARY KEY,
    song_id INT,
    listener_id INT,
    play_timestamp TIMESTAMP,
    FOREIGN KEY (song_id) REFERENCES songs(song_id),
    FOREIGN KEY (listener_id) REFERENCES listeners(listener_id)
);

-- Total plays per song
SELECT s.title, COUNT(p.play_id) AS total_plays
FROM songs s
JOIN plays p ON s.song_id = p.song_id
GROUP BY s.title
ORDER BY total_plays DESC;

-- Average play duration per genre
SELECT genre, AVG(duration) AS avg_duration_seconds
FROM songs
GROUP BY genre;

-- Artists with songs played more than 1000 times
SELECT a.artist_name, COUNT(p.play_id) AS total_song_plays
FROM artists a
JOIN songs s ON a.artist_id = s.artist_id
JOIN plays p ON s.song_id = p.song_id
GROUP BY a.artist_name
HAVING COUNT(p.play_id) > 1000;

-- INNER JOIN: songs ↔ plays
SELECT s.title, p.play_timestamp
FROM songs s
INNER JOIN plays p ON s.song_id = p.song_id;

-- RIGHT JOIN: listeners ↔ plays (list listeners even if no play)
SELECT l.listener_name, p.play_id, p.play_timestamp
FROM listeners l
RIGHT JOIN plays p ON l.listener_id = p.listener_id;

-- SELF JOIN: listeners who play songs of same genre
SELECT l1.listener_name AS listener1, l2.listener_name AS listener2, l1.preferred_genre
FROM listeners l1
JOIN listeners l2 ON l1.preferred_genre = l2.preferred_genre 
    AND l1.listener_id <> l2.listener_id;
