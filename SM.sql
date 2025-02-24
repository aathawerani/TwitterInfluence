/****** Script for SelectTopNRows command from SSMS  ******/


drop table #TopTwitter2
drop table Twitter9

create table #TopTwitter
(
	username varchar(200)
	)

insert into #TopTwitter (username)
  select Vertex from [SMtwitterDB].[dbo].[Vertices9]/*(
SELECT top 50 [Vertex]
      ,[PageRank]
	  ,(select count(*) from [SMtwitterDB].[dbo].[Edges9] E where E.Relationship = 'Mentions' and E.Tweet like '%RT%'
				and E.[Vertex 2] = V.[Vertex]) Retweets
  FROM [SMtwitterDB].[dbo].[Vertices9] V
  order by retweets desc
  ) temp*/

create table Twitter
(
	username varchar(200), mention int, retweet int, uniqueinteraction int, timeline varchar(20) 
	)

declare @username varchar(200)

declare @mintime datetime, @maxtime datetime, @timeinterval datetime
select @mintime = min([Relationship Date (UTC)]), @maxtime = max([Relationship Date (UTC)]) from [SMtwitterDB].[dbo].[Edges9]
--where [vertex 2] in (select username from #TopTwitter)


DECLARE twitteruser CURSOR FOR 
SELECT username from #TopTwitter

OPEN twitteruser

FETCH NEXT FROM twitteruser
INTO @username

WHILE @@FETCH_STATUS = 0
BEGIN


set @timeinterval = @mintime

while(@timeinterval < @maxtime)
begin

	insert into Twitter (username, timeline, mention, retweet, uniqueinteraction)
	select @username, @timeinterval,
			(select count(*) from [SMtwitterDB].[dbo].[Edges9] where Relationship = 'Mentions' and Tweet not like '%RT%'
					and [Vertex 2] = @username
					and datepart(dd, [Relationship Date (UTC)]) = datepart(dd, @timeinterval)
					and datepart(hh, [Relationship Date (UTC)]) = datepart(hh, @timeinterval)
					),
			(select count(*) from [SMtwitterDB].[dbo].[Edges9] where Relationship = 'Mentions' and Tweet like '%RT%'
					and [Vertex 2] = @username
					and datepart(dd, [Relationship Date (UTC)]) = datepart(dd, @timeinterval)
					and datepart(hh, [Relationship Date (UTC)]) = datepart(hh, @timeinterval)
					),
			(select count(*) from [SMtwitterDB].[dbo].[Edges9] where Relationship = 'Replies to' 
					and [Vertex 2] = @username
					and datepart(dd, [Relationship Date (UTC)]) = datepart(dd, @timeinterval)
					and datepart(hh, [Relationship Date (UTC)]) = datepart(hh, @timeinterval)
					)

	set @timeinterval = dateadd(hh, 1, @timeinterval) 

end

FETCH NEXT FROM twitteruser
INTO @username

END 
CLOSE twitteruser;
DEALLOCATE twitteruser;

select @mintime = min(timeline) from Twitter where retweet > 0 or mention > 0 or uniqueinteraction>0

--select * from Twitter where timeline >= @mintime

declare @mentioncount int, @uniqueinteractioncount int, @retweetcount1 int, @retweetcount2 int, @retweetcount3 int, @min int, @max int

select @min = min(mention), @max = max(mention) from Twitter
set @mentioncount = (@max - @min)/2
select @min = min(uniqueinteraction), @max = max(uniqueinteraction) from Twitter
set @uniqueinteractioncount = (@max - @min)/2
select @min = min(retweet), @max = max(retweet) from Twitter
set @retweetcount1 = (@max - @min)/4
set @retweetcount2 = @retweetcount1 * 2
set @retweetcount3 = @retweetcount1 * 3

--select @mentioncount, @uniqueinteractioncount, @retweetcount1, @retweetcount2, @retweetcount3

select username, timeline, (case when mention < @mentioncount then '0' else '1' end) mention,
		(case when uniqueinteraction < @uniqueinteractioncount then '0' else '1' end) uniqueinteraction,
		(case when retweet < @retweetcount1 then '0'
			else case when retweet > @retweetcount1 and retweet < @retweetcount2 then '1' 
				else case when retweet > @retweetcount2 and retweet < @retweetcount3 then '2' 
					else case when retweet > @retweetcount3 then '3' end end end end) retweet
from Twitter
where timeline >= @mintime



/*
select min([Relationship Date (UTC)]), max([Relationship Date (UTC)]) from [SMtwitterDB].[dbo].[Edges9]


SELECT [Vertex 1]
      ,[Vertex 2]
      ,(case when Relationship = 'Mentions' and Tweet like '%RT%' then 'Mentions' else
			case when Relationship = 'Mentions' and Tweet not like '%RT%' then 'Retweet' else
				case when Relationship = 'Replies to' and Tweet not like '%RT%' then 'UniqueInteraction'
					else  [Relationship]
				end 
			end 
		end) [Relationship]
      , cast(datepart(yy, [Relationship Date (UTC)]) as varchar(4)) 
			+ cast(datepart(MM, [Relationship Date (UTC)]) as varchar(2))
			+ cast(datepart(dd, [Relationship Date (UTC)]) as varchar(2))
			+ cast(datepart(hh, [Relationship Date (UTC)]) as varchar(2))
			 [Relationship Date (UTC)]
      ,[Tweet Date (UTC)]
  FROM [SMtwitterDB].[dbo].[Edges9]
  group by [Vertex 1], [Vertex 2], [Relationship], Tweet, [Relationship Date (UTC)], [Tweet Date (UTC)]


SELECT [Vertex 1]
      ,[Vertex 2]
      ,(case when Relationship = 'Mentions' and Tweet like '%RT%' then 'Mentions' else
			case when Relationship = 'Mentions' and Tweet not like '%RT%' then 'Retweet' else
				case when Relationship = 'Replies to' and Tweet not like '%RT%' then 'UniqueInteraction'
					else  [Relationship]
				end 
			end 
		end) [Relationship]
      , cast(datepart(yy, [Relationship Date (UTC)]) as varchar(4)) 
			+ cast(datepart(MM, [Relationship Date (UTC)]) as varchar(2))
			+ cast(datepart(dd, [Relationship Date (UTC)]) as varchar(2))
			+ cast(datepart(hh, [Relationship Date (UTC)]) as varchar(2))
			 [Relationship Date (UTC)]
      ,[Tweet Date (UTC)]
  FROM [SMtwitterDB].[dbo].[Edges9]
  where [Vertex 2] in (
  select Vertex from (
SELECT top 50 [Vertex]
      ,[PageRank]
	  ,(select count(*) from [SMtwitterDB].[dbo].[Edges9] E where E.Relationship = 'Mentions' and E.Tweet like '%RT%'
				and E.[Vertex 2] = V.[Vertex]) Retweets
	  ,(select count(*) from [SMtwitterDB].[dbo].[Edges9] E where E.Relationship = 'Mentions' and E.Tweet not like '%RT%'
				and E.[Vertex 2] = V.[Vertex]) Mentions
	  ,(select count(*) from [SMtwitterDB].[dbo].[Edges9] E where E.Relationship = 'Replies to' and E.Tweet not like '%RT%'
				and E.[Vertex 2] = V.[Vertex]) UniqueInteraction
  FROM [SMtwitterDB].[dbo].[Vertices9] V
  order by retweets desc
  ) temp
  )










SELECT top 50 [Vertex]
      ,[PageRank]
	  ,(select count(*) from [SMtwitterDB].[dbo].[Edges9] E where E.Relationship = 'Mentions' and E.Tweet like '%RT%'
				and E.[Vertex 2] = V.[Vertex]) Retweets
	  ,(select count(*) from [SMtwitterDB].[dbo].[Edges9] E where E.Relationship = 'Mentions' and E.Tweet not like '%RT%'
				and E.[Vertex 2] = V.[Vertex]) Mentions
	  ,(select count(*) from [SMtwitterDB].[dbo].[Edges9] E where E.Relationship = 'Replies to' and E.Tweet not like '%RT%'
				and E.[Vertex 2] = V.[Vertex]) UniqueInteraction
  FROM [SMtwitterDB].[dbo].[Vertices9] V
  order by retweets desc


SELECT [Vertex]
      ,[PageRank]
	  ,(select count(*) from [SMtwitterDB].[dbo].[Edges12] E where E.Relationship = 'Mentions' and E.Tweet like '%RT%'
				and E.[Vertex 2] = V2.[Vertex]) Retweets
	  ,(select count(*) from [SMtwitterDB].[dbo].[Edges12] E where E.Relationship = 'Mentions' and E.Tweet not like '%RT%'
				and E.[Vertex 2] = V2.[Vertex]) Mentions
	  ,(select count(*) from [SMtwitterDB].[dbo].[Edges12] E where E.Relationship = 'Replies to' and E.Tweet not like '%RT%'
				and E.[Vertex 2] = V2.[Vertex]) UniqueInteraction
  FROM (SELECT top 50 [Vertex]
      ,[PageRank]
	  ,(select count(*) from [SMtwitterDB].[dbo].[Edges9] E where E.Relationship = 'Mentions' and E.Tweet like '%RT%'
				and E.[Vertex 2] = V.[Vertex]) Retweets
	  ,(select count(*) from [SMtwitterDB].[dbo].[Edges9] E where E.Relationship = 'Mentions' and E.Tweet not like '%RT%'
				and E.[Vertex 2] = V.[Vertex]) Mentions
	  ,(select count(*) from [SMtwitterDB].[dbo].[Edges9] E where E.Relationship = 'Replies to' and E.Tweet not like '%RT%'
				and E.[Vertex 2] = V.[Vertex]) UniqueInteraction
  FROM [SMtwitterDB].[dbo].[Vertices9] V order by retweets desc) V2
  order by retweets desc



  */