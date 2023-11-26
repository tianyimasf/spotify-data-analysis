-- 100 Top played tracks and their info
/*SELECT 
    TOP 100 * INTO #top_played_tracks_co
FROM my_spotify_data.dbo.stream_history_co_prepared as history_co
ORDER BY times_played DESC

-- create histogram data by calculating bin boundaries and # items in bins
select 
    bin_floor,
    count(track_id) as tracks_num
from (
    select 
        floor(times_played/5.00)*5 as bin_floor,
        track_id
    from #top_played_tracks_co
) as convert_to_bins
group by bin_floor
order by bin_floor

-- Top 75 played tracks based on # days played
SELECT 
    TOP 75 * INTO #top_days_played_tracks_co
FROM my_spotify_data.dbo.stream_history_co_prepared as history_co
ORDER BY days_played DESC

select 
    bin_floor,
    count(track_id) as tracks_num
from (
    select 
        floor(days_played/1.00)*1 as bin_floor,
        track_id
    from #top_days_played_tracks_co
) as convert_to_bins
group by bin_floor
order by bin_floor

-- Overlap between Top 100 played and Top 75 played based on the two differen criteria
-- 54 songs
SELECT COUNT(top_played.track_id)
FROM #top_days_played_tracks_co as top_days
INNER JOIN #top_played_tracks_co as top_played
ON top_days.track_id = top_played.track_id;

-- What are those 54 songs?
SELECT
    top_days.track_id,
    top_days.track_name,
    top_days.track_popularity,
    top_days.track_duration_ms,
    top_days.artist_id,
    top_days.artist_name,
    top_days.artist_popularity,
    top_days.artist_followers_num,
    top_days.artist_genre,
    top_days.album_id,
    top_days.album_name,
    top_days.album_popularity,
    top_days.album_label,
    top_days.total_tracks,
    top_days.times_of_day_played
    top_days.times_played,
    top_days.days_played,
    top_days.total_time_played
INTO #top_54_played_tracks
FROM #top_days_played_tracks_co as top_days
INNER JOIN #top_played_tracks_co as top_played
ON top_days.track_id = top_played.track_id;

-- Histogram of track_popularity
select 
    bin_floor,
    count(track_id) as tracks_num
from (
    select 
        floor(track_popularity/5.00)*5 as bin_floor,
        track_id
    from #top_54_played_tracks
) as convert_to_bins
group by bin_floor
order by bin_floor

-- Histogram of artist_popularity
select 
    bin_floor,
    count(track_id) as tracks_num
from (
    select 
        floor(artist_popularity/5.00)*5 as bin_floor,
        track_id
    from #top_54_played_tracks
) as convert_to_bins
group by bin_floor
order by bin_floor

-- Times of day played distribution (histogram)
select 
    FORMAT(DATEADD(HH, value_int,'00:00:00'),'hh:mm tt') as time_of_day, 
    count(*) as times_played
from (
    select cast(value as int) as value_int
    from #top_54_played_tracks
        cross apply string_split(times_of_day_played, ',') as int
) as query1
group by value_int
order by value_int

-- Genre distribution (histogram)
select 
    trim(' ' from replace(value, '''', '')) as genre, 
    count(*) as songs_of_genre
from (
    select replace(replace(artist_genre, '[', ''), ']', '') as artist_genre_trimmed
    from #top_54_played_tracks
) as query1
    cross apply string_split(artist_genre_trimmed, ',')
where artist_genre_trimmed != ''
group by value 
order by songs_of_genre desc*/

select * from #top_played_tracks_co