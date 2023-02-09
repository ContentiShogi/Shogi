declare @kyokumen kyokumentype 
INSERT INTO @kyokumen select mover,koma,position from f_parseSFEN(N'ln5nl/2G2R+P2/kp2+S3p/p1Pp3p1/9/P1sB4P/1P1P1+p3/2KS5/LN2r1PNL w BGS2P2g3p 92')
select dbo.f_generateSFEN(@kyokumen,1,92)
GO
IF NOT EXISTS(SELECT * FROM SYS.TYPES WHERE NAME='kyokumentype')
	CREATE TYPE kyokumentype AS TABLE (mover bit,koma smallint, position smallint);
GO
CREATE OR ALTER FUNCTION f_generateSFEN (@kyokumen kyokumentype READONLY,@mover bit = 0,@turn int = 1)
RETURNS NVARCHAR(256)
as
	BEGIN 
	--DECLARE @kyokumen table (mover bit,koma smallint, position smallint)
	
	Declare @sfen nvarchar(256)='',@komadai nvarchar(256)=''
	DECLARE @sfen_processing table (rn smallint,sfen nvarchar(10))
	DECLARE @kyokumen_processing table (number smallint,position smallint,koma smallint, mover bit,sfen nvarchar(10))
	
	insert into @kyokumen_processing
	SELECT row_number()over(order by kyokumen.mover,isnull(koma.promoted_from,koma.koma_id))rn
		,kyokumen.position
		,kyokumen.koma,mover
		,case when position%10>1 then convert(varchar(2),position%100) else '' end+case mover when 1 then koma.sfen_gote when 0 then koma.sfen_sente end sfen
	FROM @kyokumen kyokumen
	join koma on koma.koma_id=kyokumen.koma
	where kyokumen.position/10>=10
	
	select @komadai=@komadai+sfen from @kyokumen_processing
	delete @kyokumen_processing
	insert into @kyokumen_processing
	SELECT number,position,kyokumen.koma,mover
		,case mover when 1 then koma.sfen_gote when 0 then koma.sfen_sente end sfen
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
	RETURN left(@sfen,len(@sfen)-1)+case @mover when 0 then ' b ' else ' w 'end+@komadai+' '+convert(varchar(5),@turn);
	END
GO
--select * from f_parseSFEN(N'9/3k5/9/9/9/4K4/9/9/9 w L2r2b4g4s4n3l18p 4')
CREATE OR ALTER FUNCTION f_parseSFEN (@sfen nvarchar(256)='')
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
end
GO
