/*select count(*) from Twitter5

select username, sum(mention) summention, sum(retweet) sumretweet, sum(uniqueinteraction) sumuniqueinteraction from Twitter5
group by username order by sumretweet desc, summention desc, sumuniqueinteraction desc

--insert into Twitter9 (username, timeline, mention, retweet, uniqueinteraction)
select username, timeline, mention, retweet, uniqueinteraction from Twitter5
where retweet>0 or mention > 0 or uniqueinteraction > 0
*/

/*declare @mintime datetime
select @mintime = min(timeline) from Twitter9 where retweet > 0 or mention > 0 or uniqueinteraction>0
--select @mintime

declare @mentioncount int, @uniqueinteractioncount int, @retweetcount1 int, @retweetcount2 int, @retweetcount3 int, @min int, @max int

select @min = min(mention), @max = max(mention) from Twitter9
set @mentioncount = (@max - @min)/2
select @min = min(uniqueinteraction), @max = max(uniqueinteraction) from Twitter9
set @uniqueinteractioncount = (@max - @min)/2
select @min = min(retweet), @max = max(retweet) from Twitter9
set @retweetcount1 = (@max - @min)/4
set @retweetcount2 = @retweetcount1 * 2
set @retweetcount3 = @retweetcount1 * 3

select username, timeline, (case when mention < @mentioncount then '0' else '1' end) mention,
		(case when uniqueinteraction < @uniqueinteractioncount then '0' else '1' end) uniqueinteraction,
		(case when retweet < @retweetcount1 then '0'
			else case when retweet > @retweetcount1 and retweet < @retweetcount2 then '1' 
				else case when retweet > @retweetcount2 and retweet < @retweetcount3 then '2' 
					else case when retweet > @retweetcount3 then '3' end end end end) retweet
from Twitter9
where retweet>0 or mention > 0 or uniqueinteraction > 0
*/

/*
drop table Twitter9
create table Twitter9 (username varchar(200), mention int, retweet int, uniqueinteraction int, timeline varchar(20))
insert into Twitter9 (username, timeline, mention, retweet, uniqueinteraction)
select username, timeline, mention, retweet, uniqueinteraction from Twitter5 where username in (
select username/*, sum(mention) summention, sum(retweet) sumretweet, sum(uniqueinteraction) sumuniqueinteraction*/ from Twitter5
group by username having sum(mention) > 30 or sum(retweet) > 30 or sum(uniqueinteraction) > 30
--order by sumretweet desc, summention desc, sumuniqueinteraction desc
) 

select username, sum(mention) summention, sum(retweet) sumretweet, sum(uniqueinteraction) sumuniqueinteraction from Twitter9
group by username having sum(mention) > 30 or sum(retweet) > 30 or sum(uniqueinteraction) > 30
order by sumretweet desc

declare @mentioncount int, @uniqueinteractioncount int, @retweetcount1 int, @retweetcount2 int, @retweetcount3 int, @min int, @max int
select @min = min(mention), @max = max(mention) from Twitter9
set @mentioncount = (@max - @min)/2
select @min = min(uniqueinteraction), @max = max(uniqueinteraction) from Twitter9
set @uniqueinteractioncount = (@max - @min)/2
select @min = min(retweet), @max = max(retweet) from Twitter9
set @retweetcount1 = (@max - @min)/4
set @retweetcount2 = @retweetcount1 * 2
set @retweetcount3 = @retweetcount1 * 3

select @mentioncount, @uniqueinteractioncount, @retweetcount1, @retweetcount2, @retweetcount3

select min(mention), max(mention), min(retweet), max(retweet), min(uniqueinteraction), max(uniqueinteraction) from Twitter9

select username, timeline, (case when mention < @mentioncount then '0' else '1' end) mention,
		(case when uniqueinteraction < @uniqueinteractioncount then '0' else '1' end) uniqueinteraction,
		(case when retweet < @retweetcount1 then '0'
			else case when retweet > @retweetcount1 and retweet < @retweetcount2 then '1' 
				else case when retweet > @retweetcount2 and retweet < @retweetcount3 then '2' 
					else case when retweet > @retweetcount3 then '3' end end end end) retweet
from Twitter9

select @retweetcount3 = min(retweet) from (
select top 18 username from Twitter9 order by retweet desc
) temp

select @retweetcount2 = min(retweet) from (
select top 36 retweet from Twitter9 order by retweet desc
) temp

select @retweetcount1 = min(retweet) from (
select top 54 retweet from Twitter9 order by retweet desc
) temp

select @mentioncount = min(mention) from (
select top 36 mention from Twitter9 order by mention desc
) temp

select @uniqueinteractioncount = min(uniqueinteraction) from (
select top 36 uniqueinteraction from Twitter9 order by uniqueinteraction desc
) temp
*/

declare @mentioncount int, @uniqueinteractioncount int, @retweetcount1 int, @retweetcount2 int, @retweetcount3 int, @min int, @max int

declare @username varchar(200)

select top 1 @username = username from (
select top 18 username, sum(retweet) sumretweet from Twitter9 group by username order by sum(retweet) desc) temp
order by sumretweet
--select @username
--select top 18 username, sum(retweet) sumretweet from Twitter9 group by username order by sum(retweet) desc
select @retweetcount3 = max(retweet) from Twitter9 where username = @username

select top 1 @username = username from (
select top 36 username, sum(retweet) sumretweet from Twitter9 group by username order by sum(retweet) desc) temp
order by sumretweet
--select @username
--select top 36 username, sum(retweet) sumretweet from Twitter9 group by username order by sum(retweet) desc
select @retweetcount2 = max(retweet) from Twitter9 where username = @username

select top 1 @username = username from (
select top 54 username, sum(retweet) sumretweet from Twitter9 group by username order by sum(retweet) desc) temp
order by sumretweet
--select @username
--select top 54 username, sum(retweet) sumretweet from Twitter9 group by username order by sum(retweet) desc
select @retweetcount1 = max(retweet) from Twitter9 where username = @username

select top 1 @username = username from (
select top 36 username, sum(mention) summention from Twitter9 group by username order by sum(mention) desc) temp
order by summention
--select @username
--select top 36 username, sum(mention) summention from Twitter9 group by username order by sum(mention) desc
select @mentioncount = max(mention) from Twitter9 where username = @username

select top 1 @username = username from (
select top 36 username, sum(uniqueinteraction) sumuniqueinteraction from Twitter9 group by username order by sum(uniqueinteraction) desc
) temp
order by sumuniqueinteraction
--select @username
--select top 36 username, sum(uniqueinteraction) sumuniqueinteraction from Twitter9 group by username order by sum(uniqueinteraction) desc
select @uniqueinteractioncount = max(uniqueinteraction) from Twitter9 where username = @username

/*select @mentioncount, @uniqueinteractioncount, @retweetcount1, @retweetcount2, @retweetcount3

select @min = min(mention), @max = max(mention) from Twitter9
set @mentioncount = (@max - @min)/2
select @min = min(uniqueinteraction), @max = max(uniqueinteraction) from Twitter9
set @uniqueinteractioncount = (@max - @min)/2
select @min = min(retweet), @max = max(retweet) from Twitter9
set @retweetcount1 = (@max - @min)/4
set @retweetcount2 = @retweetcount1 * 2
set @retweetcount3 = @retweetcount1 * 3

select @mentioncount, @uniqueinteractioncount, @retweetcount1, @retweetcount2, @retweetcount3
*/

/*
select @min = min(mention), @max = max(mention) from Twitter9
set @mentioncount = (@max - @min)/2
select @min = min(uniqueinteraction), @max = max(uniqueinteraction) from Twitter9
set @uniqueinteractioncount = (@max - @min)/2
select @min = min(retweet), @max = max(retweet) from Twitter9
set @retweetcount1 = (@max - @min)/4
set @retweetcount2 = @retweetcount1 * 2
set @retweetcount3 = @retweetcount1 * 3

select @mentioncount, @uniqueinteractioncount, @retweetcount1, @retweetcount2, @retweetcount3
*/

--select * from Twitter9 where mention > @mentioncount



select username, timeline, mentionlevel, uniqueinteractionlevel, retweetlevel from (
select username, timeline, (case when mention < @mentioncount then '0' else '1' end) mentionlevel,
		(case when uniqueinteraction < @uniqueinteractioncount then '0' else '1' end) uniqueinteractionlevel,
		(case when retweet < @retweetcount1 then '0'
			else case when retweet >= @retweetcount1 and retweet < @retweetcount2 then '1' 
				else case when retweet >= @retweetcount2 and retweet < @retweetcount3 then '2' 
					else case when retweet >= @retweetcount3 then '3' end end end end) retweetlevel
from Twitter9
) temp
where mentionlevel > 0 or uniqueinteractionlevel > 0 or retweetlevel > 0
order by username, timeline

--select username, sum(mention), sum(retweet), sum(uniqueinteraction) from twitter12 group by username
--order by sum(retweet) desc


