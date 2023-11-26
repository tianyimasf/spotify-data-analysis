-- Top Played Artist Info
SELECT
    TOP 20
    AVG(times_played) as avg_times_played,
    MIN(artist_name) as artist_name,
    MAX(artist_popularity) as artist_popularity,
    MAX(artist_followers_num) as artist_followers_num,
    STRING_AGG(track_name, ', ') as tracks
FROM
    my_spotify_data.dbo.stream_history_co_prepared
GROUP BY artist_id
ORDER BY avg_times_played DESC