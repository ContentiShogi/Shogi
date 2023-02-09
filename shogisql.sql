DECLARE @kyokumen table (mover bit,koma smallint, position smallint)
INSERT INTO @kyokumen select mover,koma,position from f_parseSFEN(N'ln5nl/2G2R+P2/kp2+S3p/p1Pp3p1/9/P1sB4P/1P1P1+p3/2KS5/LN2r1PNL w BGS2P2g3p 92')
DECLARE @kyokumen2 table (number smallint,position smallint,koma smallint, mover bit,sfen nvarchar(10))
insert into @kyokumen2
SELECT number,position,kyokumen.koma,mover
,case mover when 1 then koma.sfen_gote when 0 then koma.sfen_sente end sfen
FROM (select number,1 i from master..spt_values where type='P'and number between 11 and 99)squares
left join @kyokumen kyokumen on squares.number=kyokumen.position
left join koma on koma.koma_id=kyokumen.koma
group by position,kyokumen.koma,mover,koma.sfen_gote,koma.sfen_sente,number
order by number
select a.*,b.* from @kyokumen a
left join @kyokumen b on a.position/100=b.position/100 and a.position%10<b.position%10 and a.position/10<b.position
order by a.position/100 desc,a.position%10,a.position/10 desc
--select /*row_number()over(order by a.number)rn,*/isnull(a.position,midnumber),a.koma,a.mover,isnull(a.sfen,count(*)) sfen 
--from @kyokumen2 a 
--cross apply 
--	(select max(number) midnumber,count(*)midcount
--	from @kyokumen2 b where a.position is null and b.position is not null and b.number<a.number)bb
--	group by isnull(a.position,midnumber),a.koma,a.mover,a.sfen
--	order by isnull(a.position,midnumber)%10,isnull(a.position,midnumber)/10 desc,1,2,3,4

--select /*row_number()over(order by a.number)rn,*/isnull(a.position,midnumber)num,a.koma,a.mover,a.sfen
--from @kyokumen2 a 
--cross apply 
--	(select max(number)+1 midnumber,count(*)midcount
--	from @kyokumen2 b where a.position is null and b.position is not null and b.number<a.number)bb
--	order by a.number

/*--select * from f_parseSFEN(N'9/3k5/9/9/9/4K4/9/9/9 w L2r2b4g4s4n3l18p 4')
ALTER FUNCTION f_parseSFEN (@sfen nvarchar(100)='')
returns @kyokumen table (sfenchar nvarchar(5),mover bit,koma smallint, position smallint)
as
begin 
Declare @sfenchar nvarchar(10)='',@dan int = 1,@suji int =9,@skip bit=0,@move_number int =null,@turn bit;

set @sfen = ltrim(rtrim(@sfen))
	while not(@dan>=9 and @suji<=1 and @move_number is not null and @sfen='')
	begin
		--select 'debug',@skip skips,@sfenchar sfenchar,case left(@sfen,1) when '+' then left(@sfen,2) when ' ' then left(@sfen,3) else left(@sfen,1)end nextsfen,@suji suji,@dan dan,@sfen
		select @sfenchar = case left(@sfen,1) when '+' then left(@sfen,2) when ' ' then left(@sfen,3) else left(@sfen,1)end
		if(@skip=0)
			begin
				if (@sfenchar like' _ ')begin set @skip=1/*;set @suji=@suji-1;*/end 
				else if (@sfenchar='/')begin set @suji=9; set @dan=@dan+1;end 
				else if (@sfenchar like'[1-9]') begin set @suji=@suji-convert(int,@sfenchar);end
				else
					begin
					insert into @kyokumen
					select @sfenchar
						, case when sfen_sente = @sfenchar then 0 when sfen_gote = @sfenchar then 1 end mover
						, koma.koma_id
						, @suji*10+@dan position
					from koma where @sfenchar in (sfen_sente,sfen_gote)
					set @suji=@suji-1
					end
			end
		if(@skip = 1)
			begin
				--select 'debug',@move_number,@skip skips,@sfenchar sfenchar,@suji suji,@dan dan,@sfen ,1
				if (@sfenchar like ' _ ') 
					begin set @turn= case @sfenchar when ' b ' then 0 when ' w ' then 1 end 
					end
				else if (@sfenchar like ' [0-9]' or @sfenchar like ' [0-9][0-9]' or @sfenchar like ' [0-9][0-9][0-9]' ) 
					begin set @sfenchar = @sfen ;
					--select 'debug',@move_number,@skip skips,@sfenchar sfenchar,@suji suji,@dan dan,@sfen ,2
					set @move_number=convert(int,ltrim(rtrim(@sfen)))
					end
				else begin
					if (@sfenchar like'[1-9]')
						begin set @sfenchar=left(@sfen,2) 
						if (@sfenchar like'1[1-9]') set @sfenchar=left(@sfen,3)
						end
					--select 'debug',@move_number,@skip skips,@sfenchar sfenchar,@suji suji,@dan dan,@sfen ,3
					insert into @kyokumen
					select @sfenchar
						, case when sfen_sente = right(@sfenchar,1) then 0 when sfen_gote = right(@sfenchar,1) then 1 end mover
						, koma.koma_id
						, 100
							+ case when @sfenchar like'[1-9]%' then convert(int,substring(replace(@sfenchar,' ','0'),1,len(replace(@sfenchar,' ','|'))-1))
								else 1 end
					from koma where right(@sfenchar,1) in (sfen_sente,sfen_gote)
					end
			end
		set @sfen=right(@sfen,len(@sfen)-len(replace(@sfenchar,' ','|')))
	end
	return;
end*/
--select * from koma where koma_id not in (select distinct koma from moves)
--select mover,koma,position,moves  from moves group by mover,koma,position,moves having count(*)>1
----HI
--insert into moves
--select convert(bit,0) mover,3 koma,position.masume position,moves.masume moves
--from banmen position
--join banmen moves on (moves.suji=position.suji or moves.dan=position.dan) and moves.masume!=position.masume
--union select 1 mover,3 koma,position.masume position,moves.masume moves
--from banmen position
--join banmen moves on (moves.suji=position.suji or moves.dan=position.dan) and moves.masume!=position.masume
----KAKU
--insert into moves
--select 0 mover,4 koma,position.masume position,moves.masume moves
--from banmen position
--join banmen moves on (moves.kakuparallel=position.kakuparallel or moves.kakuorthogonal=position.kakuorthogonal) and moves.masume!=position.masume
--union select 1 mover,4 koma,position.masume position,moves.masume moves
--from banmen position
--join banmen moves on (moves.kakuparallel=position.kakuparallel or moves.kakuorthogonal=position.kakuorthogonal) and moves.masume!=position.masume
----OO
--insert into moves
--select 0 mover,1 koma,position.masume position,moves.masume moves
--from banmen position
--join banmen moves on (abs(moves.suji-position.suji)<=1 and abs(moves.dan-position.dan)<=1)	and moves.masume!=position.masume
--union select 1 mover,1 koma,position.masume position,moves.masume moves
--from banmen position
--join banmen moves on (abs(moves.suji-position.suji)<=1 and abs(moves.dan-position.dan)<=1)	and moves.masume!=position.masume
----GYOKU
--insert into moves
--select 0 mover,2 koma,position.masume position,moves.masume moves
--from banmen position
--join banmen moves on (abs(moves.suji-position.suji)<=1 and abs(moves.dan-position.dan)<=1)	and moves.masume!=position.masume
--union select 1 mover,2 koma,position.masume position,moves.masume moves
--from banmen position
--join banmen moves on (abs(moves.suji-position.suji)<=1 and abs(moves.dan-position.dan)<=1)	and moves.masume!=position.masume
----RYUUOU
--insert into moves
--select 0 mover,10 koma,position.masume position,moves.masume moves
--from banmen position
--join banmen moves on ((abs(moves.suji-position.suji)<=1 and abs(moves.dan-position.dan)<=1) or (moves.suji=position.suji or moves.dan=position.dan) )
--						and moves.masume!=position.masume
--union select 1 mover,10 koma,position.masume position,moves.masume moves
--from banmen position
--join banmen moves on ((abs(moves.suji-position.suji)<=1 and abs(moves.dan-position.dan)<=1) or (moves.suji=position.suji or moves.dan=position.dan) )
--						and moves.masume!=position.masume
----UMA
--insert into moves
--select 0 mover,11 koma,position.masume position,moves.masume moves
--from banmen position
--join banmen moves on ((abs(moves.suji-position.suji)<=1 and abs(moves.dan-position.dan)<=1) or (moves.kakuparallel=position.kakuparallel or moves.kakuorthogonal=position.kakuorthogonal) )
--						and moves.masume!=position.masume
--union select 1 mover,11 koma,position.masume position,moves.masume moves
--from banmen position
--join banmen moves on ((abs(moves.suji-position.suji)<=1 and abs(moves.dan-position.dan)<=1) or (moves.kakuparallel=position.kakuparallel or moves.kakuorthogonal=position.kakuorthogonal) )
--						and moves.masume!=position.masume
----GIN
--insert into moves
--select 0 mover,6 koma,position.masume position,moves.masume moves
--from banmen position
--join banmen moves on (abs(moves.suji-position.suji)<=1 and abs(moves.dan-position.dan)=1) and moves.masume!=position.masume
--and not (moves.suji=position.suji and moves.dan=position.dan+1)
--union 
--select 1 mover,6 koma,position.masume position,moves.masume moves
--from banmen position
--join banmen moves on (abs(moves.suji-position.suji)<=1 and abs(moves.dan-position.dan)=1) and moves.masume!=position.masume
--and not (moves.suji=position.suji and moves.dan=position.dan-1)order by position
----KIN
--insert into moves
--select 0 mover,5 koma,position.masume position,moves.masume moves
--from banmen position
--join banmen moves on (abs(moves.suji-position.suji)<=1 and abs(moves.dan-position.dan)<=1) and moves.masume!=position.masume
--and not (moves.dan=position.dan+1 and abs(moves.suji-position.suji)=1)
--union 
--select 1 mover,5 koma,position.masume position,moves.masume moves
--from banmen position
--join banmen moves on (abs(moves.suji-position.suji)<=1 and abs(moves.dan-position.dan)<=1) and moves.masume!=position.masume
--and not (moves.dan=position.dan-1 and abs(moves.suji-position.suji)=1)order by position
----NARIGIN
--insert into moves
--select 0 mover,12 koma,position.masume position,moves.masume moves
--from banmen position
--join banmen moves on (abs(moves.suji-position.suji)<=1 and abs(moves.dan-position.dan)<=1) and moves.masume!=position.masume
--and not (moves.dan=position.dan+1 and abs(moves.suji-position.suji)=1)
--union 
--select 1 mover,12 koma,position.masume position,moves.masume moves
--from banmen position
--join banmen moves on (abs(moves.suji-position.suji)<=1 and abs(moves.dan-position.dan)<=1) and moves.masume!=position.masume
--and not (moves.dan=position.dan-1 and abs(moves.suji-position.suji)=1)order by position
----NARIKEI
--insert into moves
--select 0 mover,13 koma,position.masume position,moves.masume moves
--from banmen position
--join banmen moves on (abs(moves.suji-position.suji)<=1 and abs(moves.dan-position.dan)<=1) and moves.masume!=position.masume
--and not (moves.dan=position.dan+1 and abs(moves.suji-position.suji)=1)
--union 
--select 1 mover,13 koma,position.masume position,moves.masume moves
--from banmen position
--join banmen moves on (abs(moves.suji-position.suji)<=1 and abs(moves.dan-position.dan)<=1) and moves.masume!=position.masume
--and not (moves.dan=position.dan-1 and abs(moves.suji-position.suji)=1)order by position
----NARIKYO
--insert into moves
--select 0 mover,14 koma,position.masume position,moves.masume moves
--from banmen position
--join banmen moves on (abs(moves.suji-position.suji)<=1 and abs(moves.dan-position.dan)<=1) and moves.masume!=position.masume
--and not (moves.dan=position.dan+1 and abs(moves.suji-position.suji)=1)
--union 
--select 1 mover,14 koma,position.masume position,moves.masume moves
--from banmen position
--join banmen moves on (abs(moves.suji-position.suji)<=1 and abs(moves.dan-position.dan)<=1) and moves.masume!=position.masume
--and not (moves.dan=position.dan-1 and abs(moves.suji-position.suji)=1)order by position
----TOKIN
--insert into moves
--select 0 mover,15 koma,position.masume position,moves.masume moves
--from banmen position
--join banmen moves on (abs(moves.suji-position.suji)<=1 and abs(moves.dan-position.dan)<=1) and moves.masume!=position.masume
--and not (moves.dan=position.dan+1 and abs(moves.suji-position.suji)=1)
--union 
--select 1 mover,15 koma,position.masume position,moves.masume moves
--from banmen position
--join banmen moves on (abs(moves.suji-position.suji)<=1 and abs(moves.dan-position.dan)<=1) and moves.masume!=position.masume
--and not (moves.dan=position.dan-1 and abs(moves.suji-position.suji)=1)order by position
----KYO
--insert into moves
--select 0 mover,8 koma,position.masume position,moves.masume moves
--from banmen position
--join banmen moves on moves.suji=position.suji and moves.masume!=position.masume and moves.dan<position.dan
--union 
--select 1 mover,8 koma,position.masume position,moves.masume moves
--from banmen position
--join banmen moves on moves.suji=position.suji and moves.masume!=position.masume and moves.dan>position.dan order by mover,position
----FU
--insert into moves
--select 0 mover,9 koma,position.masume position,moves.masume moves
--from banmen position
--join banmen moves on moves.suji=position.suji and moves.masume!=position.masume and moves.dan=position.dan-1
--union 
--select 1 mover,9 koma,position.masume position,moves.masume moves
--from banmen position
--join banmen moves on moves.suji=position.suji and moves.masume!=position.masume and moves.dan-1=position.dan order by mover,position
----KEI
--insert into moves
--select 0 mover,7 koma,position.masume position,moves.masume moves
--from banmen position
--join banmen moves on abs(moves.suji-position.suji)=1 and moves.masume!=position.masume and moves.dan=position.dan-2
--union 
--select 1 mover,7 koma,position.masume position,moves.masume moves
--from banmen position
--join banmen moves on abs(moves.suji-position.suji)=1 and moves.masume!=position.masume and moves.dan-2=position.dan order by mover,position
--update moves set promotion =null
--update moves set promotion =1 where (mover=0 and (position%10 in (1,2,3) or moves%10 in (1,2,3))) or (mover=1 and (position%10 in (7,8,9) or moves%10 in (7,8,9))) and koma not in (1,2,5,10,11,12,13,14,15)
--update moves set promotion = 0 where isnull(promotion,0)!=1 and koma not in (1,2,5,10,11,12,13,14,15)
--update moves set promotion = 2 where koma in (7,8,9) and moves%10=case mover when 0 then 1 when 1 then 9 end
--update moves set promotion = 2 where koma = 7 and moves%10=case mover when 0 then 2 when 1 then 8 end
--update moves set promotion =null where koma in (1,2,5,10,11,12,13,14,15)
--update moves set drops= null
--update moves set drops = 1 where isnull(promotion,0) != 2 and koma not in (1,2,10,11,12,13,14,15)
--update moves set drops = 0 where isnull(drops,0) != 1 and koma not in (1,2,10,11,12,13,14,15)
--update moves set drops =null where koma in (1,2,10,11,12,13,14,15)
--select 'select distinct mover,koma,position into '+koma_roma+'_positions from '+koma_roma+'_moves '+koma_roma from koma
--number of possible positions, but not removing illegal pawn drops and multiple-checks, also not counting promoted pieces = 81*80*80*79*78*77*152*150*148*146*144*142*140*138*118*116*114*112*119*117*115*113*111*109*107*105*103*101*99*97*95*93*91*89*87*85*83*81
/*select 81 union all select 80 union all
select count(*)-2 from kin_positions where mover=0 union all
select count(*)-3 from kin_positions where mover=1 union all
select count(*)-4 from kin_positions where mover=0 union all
select count(*)-5 from kin_positions where mover=1 union all
select(select count(*)-6 from hi_positions where mover=0 )+(select count(*)-6 from ryuu_positions where mover = 0) union all
select(select count(*)-7 from hi_positions where mover=1 )+(select count(*)-7 from ryuu_positions where mover = 1) union all
select(select count(*)-8 from kaku_positions where mover=0 )+(select count(*)-8 from uma_positions where mover = 0) union all
select(select count(*)-9 from kaku_positions where mover=1 )+(select count(*)-9 from uma_positions where mover = 1) union all
select(select count(*)-10 from gin_positions where mover=0 )+(select count(*)-10 from narigin_positions where mover = 0) union all
select(select count(*)-11 from gin_positions where mover=1 )+(select count(*)-11 from narigin_positions where mover = 1) union all
select(select count(*)-12 from gin_positions where mover=0 )+(select count(*)-12 from narigin_positions where mover = 0) union all
select(select count(*)-13  from gin_positions where mover=1 )+(select count(*)-13 from narigin_positions where mover = 1) union all
select(select count(*)-14  from kei_positions where mover=0 )+(select count(*)-14 from narikei_positions where mover = 0) union all
select(select count(*)-15  from kei_positions where mover=1 )+(select count(*)-15 from narikei_positions where mover = 1) union all
select(select count(*)-16  from kei_positions where mover=0 )+(select count(*)-16 from narikei_positions where mover = 0) union all
select(select count(*)-17  from kei_positions where mover=1 )+(select count(*)-17 from narikei_positions where mover = 1) union all
select(select count(*)-18  from kyoo_positions where mover=0 )+(select count(*)-18 from narikyoo_positions where mover = 0) union all
select(select count(*)-19  from kyoo_positions where mover=1 )+(select count(*)-19 from narikyoo_positions where mover = 1) union all
select(select count(*)-20  from kyoo_positions where mover=0 )+(select count(*)-20 from narikyoo_positions where mover = 0) union all
select(select count(*)-21 from kyoo_positions where mover=1 )+(select count(*)-21 from narikyoo_positions where mover = 1) union all
select(select count(*)-22 from fu_positions where mover=0 )+(select count(*)-22 from tokin_positions where mover = 0) union all
select(select count(*)-23 from fu_positions where mover=1 )+(select count(*)-23 from tokin_positions where mover = 1) union all
select(select count(*)-24 from fu_positions where mover=0 )+(select count(*)-24 from tokin_positions where mover = 0) union all
select(select count(*)-25 from fu_positions where mover=1 )+(select count(*)-25 from tokin_positions where mover = 1) union all
select(select count(*)-26 from fu_positions where mover=0 )+(select count(*)-26 from tokin_positions where mover = 0) union all
select(select count(*)-27 from fu_positions where mover=1 )+(select count(*)-27 from tokin_positions where mover = 1) union all
select(select count(*)-28 from fu_positions where mover=0 )+(select count(*)-28 from tokin_positions where mover = 0) union all
select(select count(*)-29 from fu_positions where mover=1 )+(select count(*)-29 from tokin_positions where mover = 1) union all
select(select count(*)-30 from fu_positions where mover=0 )+(select count(*)-30 from tokin_positions where mover = 0) union all
select(select count(*)-31 from fu_positions where mover=1 )+(select count(*)-31 from tokin_positions where mover = 1) union all
select(select count(*)-32 from fu_positions where mover=0 )+(select count(*)-32 from tokin_positions where mover = 0) union all
select(select count(*)-33 from fu_positions where mover=1 )+(select count(*)-33 from tokin_positions where mover = 1) union all
select(select count(*)-34 from fu_positions where mover=0 )+(select count(*)-34 from tokin_positions where mover = 0) union all
select(select count(*)-35 from fu_positions where mover=1 )+(select count(*)-35 from tokin_positions where mover = 1) union all
select(select count(*)-36 from fu_positions where mover=0 )+(select count(*)-36 from tokin_positions where mover = 0) union all
select(select count(*)-37 from fu_positions where mover=1 )+(select count(*)-37 from tokin_positions where mover = 1)*/