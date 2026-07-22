select * from participations
select * from countries
select * from athletes
select * from sports
select * from olympicgames

/*
Procedure 1: Olympic Rivalries
Which countries frequently compete against each other in the same sport?
*/
alter procedure sp_olympicrivalries 
@sportname varchar(100)
as
begin
    select c1.countryname,
           c2.countryname,
           count(*) as rivalrycount
           from participations p1
           inner join participations p2
           on p1.sportid=p2.sportid
           and p1.gameid=p2.gameid
           and p1.countryid<p2.countryid

           inner join countries c1
           on c1.countryid=p1.countryid

           inner join countries c2
           on c2.countryid=p2.countryid

           inner join sports s
           on s.sportsid=p1.sportid

           where s.sportsname=@sportname
           group by c1.countryname, c2.countryname
           order by rivalrycount desc;
end

exec sp_olympicrivalries 'hockey'

/*
Procedure 2: Hidden Olympic Specialists
Countries winning medals in very few sports.
*/
create procedure sp_specialistcountries
as
begin
     select c.countryname,
     count(distinct p.sportid) as sportswon
     from participations p
     inner join countries c
     on c.countryid=p.countryid
     where p.medal<>'na'
     group by c.countryname
     order by sportswon
end
exec sp_specialistcountries

/*
Procedure 3: Olympic Breakthrough Nations
Which countries achieved their best-ever Olympic performance in a given year?
*/
alter procedure sp_breakthroughnations
as
begin
     with countryyearmedals as
     (
     select c.countryname,
            o.year,
            count(*) as totalmedals
            from participations p
            inner join countries c
            on p.countryid=c.countryid
            inner join olympicgames o
            on o.gameid=p.gameid
            where p.medal<>'na'
            group by c.countryname,o.year
     )
     select countryname,year,bestever from (
     select *,max(totalmedals) over(partition by countryname) as bestever
     from countryyearmedals
     ) x
     where bestever=totalmedals
     order by bestever desc
     
end

exec sp_breakthroughnations

/*
Procedure 4: Forgotten Sports
Which sports disappeared from the Olympics?
*/
create procedure sp_forgottensports
as
begin
    select s.sportsname,
    min(o.year) as firstappearance,
    max(o.year) as lastapperance
    from participations p
    inner join sports s
    on s.sportsid=p.sportid
    inner join olympicgames o
    on o.gameid=p.gameid
    group by s.sportsname
    having max(o.year)<2016
end

exec sp_forgottensports

/*
Procedure 5: Olympic Expansion Report
Which sports gained the most participating countries over time?
*/
create procedure sp_sportsexpansion
as
begin
    select
    s.sportsname,
    count(distinct p.countryid) as totalcountries
    from participations p
    inner join sports s
    on s.sportsid=p.sportid
    group by s.sportsname
    order by totalcountries desc
end

exec sp_sportsexpansion