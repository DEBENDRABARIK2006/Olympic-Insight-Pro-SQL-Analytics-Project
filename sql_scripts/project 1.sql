if db_id('OlympicInsightPro') is null
begin 
     create database OlympicInsightPro
     print 'database created successfully'
end 
else
begin 
     print 'database already exists.'
end
go

use OlympicInsightPro
go

SELECT COUNT(*) AS TotalRows
FROM athlete_events;

SELECT TOP 10 *
FROM athlete_events;

SELECT COUNT(*) AS TotalRows
FROM noc_regions;

SELECT TOP 10 *
FROM noc_regions;

--missing ages
select count(*) as total_missing_ages
from athlete_events
where age ='NA' or age =''

--Missing Heights
select count(*) as total_missing_height
from athlete_events
where height ='NA' or height =''

--Missing Weights
select count(*) as total_missing_weight
from athlete_events
where weight ='NA' or weight =''

--Medal Distribution
select medal,count(*) as total_medal
from athlete_events
where medal in ('gold','bronze','silver')
group by(medal)
order by total_medal desc


--create country table
create table countries(
countryid int identity(1,1),
NOC nvarchar(10) not null,
countryname nvarchar(50) not null,
constraint pk_countries primary key (countryid),
constraint uq_countries unique (NOC)
)
--load data
insert into countries(NOC,countryname)
select distinct NOC,region 
from noc_regions
where region <>'NA'
--verify
select * from countries

--Create Sports Table
create table sports(
sportsid int identity(1,1),
sportsname nvarchar (100) not null,
constraint pk_sports primary key(sportsid),
constraint uq_sports unique(sportsname)
)

insert into sports(sportsname)
select distinct sport
from athlete_events
order by sport

select * from sports

--create olympic games table
create table olympicgames(
gameid int identity(1,1),
[year] int not null,
season nvarchar(50) not null,
city varchar(50) not null

constraint pk_olympicgames primary key(gameid)
)

insert into olympicgames ([year],season,city)
select distinct [year],season,city from athlete_events
order by [year] 

select * from olympicgames

--create athletes table
create table athletes (
athleteid int primary key,
name nvarchar(250) not null,
sex nvarchar(1) not null
)

insert into athletes(athleteid,name,sex)
select id,max(name),max(sex) from athlete_events group by id

select * from athletes

--create participatiopn table
create table participations(
participationid bigint identity(1,1),
athleteid int not null,
countryid int not null,
sportid int not null,
gameid int not null,
age int ,
height int,
weight int,
eventname nvarchar(100) not null,
medal nvarchar(100)

    CONSTRAINT PK_Participations
        PRIMARY KEY(participationid),

    CONSTRAINT FK_Participation_Athlete
        FOREIGN KEY(athleteid)
        REFERENCES athletes(athleteid),

    CONSTRAINT FK_Participation_Country
        FOREIGN KEY(countryid)
        REFERENCES countries(countryid),

    CONSTRAINT FK_Participation_Sport
        FOREIGN KEY(sportid)
        REFERENCES sports(sportsid),

    CONSTRAINT FK_Participation_Game
        FOREIGN KEY(gameid)
        REFERENCES olympicgames(gameid)
)

insert into participations(
athleteid ,
countryid ,
sportid ,
gameid ,
age  ,
height ,
weight ,
eventname ,
medal 
) 
select ae.id,
       c.countryid,
       s.sportsid,
       g.gameid ,
       TRY_CAST(ae.age AS INT),
       TRY_CAST(ae.height AS INT),
       TRY_CAST(ae.weight AS INT),
       ae.event,
       ae.medal
from athlete_events ae
inner join countries c on ae.noc=c.noc
inner join sports s on ae.sport=s.sportsname
inner join olympicgames g on ae.[year]=g.[year] and ae.Season=g.season and ae.city=g.city

select * from participations


--since the table is large
CREATE NONCLUSTERED INDEX IX_Country
ON participations(countryid);

CREATE NONCLUSTERED INDEX IX_Sport
ON participations(sportid);

CREATE NONCLUSTERED INDEX IX_Game
ON participations(gameid);

CREATE NONCLUSTERED INDEX IX_Medal
ON participations(Medal);

CREATE NONCLUSTERED INDEX IX_Participations_AthleteID
ON participations(athleteid);