CREATE EXTENSION "uuid-ossp";

SELECT uuid_generate_v4()

-- Solution 1
-- Find number where (larger) numbers count is equal (less or equal) numbers count 

select (
	case 
		when count(s."ID") <= 2 THEN (
			select AVG(s."LAT_N")
		)
		when count(s."ID") % 2 = 0 THEN (
			select AVG(nums."med") as median
			from
			(
				select ROUND(s."LAT_N"::numeric, 4) as med from station s
				where (select floor(count(distinct s1."LAT_N") / 2) from station s1)
					= (select count(distinct s2."LAT_N") from station s2 where s2."LAT_N" > s."LAT_N")
				union all
				select ROUND(s."LAT_N"::numeric, 4) as med from station s
				where (select floor(count(distinct s1."LAT_N") / 2) - 1 from station s1)
					= (select count(distinct s2."LAT_N") from station s2 where s2."LAT_N" > s."LAT_N")	
			) as nums		
		)
		else (
			select ROUND(s."LAT_N"::numeric, 4) as median from station s
			where (select floor(count(distinct s1."LAT_N") / 2) from station s1)
				= (select count(distinct s2."LAT_N") from station s2 where s2."LAT_N" > s."LAT_N")
		)
	end
) as res
from station s

-- Also Solution 1
-- But with view to filter distinct lat_n, long_w

create OR REPLACE view distinct_station_lat_longw as
select s2.*
from station s2 inner join 
	(select DISTINCT s."UID", s."LAT_N", s."LONG_W"
		from station s) as s3 on s2."UID" = s3."UID"
		
select (
	case 
		when count(s."ID") <= 2 THEN (
			select AVG(s."LAT_N")
		)
		when count(s."ID") % 2 = 0 THEN (
			select AVG(nums."med") as median
			from
			(
				select round(s."LAT_N"::numeric, 4) as med from distinct_station_lat_longw s
				where (select floor(count(s1."ID") / 2) from distinct_station_lat_longw s1)
					= (select count(s2."ID") from distinct_station_lat_longw s2 where s2."LAT_N" > s."LAT_N")
				union all
				select round(s."LAT_N"::numeric, 4) as med from distinct_station_lat_longw s
				where (select floor(count(s1."ID") / 2) - 1 from distinct_station_lat_longw s1)
					= (select count(s2."ID") from distinct_station_lat_longw s2 where s2."LAT_N" > s."LAT_N")	
			) as nums		
		)
		else (
			select round(s."LAT_N"::numeric, 4) as median from distinct_station_lat_longw s
			where (select distinct floor(count(s1."ID") / 2) from distinct_station_lat_longw s1)
				= (select distinct count(s2."ID") from distinct_station_lat_longw s2 where s2."LAT_N" > s."LAT_N")
		)
	end
) as res
from distinct_station_lat_longw s
  
-- Solution 2 (first sample)
-- Sorting, assign increasing ids. Find the center id

select (
	case 
		when count(s."ID") <= 2 THEN (
			select AVG(s."LAT_N")
		)
		when count(s."ID") % 2 = 0 THEN (
			WITH
			    limit1 AS (select floor(count(s."ID") / 2) - 1 from station s),
			    limit2 AS (select floor(count(s."ID") / 2) from station s)
			select AVG(nums."med") as median
				from (
					(select round(s."LAT_N"::numeric, 4) as med
					from (select * from station s order by s."LAT_N") as s
					limit 1 offset (table limit1))
					union all
					(select round(s."LAT_N"::numeric, 4) as med
					from (select * from station s order by s."LAT_N") as s
					limit 1 offset (table limit2))
				) as nums
		)
		else (
			WITH
			    limit2 AS (select floor(count(s."ID") / 2) from station s)
			select round(s."LAT_N"::numeric, 4) as med
				from (select * from station s order by s."LAT_N") as s
				limit 1 offset (table limit2)
		)
	end
) as res
from station s

-- Solution 2 (second sample, much faster!)
-- Sorting, assign increasing ids. Find the center id

select (
	case 
		when count(s."ID") <= 2 THEN (
			select AVG(s."LAT_N")
		)
		when count(s."ID") % 2 = 0 THEN (
			WITH
			    limit1 AS (select floor(count(s."ID") / 2) - 1 from station s),
			    limit2 AS (select floor(count(s."ID") / 2) from station s)
			select AVG(nums."med") as median
				from (
					(select round(s."LAT_N"::numeric, 4) as med
					from (select * from station s order by s."LAT_N") as s
					limit 1 offset (select * from limit1))
					union all
					(select round(s."LAT_N"::numeric, 4) as med
					from (select * from station s order by s."LAT_N") as s
					limit 1 offset (select * from limit2))
				) as nums
		)
		else (
			WITH
			    limit2 AS (select floor(count(s."ID") / 2) from station s)
			select round(s."LAT_N"::numeric, 4) as med
				from (select * from station s order by s."LAT_N") as s
				limit 1 offset (select * from limit2)
		)
	end
) as res
from station s

-- Solution 2 (third sample, using row number)
-- Sorting, assign increasing ids. Find the center id

-- CAUTION, row number start from 1 not zero

select (
	case 
		when count(s."ID") <= 2 THEN (
			select AVG(s."LAT_N")
		)
		when count(s."ID") % 2 = 0 THEN (
			WITH
			    limit1 AS (select floor(count(s."ID") / 2) from station s),
			    limit2 AS (select floor(count(s."ID") / 2) + 1 from station s)
			select AVG(nums."med") as median
				from (
					(select round(s."LAT_N"::numeric, 4) as med
					from (select s."LAT_N", row_number() over (order by s."LAT_N") as r from station s) as s
					where s."r" = (select * from limit1))
					union all
					(select round(s."LAT_N"::numeric, 4) as med
					from (select s."LAT_N", row_number() over (order by s."LAT_N") as r from station s) as s
					where s."r" = (select * from limit2))
				) as nums
		)
		else (
			WITH
			    limit2 AS (select floor(count(s."ID") / 2) from station s)
			select round(s."LAT_N"::numeric, 4) as med
				from (select s."LAT_N", row_number() over (order by s."LAT_N") as r from station s) as s
				where s."r" = (select * from limit2)
		)
	end
) as res
from station s