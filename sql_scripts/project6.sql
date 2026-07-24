select * from participations
select * from countries
select * from athletes
select * from sports
select * from olympicgames

/*
Report 1: Country Momentum Index
Which countries are improving, stagnating, or declining over consecutive Olympics?
*/
with countrymedals as (
select c.countryname,
o.year,
count(*) as totalmedal
from participations p
inner join countries c
on c.countryid=p.countryid
inner join olympicgames o
on o.gameid=p.gameid
where p.medal<>'na'
group by c.countryname,o.year  
)
select countryname,
       [year],
       totalmedal,
       lag(totalmedal)over(partition by countryname order by [year]) as previousmedals,
       totalmedal- lag(totalmedal)over(partition by countryname order by [year])as medalchange,

       case 
          when totalmedal>lag(totalmedal)over(partition by countryname order by [year]) then 'improving'
          when totalmedal<lag(totalmedal)over(partition by countryname order by [year]) then 'declining'
          else 'stable'
        end as trend
        from countrymedals

/*
Report 2: Peak Performance Age by Sport
At what age do athletes generally win medals in each sport?
*/
select s.sportsname,
round(avg(cast(p.age as float)),2)as average_medal_age
from participations p
inner join sports s
on p.sportid=s.sportsid
where p.medal<>'na'
group by s.sportsname
order by average_medal_age

/*
Report 3: Medal Dependency Index
Is a country dependent on one sport?
*/
with sportmedal as(
   select c.countryname,
   s.sportsname,
   count(*) as medals
   from participations p
   inner join countries c
   on c.countryid=p.countryid
   inner join sports s
   on s.sportsid=p.sportid
   where p.medal<>'na'
   group by c.countryname,s.sportsname
),
ranked as (
select *,
dense_rank()over(partition by countryname order by medals desc )rk
from sportmedal
)
select * from ranked where rk=1;

/*
Report 4: Medal Concentration
Which athletes account for most of their country's medals?
*/
select a.name,
c.countryname,
count(*) as totalmedals,
round(count(*)*100.0/sum(count(*)) over (partition by c.countryname),2) as contributionpercent
from participations p
inner join athletes a
on a.athleteid=p.athleteid
inner join countries c
on c.countryid=p.countryid
where p.medal<>'na' 
group by a.name,c.countryname

/*
Report 5: Event Competitiveness
Which Olympic events attract the highest number of countries?
*/
select
eventname,
count(distinct countryid) as countriesparticipated
from participations
group by eventname
order by countriesparticipated desc

/*
Report 6:Medal Streak Analysis
Which athletes won medals in the highest number of consecutive Olympic Games?
*/

with streakanalysis as(
select a.athleteid,
       a.name,
       o.year,
       row_NUMBER() OVER (partition by a.athleteid order by year ) as rn
       from participations p
       inner join athletes a
       on a.athleteid=p.athleteid
       inner join olympicgames o
       on o.gameid=p.gameid
       where p.medal <>'na'
),
grouped as (
select *,year-(rn*4)as grp
from streakanalysis
)

select name,min(YEAR)as stratolympics,
max(year) as endolympics,
count(*)as consecutivemedalolympics
from grouped
group by name , athleteid,grp
order by consecutivemedalolympics desc

/*
Report 7: Sport Evolution Ranking
Which sports are growing fastest in participation?
*/
with sportparticipations as(
     select s.sportsname,
     o.year,
     count(distinct p.athleteid) as totalathletes
     from participations p
     inner join sports s
     on s.sportsid=p.sportid
     inner join olympicgames o
     on o.gameid=p.gameid
     group by  s.sportsname,o.year
)
select 
     sportsname,
     year,
     totalathletes,
     lag(totalathletes)over(partition by sportsname order by year)as previousathletes,
     totalathletes-lag(totalathletes)over(partition by sportsname order by year)as growth,
     rank()over(partition by year order by totalathletes ) as rank
from sportparticipations

/*
report 8:Olympic Dynasty Detector
Which countries stayed in the Top 5 medal table for the longest continuous period?
*/
with countrymedals as(
select o.year,
       c.countryname,
       count(*) medals
       from participations p
       inner join countries c
       on c.countryid=p.countryid
       inner join olympicgames o
       on o.gameid=p.gameid
       where p.medal<>'na'
       group by o.year,c.countryname
),
ranking as(
select *,
rank()over(partition by year order by medals)as medalrank
from countrymedals 
),
topfive as(
select * from ranking where medalrank<=5
)
select countryname,
       count(*)as timestopfive
       from topfive 
       group by countryname
       order by timestopfive desc