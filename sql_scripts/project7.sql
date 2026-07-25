select * from participations
select * from countries
select * from athletes
select * from sports
select * from olympicgames

/*
Report 1: Country Medal Matrix
Show the medal breakdown of every country
*/
select * from (
   select c.countryname,
   p.medal
   from participations p
   inner join countries c
   on c.countryid=p.countryid
   where p.medal<>'na'
)as sourcetable
pivot(
 count(medal) for medal in ([Gold],[Silver],[Bronze])
)as pivottable
order by countryname
/*
Report 2: Sport-wise Medal Matrix
Which sports award the highest number of each medal type?
*/
select * from (
   select s.sportsname,
   p.medal
   from participations p
   inner join sports s
   on s.sportsid=p.sportid
   where p.medal<>'na'
)as sourcetable
pivot(
 count(medal) for medal in ([Gold],[Silver],[Bronze])
)as pivottable
order by gold desc
/*
Report 3: Olympic Season Medal Matrix
Compare Summer and Winter Olympics by medal distribution.
*/
select * from (
   select o.season,
   p.medal
   from participations p
   inner join olympicgames o
   on o.gameid=p.gameid
   where p.medal<>'na'
)as sourcetable
pivot(
 count(medal) for medal in ([Gold],[Silver],[Bronze])
)as pivottable
order by gold desc
/*
Report 4: Country × Sport Heat Map
Which sports contribute the most medals for each country?
*/
select * from (
   select c.countryname,
   s.sportsname
   from participations p
   inner join countries c
   on c.countryid=p.countryid
   inner join sports s
   on p.sportid=s.sportsid
   where p.medal<>'na'
)as sourcetable
pivot(
 count(sportsname) for sportsname in ([Athletics],
        [Swimming],
        [Gymnastics],
        [Wrestling],
        [Boxing],
        [Rowing],
        [Cycling],
        [Shooting],
        [Football],
        [Hockey])
)as pivottable
order by countryname 

/*
Report 5: Medal Distribution by Decade
How has medal distribution changed over decades?
*/
select * from (
   select 
   concat((o.year/10)*10,'s')as decade,
   p.medal
   from participations p
   inner join olympicgames o
   on o.gameid=p.gameid
   where p.medal<>'na'
)as sourcetable
pivot(
 count(medal) for medal in ([Gold],[Silver],[Bronze])
)as pivottable
order by decade

/*
Report 6:Country × Olympic Season Matrix
*/
select * from (
   select c.countryname,
   o.season
   from participations p
   inner join countries c
   on c.countryid=p.countryid
   inner join olympicgames o
   on o.gameid=p.gameid
   where p.medal<>'na'
)as sourcetable
pivot(
 count(season) for season in ([summer],[winter])
)as pivottable
order by countryname