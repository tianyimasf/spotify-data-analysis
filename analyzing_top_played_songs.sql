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
    top_days.times_of_day_played,
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
order by songs_of_genre desc

-- Catagoricalize time of day
select
    distinct time_of_day_catagorical = case
        when cast('12:00 AM' as time) <= time_of_day and time_of_day < cast('04:00 AM' as time) then 'late night'
        when cast('04:00 AM' as time) <= time_of_day and time_of_day < cast('08:00 AM' as time) then 'early morning'
        when cast('08:00 AM' as time) <= time_of_day and time_of_day < cast('12:00 PM' as time) then 'morning'
        when cast('12:00 PM' as time) <= time_of_day and time_of_day < cast('04:00 PM' as time) then 'afternoon'
        when cast('04:00 PM' as time) <= time_of_day and time_of_day < cast('08:00 PM' as time) then 'evening'
        when cast('08:00 PM' as time) <= time_of_day and time_of_day <= cast('11:59 PM' as time) then 'night'
    end,
    track_id into #time_of_day_catagorical
from (
    select
        format(dateadd(HH, value_int,'00:00:00'),'hh:mm tt') as time_of_day, 
        track_id
    from (
        select cast(value as int) as value_int, track_id
        from #top_54_played_tracks
            cross apply string_split(times_of_day_played, ',') as int
    ) as query1
) as query2

-- Make dummy variables
select 
    late_night = case when exists (
                        select top 1 * from #time_of_day_catagorical where time_of_day_catagorical = 'late night'
                    ) then 1 else 0 end,
    early_morning = case when exists (
                        select top 1 * from #time_of_day_catagorical where time_of_day_catagorical = 'early_morning'
                    ) then 1 else 0 end,
    morning = case when exists (
                        select top 1 * from #time_of_day_catagorical where time_of_day_catagorical = 'morning'
                    ) then 1 else 0 end,         
    afternoon = case when exists (
                        select top 1 * from #time_of_day_catagorical where time_of_day_catagorical = 'afternoon'
                    ) then 1 else 0 end,
    evening = case when exists (
                        select top 1 * from #time_of_day_catagorical where time_of_day_catagorical = 'evening'
                    ) then 1 else 0 end,
    night = case when exists (
                        select top 1 * from #time_of_day_catagorical where time_of_day_catagorical = 'night'
                    ) then 1 else 0 end,
    track_id into #time_of_day_dummy_variables
from #time_of_day_catagorical
group by track_id

select t1.late_night, t1.early_morning, t1.morning, 
    t1.afternoon, t1.evening, t1.night,
    t2.track_name, t2.artist_name, t2.times_played, t2.days_played
    into #top_54_played_tracks_with_times
from #time_of_day_dummy_variables as t1
inner join #top_54_played_tracks as t2
on t1.track_id = t2.track_id

-- Compare hourly listening habit
-- Seems to be the same because we didn't consider the count of hours
select top 20 track_name
from #top_54_played_tracks_with_times
where late_night = 1
order by times_played

select top 20 track_name
from #top_54_played_tracks_with_times
where afternoon = 1
order by times_played
select count(*) as hour_count, history.Hour as hour, 
    MAX(history.trackName) as track_name, MAX(tracks.track_id) as track_id, 
    MAX(history.artistName) as artist_name, MAX(tracks.artist_id) as artist_id
    into #stream_history_co_temp
from my_spotify_data.dbo.stream_history as history
inner join my_spotify_data.dbo.tracks as tracks
on history.trackName = tracks.track_name and history.artistName = tracks.artist_name
where endTime >= '2023-04-19'
group by searchTerm, Hour

-- Tracks with time of day played and count for each time section, ordered descended
select 
    sum(hour_count) as count, time_of_day,
    max(track_id) as track_id, max(track_name) as track_name, 
    max(artist_id) as artist_id, max(artist_name) as artist_name
    into my_spotify_data.dbo.tracks_with_time_of_day_count_co
from (
    select
        case
        when 0 <= hour and hour < 4 then 'late night'
        when 4 <= hour and hour < 8 then 'early morning'
        when 8 <= hour and hour < 12 then 'morning'
        when 12 <= hour and hour < 16 then 'afternoon'
        when 16 <= hour and hour < 20 then 'evening'
        when 20 <= hour and hour <= 23 then 'night'
        end as time_of_day, *
    from #stream_history_co_temp
) as query1
group by time_of_day, track_name, artist_name
order by count desc*/

-- Now look at top played at time of day again
select top 20 track_name, count 
from my_spotify_data.dbo.tracks_with_time_of_day_count_co
where time_of_day = 'afternoon'
order by count desc