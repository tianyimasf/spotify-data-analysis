ALTER TABLE my_spotify_data.dbo.stream_history
    ADD searchTerm AS CONCAT(trackName, ' ', artistName),
        Date AS CAST(endTime as Date),
        Time AS CAST(endTime AS Time),
        Hour AS DATEPART(hour, endTime)

ALTER TABLE my_spotify_data.dbo.stream_history_sf_prepared
    ADD searchTerm AS CONCAT(trackName, ' ', artistName)

ALTER TABLE my_spotify_data.dbo.stream_history_co_prepared
    ADD searchTerm AS CONCAT(trackName, ' ', artistName)

SELECT TOP 100 * FROM my_spotify_data.dbo.stream_history_sf_prepared