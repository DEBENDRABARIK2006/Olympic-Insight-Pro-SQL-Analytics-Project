select * from participations
select * from countries
select * from athletes
select * from sports
select * from olympicgames

/*
View 1: Athlete Career Summary
*/
create view vw_athleteCareerSummery
as
select
     p.athleteid,
     a.name,
     a.sex,
     min(o.year) as firstolympics,
     max(o.year) as lastolympic,
     count(distinct o.year) as participated
from participations p
inner join athletes a
on a.athleteid=p.athleteid
inner join olympicgames o
on o.gameid=p.gameid
group by p.athleteid,a.name,a.sex


select * from vw_athleteCareerSummery
order by participated desc

/*
View 2: Country Participation Summary
How active each nation is.
*/
create view vw__CountryParticipationSummary
as
select 
     c.countryname,
     count(distinct p.athleteid) as totalathletes,
     count(distinct p.sportid) as sportsplayed,
     count(distinct p.gameid) as olympicsparticipated
from participations p
inner join countries c
on c.countryid=p.countryid
group by countryname

select * from vw__CountryParticipationSummary

/*
View 3: Sport Popularity
Most globally played sports.
*/
alter view vw_SportPopularity
as
select s.sportsid,
s.sportsname,
count(distinct p.athleteid)as athletecount,
count(distinct p.countryid) as countrycount,
count(*) as totalparticipations
from participations p
inner join sports s
on s.sportsid=p.sportid
group by s.sportsid,
s.sportsname 

select * from vw_SportPopularity

--View 4: Olympic Games Summary
create view vw_OlympicGamesSummary
as
select
     o.gameid,
     o.year,
     o.season,
     o.city,
     count(distinct p.athleteid)as athletecount,
     count(distinct p.countryid) as countrycount,
     count(distinct p.sportid) as sportcount
     from participations p
     inner join olympicgames o
     on p.gameid=o.gameid
group by 
     o.gameid,
     o.year,
     o.season,
     o.city

select *from vw_OlympicGamesSummary

--View 5: Multi-Medal Athletes
alter VIEW vw_MultiMedalAthletes
as
select 
     a.athleteid,
     a.name,
     count(*)as medalcount
from participations p
inner join athletes a
on a.athleteid=p.athleteid
where p.medal<>'na'
group by a.athleteid,
         a.name
having count(*)>5

select * from vw_MultiMedalAthletes

--View 6: Country-Sport Coverage
create view vw_CountrySportCoverage
as
select c.countryname,
       count(distinct p.sportid) as sportsrepresented
from participations p
inner join countries c
on c.countryid=p.countryid
group by c.countryname

select * from vw_CountrySportCoverage order by sportsrepresented desc 