select * from participations
select * from countries
select * from athletes
select * from sports
select * from olympicgames
--Report 1: Complete Medal Table
select c.countryname,
       sum(case when p.medal='gold' then 1 else 0 end) as Gold,
       sum(case when p.medal='silver' then 1 else 0 end) as Silver,
       sum(case when p.medal='bronze' then 1 else 0 end) as Bronze,
       count(*) as totalmedals
from participations p
inner join countries c
on c.countryid=p.countryid
where p.medal<>'na'
group by c.countryname
order by totalmedals desc

--Report 2: Top Athlete of Each Country
with athletemedal as(
select c.countryname,
       a.name,
       count(*) as totalmedal,
       DENSE_RANK()over(partition by c.countryname order by count(*) desc) as rnk
       from participations p
       inner join athletes a
       on a.athleteid=p.athleteid
       inner join countries c
       on c.countryid=p.countryid
       where p.medal <> 'na'
       group by c.countryname,a.name
)
select * from athletemedal where rnk=1
order by totalmedal desc

--Report 3: Most Dominant Country in Each Sport
with sportranking as (
select c.countryname,
       s.sportsname,
       count(*) as totalmedal,
       dense_rank()over(partition by s.sportsname order by count(*) desc) as rnk
       from participations p
       inner join countries c
       on c.countryid=p.countryid
       inner join sports s
       on p.sportid=s.sportsid
       where p.medal<>'na'
       group by c.countryname , s.sportsname
     
)
select * from sportranking where rnk=1
order by totalmedal desc

--Report 4: Olympic Growth Trend
select o.year,
       count(*) as participationcount
       from participations p
       inner join olympicgames o
       on p.gameid=o.gameid
       group by o.year
       order by o.year

--Report 5: Medal Growth by Country
select o.year,
       c.countryname,
       count(*) as totalmedal
       from participations p
       inner join olympicgames o
       on p.gameid=o.gameid
       inner join countries c
       on c.countryid=p.countryid
       
       
--Report 6: Athlete Career Timeline
select a.name,
       s.sportsname,
       o.year,
       p.medal,
       row_number()over(partition by a.name order by o.year) as careerorder
from participations p
inner join athletes a
on p.athleteid=a.athleteid
inner join sports s
on s.sportsid=p.sportid
inner join olympicgames o
on o.gameid=p.gameid
order by a.name

--Report 7: Medal Efficiency(Countries with best Gold/Total ratio)
select 
  c.countryname,
  count(case when p.medal='gold' then 1 end)*100.0/
  count(*) as goldpercentage
from participations p
inner join countries c
on c.countryid=p.countryid
where p.medal<>'na'
group by c.countryname
order by goldpercentage desc

--Report 8: Youngest Gold Medalists
select
     a.name,
     p.age,
     c.countryname,
     p.eventname
from participations p
inner join countries c
on c.countryid=p.countryid
inner join athletes a
on a.athleteid=p.athleteid
where p.medal='gold'
and p.age is not null
and p.age<=23
order by p.age 

--Report 9: Most Competitive Sports
select s.sportsname,
       count(distinct c.countryname) as medalwinningcountries
from  participations p
inner join countries c
on c.countryid=p.countryid
inner join sports s
on s.sportsid=p.sportid
where p.medal <> 'na'
group by s.sportsname
order by medalwinningcountries desc

--Analytics Report 10: Olympic Power Score(Gold=7, Silver=4, Bronze=1)
select c.countryname,
       sum(case when p.medal='gold' then 7 
                when p.medal='silver' then 4
                when p.medal='bronze' then 1
                else 0
            end
        )as powerscore
from participations p
inner join countries c
on c.countryid=p.countryid
group by countryname
order by powerscore desc
