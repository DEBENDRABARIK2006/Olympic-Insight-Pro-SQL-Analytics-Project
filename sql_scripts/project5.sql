select * from participations
select * from countries
select * from athletes
select * from sports
select * from olympicgames

/*
1: Athlete Experience Level:
Is an athlete a Rookie, Experienced, Veteran, or Legend based on Olympic appearances?
*/
create function fn_athlete_experience_level(@athleteid int)
returns varchar(50)
as
begin
    declare @attended int
    select @attended =count(*) 
    from participations 
    where athleteid=@athleteid
    group by gameid

    return (
    case 
       when @attended =1 then 'Rookie'
       when @attended between 2 and 3 then 'Experienced'
       when @attended between 4 and 5 then 'Veteran'
       else 'legend'
       end
    )
end

select athleteid , name ,dbo.fn_athlete_experience_level(athleteid) as experiencelevel
from athletes

/*
2: Olympic Host Legacy
What happened in a particular Olympic Games?
*/
create function fn_legacy(@year int)
returns table
as
return(
    select o.city,
    o.season,
    count(distinct p.athleteid)as total_athletes,
    count(distinct p.countryid) as total_countries,
    count(distinct p.sportid) as sports,
    count(medal) as total_medals
    from olympicgames o
    inner join participations p
    on o.gameid=p.gameid
    where o.year=@year and p.medal <> 'na'
    group by  o.city,
    o.season
)

select * from dbo.fn_legacy(2016)

/*
3: Sport Participation Map
Which countries have participated in a particular sport?
*/
create function fn_sportparticipationmap(@sportname varchar(50))
returns table
as
return (
     select c.countryname,
     min(o.year) as firstappearance,
     max(o.year) as latestappearance
     from participations p
     inner join countries c
     on p.countryid=c.countryid
     inner join olympicgames o
     on o.gameid=p.gameid
     inner join sports s
     on s.sportsid=p.sportid
     where s.sportsname=@sportname
     group by c.countryname
)

select * from fn_sportparticipationmap('hockey')
/*
4:complete athlete profile
*/
create function fn_GetAthleteProfile(@athletename NVARCHAR(200))
returns table
as
return
(
    select
        a.athleteid,
        a.name,
        a.sex,
        MAX(p.height) AS MaxHeight,
        MAX(p.weight) AS MaxWeight,
        MIN(p.age) AS YoungestAge,
        MAX(p.age) AS OldestAge,
        min(o.year) AS firstolympics,
        max(o.year) AS lastolympics,

        COUNT(DISTINCT o.gameid) AS olympicsparticipated,

        COUNT(DISTINCT p.sportid) AS sportsplayed,

        COUNT(DISTINCT p.eventname) AS eventsparticipated,

        SUM(CASE WHEN p.medal='gold' THEN 1 ELSE 0 END) AS gold,

        SUM(CASE WHEN p.medal='silver' THEN 1 ELSE 0 END) AS silver,

        SUM(CASE WHEN p.medal='bronze' THEN 1 ELSE 0 END) AS bronze,

        SUM(CASE
                WHEN p.medal IN ('gold','silver','bronze')
                THEN 1
                ELSE 0
            END) AS totalmedals

    FROM athletes a
    INNER JOIN participations p
        ON a.athleteid= p.athleteid
    INNER JOIN olympicgames o
        ON p.gameid = o.gameid

    WHERE a.Name LIKE '%' + @AthleteName + '%'

    GROUP BY
        a.athleteid,
        a.name,
        a.sex
)

select * from dbo.fn_GetAthleteProfile('Sindhu')
select * from dbo.fn_GetAthleteProfile('usha')

/*
5:Country vs Sport Summary
*/
create function fn_CountrySportSummary(@countryname varchar(100))
returns table 
as
return(
select s.sportsname,
count(distinct p.athleteid) as totalathletes,
count(distinct p.eventname) as totalevents,
sum(case when p.medal='gold' then 1 else 0 end) as gold,
sum(case when p.medal='silver' then 1 else 0 end) as silver,
sum(case when p.medal='bronze' then 1 else 0 end) as bronze,
sum(case when p.medal in('gold','silver','bronze') then 1 else 0 end) as totalmedals

from participations p
inner join sports s
on s.sportsid=p.sportid
inner join countries c
on c.countryid=p.countryid
where c.countryname =@countryname

group by s.sportsname
)

select * from dbo.fn_CountrySportSummary('india')
order by totalmedals desc