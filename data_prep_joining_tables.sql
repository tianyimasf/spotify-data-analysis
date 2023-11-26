ALTER TABLE my_spotify_data.dbo.stream_history_co_prepared
ADD track_id VARCHAR(50),
    track_name NVARCHAR(150),
    track_popularity INT,
    track_duration_ms INT,
    artist_id VARCHAR(50),
    artist_name NVARCHAR(50),
    artist_popularity INT,
    artist_followers_num INT,
    artist_genre VARCHAR(200),
    album_id VARCHAR(50),
    album_name NVARCHAR(150),
    album_popularity INT,
    album_label NVARCHAR(200),
    total_tracks INT;
GO

UPDATE history
  SET history.track_id = tracks.track_id,
    history.track_name = tracks.track_name,
    history.track_popularity = tracks.track_popularity,
    history.track_duration_ms = tracks.track_duration_ms,
    history.artist_id = tracks.artist_id,
    history.artist_name = tracks.artist_name,
    history.artist_popularity = tracks.artist_popularity,
    history.artist_followers_num = tracks.artist_followers_num,
    history.artist_genre = tracks.artist_genre,
    history.album_id = tracks.album_id,
    history.album_name = tracks.album_name,
    history.album_popularity = tracks.album_popularity,
    history.album_label = tracks.album_label,
    history.total_tracks = tracks.total_tracks
  FROM my_spotify_data.dbo.stream_history_co_prepared AS history
  INNER JOIN my_spotify_data.dbo.tracks AS tracks
  ON history.trackName = tracks.track_name AND history.artistName = tracks.artist_name

ALTER TABLE my_spotify_data.dbo.stream_history_co_prepared
DROP COLUMN searchTerm, trackName, artistName;

DELETE FROM my_spotify_data.dbo.stream_history_co_prepared
WHERE track_id IS NULL;

SELECT COUNT(*) FROM my_spotify_data.dbo.stream_history_co_prepared