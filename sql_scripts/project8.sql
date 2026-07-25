select * from participations
select * from countries
select * from athletes
select * from sports
select * from olympicgames
/*
Report 1 : Olympic Medal Drill-down Report
Drill down medals from Country → Sport → Event
*/

select 
     case 
         when grouping(c.countryname)=1 then 'All Countries'
         else c.countryname
     end as country,
     case 
         when grouping(s.sportsname)=1 then 'All sports'
         else s.sportsname 
      end as sport,
      case
          when grouping(p.eventname)=1 then 'All Events'
          else p.eventname
      end as event,
      count(*) as totalmedals 
      from participations p
      inner join countries c
      on c.countryid=p.countryid
      inner join sports s
      on s.sportsid=p.sportid
      where p.medal<>'na'
      group by 
      rollup(
      c.countryname,
      s.sportsname,
      p.eventname
      )

      /*
      Report 2 : Olympic Medal Cube (CUBE)
      Produce every possible medal summary.
      */
    
select 
     case 
         when grouping(c.countryname)=1 then 'All Countries'
         else c.countryname
     end as country,
     case 
         when grouping(s.sportsname)=1 then 'All sports'
         else s.sportsname 
      end as sport,
      case
          when grouping(p.eventname)=1 then 'All Events'
          else p.eventname
      end as event,
      count(*) as totalmedals 
      from participations p
      inner join countries c
      on c.countryid=p.countryid
      inner join sports s
      on s.sportsid=p.sportid
      where p.medal<>'na'
      group by 
      cube(
      c.countryname,
      s.sportsname,
      p.eventname
      )


/*
Report 4 : Smart Executive Totals (GROUPING_ID)
Identify aggregation level.
*/
select 
     case 
         when grouping(c.countryname)=1 then 'All Countries'
         else c.countryname
     end as country,
     case 
         when grouping(s.sportsname)=1 then 'All sports'
         else s.sportsname 
      end as sport,
      count(*) as totalmedals ,
      grouping_id(
      c.countryname,
      s.sportsname
      )as reportlevel
      from participations p
      inner join countries c
      on c.countryid=p.countryid
      inner join sports s
      on s.sportsid=p.sportid
      where p.medal<>'na'
      group by 
      rollup(
      c.countryname,
      s.sportsname
      )
      order by reportlevel,country