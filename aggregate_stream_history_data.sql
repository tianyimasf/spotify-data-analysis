/*SELECT searchTerm,
    MIN(trackName) AS trackName, 
    MIN(artistName) AS artistName, 
    COUNT(endTime) AS playCount,
    COUNT(DISTINCT Date) AS daysPlayedTrack,
    SUM(msPlayed) AS totalTimePlayed INTO my_spotify_data.dbo.stream_history_sf_prepared
FROM my_spotify_data.dbo.stream_history
WHERE endTime < '2023-04-19'
GROUP BY searchTerm*/


SELECT searchTerm,
    MIN(trackName) AS trackName, 
    MIN(artistName) AS artistName, 
    COUNT(endTime) AS playCount,
    COUNT(DISTINCT Date) AS daysPlayedTrack,
    SUM(msPlayed) AS totalTimePlayed INTO my_spotify_data.dbo.stream_history_co_prepared
FROM my_spotify_data.dbo.stream_history
WHERE endTime >= '2023-04-19'
GROUP BY searchTerm