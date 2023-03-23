declare @kyokumen kyokumentype 
INSERT INTO @kyokumen select mover,koma,position,next_mover,move_number from dbo.f_parseSFEN(N'ln5nl/2G2R+P2/kp2+S3p/p1Pp3p1/9/P1sB4P/1P1P1+p3/2KS5/LN2r1PNL w BGS2P2g3p 92')
select dbo.f_generateSFEN(@kyokumen,1,92)SFEN
GO
IF NOT EXISTS(SELECT * FROM SYS.TYPES WHERE NAME='kyokumentype')
	CREATE TYPE kyokumentype AS TABLE (mover bit,koma smallint, position smallint,next_mover int null,move_number int null);
GO
IF NOT EXISTS(SELECT * FROM SYS.TYPES WHERE NAME='kyokumen_plus')
	CREATE TYPE kyokumen_plus AS TABLE (mover bit,koma smallint, position smallint,next_mover int null,move_number int null,suji int,dan int, kakuparallel int, kakuorthogonal int);
GO
IF NOT EXISTS(SELECT * FROM SYS.TYPES WHERE NAME='moves_udt')
	CREATE TYPE moves_udt AS TABLE (mover bit,koma smallint, position smallint, moves smallint,promotion smallint,moves_id smallint,
				movesuji smallint,movedan smallint,movekakupara smallint,movekakuorth smallint);
GO
IF NOT EXISTS(SELECT * FROM SYS.TYPES WHERE NAME='moves_played_udt')
	CREATE TYPE moves_played_udt AS TABLE (move_number int,move_id smallint,mover bit,koma smallint
										,from_position smallint,to_position smallint,promoted bit,captured bit
										,csa nvarchar(7),sfen nvarchar(256),valid bit);
GO
IF NOT EXISTS(SELECT * FROM SYS.tables WHERE NAME='type_of_move')
	create table type_of_move (_id smallint identity(1,1),movetype_name nvarchar(256),movetype_desc ntext,isillegal bit)
	insert into type_of_move(movetype_name,movetype_desc,isillegal)
	select * from (values
	('Oute',null,null),('Uchifuzume',null,1),('Nifu',null,1),('Incorrect piece movement',null,1),('Discovered check',null,1)
	,('Walking into check',null,1),('Check ignored',null,1),('Promotion',null,null),('Unpromote',null,null)
	,('Capture',null,null),('Piece cannot jump',null,1),('Own piece capture',null,1),('Tsume',null,null)
	,('Resign',null,0),('Timeout',null,0),('Sennichite rep -2',null,null),('Sennichite -1',null,null),('Sennichite',null,0)
	,('Renzoku Oute -2',null,null),('Renzoku Oute -1',null,null),('Renzoku Oute',null,1),('Impasse eligible',null,null)
	)as type_of_move(movetype_name,movetype_desc,isillegal)
GO
CREATE OR ALTER FUNCTION f_generateSFEN (@kyokumen kyokumentype READONLY,@next_mover bit =0,@move_number int =1)
RETURNS NVARCHAR(256)
as
	BEGIN 
	--DECLARE @kyokumen table (mover bit,koma smallint, position smallint)
	select @next_mover=isnull(next_mover,@next_mover) from @kyokumen where @next_mover is null
	select @move_number=isnull(max(move_number),@move_number) from @kyokumen where @move_number is null

	Declare @sfen nvarchar(256)='',@komadai nvarchar(256)=''
	DECLARE @sfen_processing table (rn smallint,sfen nvarchar(10))
	DECLARE @kyokumen_processing table (number smallint,position smallint,koma smallint, mover bit,sfen nvarchar(10))
	
	--no longer required now that dbo.komadai exists
	--insert into @kyokumen_processing
	--SELECT row_number()over(order by kyokumen.mover,isnull(koma.promoted_from,koma.koma_id))rn
	--	,kyokumen.position
	--	,kyokumen.koma,mover
	--	,case when position%10>1 then convert(varchar(2),position%100) else '' end+case mover when 1 then koma.sfen_gote when 0 then koma.sfen_sente end sfen
	--FROM @kyokumen kyokumen
	--join koma on koma.koma_id=kyokumen.koma
	--where kyokumen.position/10>=10
	insert into @kyokumen_processing
	SELECT row_number()over(order by kyokumen.koma,kyokumen.mover)number
		,kyokumen.position
		,kyokumen.koma,kyokumen.mover
		,komadai.sfen
	FROM @kyokumen kyokumen
	join komadai on komadai.koma=kyokumen.koma and kyokumen.position=komadai.position and kyokumen.mover=komadai.mover
	order by number
	select @komadai=@komadai+sfen from @kyokumen_processing order by number
	delete @kyokumen_processing

	INSERT INTO @kyokumen_processing
	SELECT number,position,kyokumen.koma,mover
		,CASE mover WHEN 1 THEN koma.sfen_gote WHEN 0 THEN koma.sfen_sente END sfen
	FROM (select number,1 i from master..spt_values where type='P'and number between 11 and 99 and number%10!=0)squares
	left join @kyokumen kyokumen on squares.number=kyokumen.position
	left join koma on koma.koma_id=kyokumen.koma
		where number/10<10
	group by position,kyokumen.koma,mover,koma.sfen_gote,koma.sfen_sente,number
	order by number%10,number/10 desc

	;with cte as(
		select isnull(a.position,stuffn)position,a.koma,a.mover,isnull(a.sfen,count(a.number))sfen--,bb.delim
		from @kyokumen_processing a 
		cross apply 
			(select isnull(min(b.number),90+a.number%10) stuffn,case when a.number!=91 and a.number/10=9 then'/' else ''end delim
			from @kyokumen_processing b where a.position is null and b.position is not null 
				and ((b.number%10=a.number%10 and b.number/10>a.number/10))
			)bb
		group by isnull(a.position,stuffn),a.koma,a.mover,a.sfen--,bb.delim
		) insert into @sfen_processing(rn,sfen)
		select row_number() over(order by position%10,position/10 desc,koma desc)rn,sfen 
		from cte 
		order by position%10,position/10 desc,koma desc
	select @sfen=@sfen+
		case when (t1.rn
					+sum(case when t2.sfen like'[2-9]'then convert(int,t2.sfen)-1 else 0 end)
				  )%9=0 then t1.sfen+'/' else t1.sfen end
	from @sfen_processing t1 cross join @sfen_processing t2 where t2.rn<=t1.rn
	group by t1.rn,t1.sfen,case when t1.sfen like'[2-9]'then convert(int,t1.sfen)else 0 end
	order by t1.rn
	RETURN left(@sfen,len(@sfen)-1)+case @next_mover when 0 then ' b ' else ' w 'end+@komadai+' '+convert(varchar(5),@move_number);
	END
GO
--select * from f_parseSFEN(N'9/3k5/9/9/9/4K4/9/9/9 w L2r2b4g4s4n3l18p 4')
CREATE OR ALTER FUNCTION f_parseSFEN (@sfen nvarchar(256)='')
returns @kyokumen TABLE (mover bit,koma smallint, position smallint,next_mover int null,move_number int null)
as
begin 
Declare @sfenchar nvarchar(10)='',@dan int = 1,@suji int =9,@skip bit=0,@move_number int =null,@next_mover bit
--todo- simplify- just use string split at space, then process komadai banmen next mover and move number separately. This will make the complicated '@skip' logic unnecessary
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
					select case when sfen_sente = @sfenchar then 0 when sfen_gote = @sfenchar then 1 end mover
						, koma.koma_id
						, @suji*10+@dan position
						, null,null
					from koma where @sfenchar in (sfen_sente,sfen_gote)
					set @suji=@suji-1
					end
			end
		if(@skip = 1)
			begin
				--select 'debug',@move_number,@skip skips,@sfenchar sfenchar,@suji suji,@dan dan,@sfen ,1
				if (@sfenchar like ' _ ') 
					begin set @next_mover= case @sfenchar when ' b ' then 0 when ' w ' then 1 end 
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
					select case when sfen_sente = right(@sfenchar,1) then 0 when sfen_gote = right(@sfenchar,1) then 1 end mover
						, koma.koma_id
						, (100*koma_id)
							+ case when @sfenchar like'[1-9]%' then convert(int,substring(replace(@sfenchar,' ','0'),1,len(replace(@sfenchar,' ','|'))-1))
								else 1 end
						, null,null
					from koma where right(@sfenchar,1) in (sfen_sente,sfen_gote)
					end
			end
		set @sfen=right(@sfen,len(@sfen)-len(replace(@sfenchar,' ','|')))
	end
	update @kyokumen set move_number=@move_number,next_mover=@next_mover
	return;
end
GO
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

--select kakuparallel,kakuorthogonal,(kakuparallel+kakuorthogonal+2)/2 suji2,(kakuorthogonal+2-kakuparallel)/2 dan2,suji,dan,suji+dan-2 kakuorthogonal2,suji-dan kakuparallel2
--from banmen
--order by suji,dan



/* --Just for fun, here's what Chat GPT wrote:
-- Create a table to store the SFEN format string
CREATE TABLE sfen_string (
    id INT IDENTITY(1,1) PRIMARY KEY,
    sfen_string VARCHAR(MAX)
);

-- Insert a sample SFEN format string into the table
INSERT INTO sfen_string VALUES ('lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL b - 1');

-- Create a table to store the parsed SFEN format string
CREATE TABLE parsed_sfen (
    id INT IDENTITY(1,1) PRIMARY KEY,
    board_position VARCHAR(9),
    turn VARCHAR(1),
    move_number INT,
    sfen_string_id INT FOREIGN KEY REFERENCES sfen_string(id)
);

-- Parse the SFEN format string and insert into the parsed_sfen table
INSERT INTO parsed_sfen (board_position, turn, move_number, s...


--Here's what it wrote when I asked to check for interposing pieces:

// Create a function to check for interposing pieces
function checkInterposingPiece(board, startRow, startCol, endRow, endCol) {
    // Get the row and column difference
    const rowDiff = Math.abs(endRow - startRow);
    const colDiff = Math.abs(endCol - startCol);
    
    // Check if the move is diagonal
    if (rowDiff === colDiff) {
        // Check if there is a piece in between
        const rowStep = (endRow - startRow) / rowDiff;
        const colStep = (endCol - startCol) / colDiff;
        for (let i = 1; i < rowDiff; i++) {
            const row = startRow + i * rowStep;
            const col = startCol + i * colStep;
            if (board[row][col] !== null) {
                return true;
            }
        }
    }
    return false;
}
This is so good!

*/
/*
;with cte as
(select position,count(moves)moves from kaku_moves
where position between 11 and 99 and mover=1
group by position)
--select sum(moves)from cte
--select sum(power(2,moves))from cte
select position,moves,power(2,moves)combos from cte order by 2 desc

select banmen.masume,_1s.moves,STRING_AGG(_0s.moves,',')within group (order by _0s.moves)
from banmen
join kaku_moves _0s on _0s.position=masume and _0s.mover=0
join kaku_moves _1s on _1s.position=masume and _1s.mover=1 and _0s.moves!=_1s.moves
where masume=55
group by banmen.masume,_1s.moves
order by 2 desc

;with cte as
(select _id,mover,koma,position,moves,power(2,ROW_NUMBER()over(partition by mover,koma,position order by distance,direction)-1) rn
from moves where position between 11 and 99)
update moves
set bitmask=rn
from cte where cte._id=moves._id
select * from moves order by mover,koma,position,distance,direction
;with cte as
(select *,
	case when position/10=moves/10 and moves%10<position%10 then 0 
		when position%10=moves%10 and moves/10<position/10 then 1 
		when position/10=moves/10 and moves%10>position%10 then 2
		when position%10=moves%10 and moves/10>position/10 then 3
		when moves/10<position/10 and moves%10<position%10 then 4
		when moves/10<position/10 and moves%10>position%10 then 5
		when moves/10>position/10 and moves%10>position%10 then 6
		when moves/10>position/10 and moves%10<position%10 then 7
		else null end dir from moves where position between 11 and 99 and position!=moves)
update moves
set distance=abs(position/10-moves/10)+abs(position%10-moves%10)
from cte where cte._id=moves._id
order by rn desc

update moves set movesuji=moves/10,movedan=moves%10
direction =8 where position in (0,1)
update moves set movekakuorth=kakuorthogonal,movekakupara=kakuparallel
from moves join banmen on moves.moves=banmen.masume
select * from moves
order by mover,koma,position,distance,direction,bitmask
select * from koma

update moves set distance =1 where koma in (10,11)and position not in (0,1)and (abs(position/10-moves/10)=1 and abs(position%10-moves%10)=1)
select * from moves
*/
