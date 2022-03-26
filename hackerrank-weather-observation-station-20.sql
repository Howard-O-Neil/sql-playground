use practice;

SHOW GLOBAL VARIABLES LIKE '%infile%';
# SET GLOBAL local_infile = 'ON';
Select @@global.secure_file_priv;

delete from station 
select * from station s

select round(s.lat_n,4) 
from station s 
where (select round(count(s.id)/2)-1 
	from station) = 
		(select count(s1.id) 
		from station s1 
		where s1.lat_n > s.lat_n);