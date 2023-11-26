ALTER TABLE my_spotify_data.dbo.stream_history_co_prepared
ADD timesOfDayPlayed VARCHAR(255);
GO

WITH extra_info AS (
    SELECT STRING_AGG(inner_query.Hour, ', ') AS timesOfDayPlayed, 
            inner_query.searchTerm AS searchTerm
    FROM (
        SELECT Hour, searchTerm
        FROM my_spotify_data.dbo.stream_history
        WHERE endTime >= '2023-04-19'
        GROUP BY Hour, searchTerm
    ) AS inner_query
    GROUP BY inner_query.searchTerm
) 

UPDATE my_spotify_data.dbo.stream_history_co_prepared 
SET timesOfDayPlayed = (
    SELECT timesOfDayPlayed
    FROM extra_info
    WHERE my_spotify_data.dbo.stream_history_co_prepared.searchTerm = extra_info.searchTerm
)