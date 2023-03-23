--declare @tebangoterand bigint = convert(bigint,(select max(regval) from registry where regkey='teban_gote_rand'))
--DECLARE @zobrist BIGINT = 0
--declare @sfen nvarchar(256),@kyokumen kyokumentype,@move_number smallint,@next_mover bit
--INSERT INTO @kyokumen select mover,koma,position,next_mover,move_number from dbo.f_parseSFEN(N'ln5nl/2G2R+P2/kp2+S3p/p1Pp3p1/9/P1sB4P/1P1P1+p3/2KS5/LN2r1PNL w BGS2P2g3p 92')
--select @zobrist=dbo.f_generateZobrist(@kyokumen)
--select @zobrist
--go
CREATE OR ALTER FUNCTION f_generateZobrist (@kyokumen kyokumentype READONLY)
RETURNS BIGINT
as
	BEGIN 
	DECLARE @zobrist BIGINT = 0
	declare @tebangoterand bigint = convert(bigint,(select max(regval) from registry where regkey='teban_gote_rand'))
	if exists (select 1 from @kyokumen where next_mover=1)set @zobrist=@zobrist^@tebangoterand
	--select 'teban_gote_rand' regkey,convert(bigint,CONVERT(binary(8), NEWID()))regval into registry -- one-time insert made in registry
	--MS SQL seems to allow aggregating bitwise XOR like this, but it's not documented..and yet it yields exact same result as the normal while loop so..
	/*DECLARE @Zobrist_processing table (rn smallint,pseudorandom bigint)
	insert into @Zobrist_processing(rn,pseudorandom)
	select row_number()over(order by kyokumen.position,kyokumen.mover,kyokumen.koma)rn,pseudorandom
	from @kyokumen kyokumen
	join positions on positions.mover=kyokumen.mover and positions.koma=kyokumen.koma and positions.position = kyokumen.position
	where pseudorandom is not null
	declare @pseudorandom bigint=0
	while exists(select 1 from @Zobrist_processing)
		begin
		set @pseudorandom=(select top(1) pseudorandom from @Zobrist_processing)
		set @Zobrist=@Zobrist^@pseudorandom
		delete @Zobrist_processing where pseudorandom=@pseudorandom
		end*/
	select @zobrist=@zobrist^pseudorandom
	from @kyokumen kyokumen
	join positions on positions.mover=kyokumen.mover and positions.koma=kyokumen.koma and positions.position = kyokumen.position
	where pseudorandom is not null
	RETURN @Zobrist;
	END
GO
CREATE OR ALTER FUNCTION f_matchSFENtoZobrist (@sfen nvarchar(256))
RETURNS BIGINT
	BEGIN
	DECLARE @matched_id BIGINT, @zobrist BIGINT;
	DECLARE @kyokumen dbo.kyokumentype;
	INSERT INTO @kyokumen SELECT * FROM dbo.f_parseSFEN(@sfen);
	SET @zobrist = dbo.f_generateZobrist(@kyokumen)
	SELECT @matched_id=_id from transpositions where zobrist=@zobrist;
	RETURN ISNULL(@matched_id,0);
	END
	;
