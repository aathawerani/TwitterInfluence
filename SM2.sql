drop table #TopTwitter1
drop table Twitter5

create table #TopTwitter1
(
	username varchar(200)
	)

insert into #TopTwitter1 (username)
select distinct [Vertex 2] from [SMtwitterDB].[dbo].[Edges14]
/*  select Vertex from [SMtwitterDB].[dbo].[Vertices14]*/
/*(
SELECT top 50 [Vertex]
      ,[PageRank]
	  ,(select count(*) from [SMtwitterDB].[dbo].[Edges12] E where E.Relationship = 'Mentions' and E.Tweet like '%RT%'
				and E.[Vertex 1] = V.[Vertex]) Retweets
  FROM [SMtwitterDB].[dbo].[Vertices12] V
  order by retweets desc
  ) temp*/

create table Twitter5
(
	username varchar(200), mention int, retweet int, uniqueinteraction int, timeline varchar(20) 
	)

declare @username varchar(200)

declare @mintime datetime, @maxtime datetime, @timeinterval datetime
select @mintime = min([Relationship Date (UTC)]), @maxtime = max([Relationship Date (UTC)]) from [SMtwitterDB].[dbo].[Edges14]
--select @mintime, @maxtime
--where [vertex 2] in (select username from #TopTwitter)

DECLARE twitteruser CURSOR FOR 
SELECT username from #TopTwitter1

OPEN twitteruser

FETCH NEXT FROM twitteruser
INTO @username

WHILE @@FETCH_STATUS = 0
BEGIN


set @timeinterval = @mintime

while(datepart(YYYY, @timeinterval) <= datepart(YYYY, @maxtime) and datepart(MM, @timeinterval) <= datepart(MM, @maxtime))
begin

	insert into Twitter5 (username, timeline, mention, retweet, uniqueinteraction)
	select @username, @timeinterval,
			(select count(*) from [SMtwitterDB].[dbo].[Edges14] where Relationship = 'Mentions' and Tweet not like '%RT%'
					and [Vertex 2] = @username
					and datepart(YYYY, [Relationship Date (UTC)]) = datepart(YYYY, @timeinterval)
					and datepart(MM, [Relationship Date (UTC)]) = datepart(MM, @timeinterval)
					),
			(select count(*) from [SMtwitterDB].[dbo].[Edges14] where Relationship = 'Mentions' and Tweet like '%RT%'
					and [Vertex 2] = @username
					and datepart(YYYY, [Relationship Date (UTC)]) = datepart(YYYY, @timeinterval)
					and datepart(MM, [Relationship Date (UTC)]) = datepart(MM, @timeinterval)
					),
			(select count(*) from [SMtwitterDB].[dbo].[Edges14] where Relationship = 'Replies to' 
					and [Vertex 2] = @username
					and datepart(YYYY, [Relationship Date (UTC)]) = datepart(YYYY, @timeinterval)
					and datepart(MM, [Relationship Date (UTC)]) = datepart(MM, @timeinterval)
					)

	set @timeinterval = dateadd(MM, 1, @timeinterval) 

end

FETCH NEXT FROM twitteruser
INTO @username

END 
CLOSE twitteruser;
DEALLOCATE twitteruser;


/*select @mintime = min(timeline) from Twitter5 where retweet > 0 or mention > 0 or uniqueinteraction>0


declare @mentioncount int, @uniqueinteractioncount int, @retweetcount1 int, @retweetcount2 int, @retweetcount3 int, @min int, @max int

select @min = min(mention), @max = max(mention) from Twitter5
set @mentioncount = (@max - @min)/2
select @min = min(uniqueinteraction), @max = max(uniqueinteraction) from Twitter5
set @uniqueinteractioncount = (@max - @min)/2
select @min = min(retweet), @max = max(retweet) from Twitter5
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
from Twitter5
where timeline >= @mintime
*/