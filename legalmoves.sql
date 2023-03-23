set nocount on;
DECLARE @sfen NVARCHAR(256) = 
	--8l/9/9/9/9/8l/9/7+bG/8K b - 1--test check
	--ppppkpppp/9/4P4/9/9/9/4p4/9/PPPPKPPPP b Pp 1 --test nifu
	--4k4/P8/P+R5l1/9/4b4/9/9/+l+b5L1/LB2K2L1 b - 1 --test ranged pieces
	--1k1l1l3/9/2+B6/9/9/9/9/8+r/L3K4 b rb4g4s4nl18p 1 --don't walk into check
	'b3r3b/4g4/2+N3l2/3S1S3/rg+l1KG3/3S+R4/6s2/1L7/4r4 b - 1'--test discovered check
	;
DECLARE @kyokumen dbo.kyokumen_plus
	;
DECLARE @kyokumenprint dbo.kyokumentype
	;
INSERT INTO @kyokumen(mover,koma,position,next_mover,move_number,dan,suji,kakuorthogonal,kakuparallel)
	SELECT mover,koma,position,next_mover,move_number,banmen.dan,banmen.suji,banmen.kakuorthogonal,banmen.kakuparallel FROM dbo.f_parseSFEN(@sfen) a
	JOIN	banmen ON banmen.masume=a.position
	;
INSERT INTO @kyokumenprint(mover,koma,position,next_mover,move_number)
	SELECT mover,koma,position,next_mover,move_number FROM @kyokumen
	;
--select dbo.f_printKyokumen(@kyokumenprint,0)
DECLARE @moves TABLE ([mover] [bit] NULL,[koma] [int] NOT NULL,[position] [int] NULL,[moves] [int] NULL,[promotion] [smallint] NULL,[moves_id] [int] NOT NULL
	,[movesuji] [int] NULL,[movedan] [int] NULL,[movekakupara] [int] NULL,[movekakuorth] [int] NULL,bitmask int null,direction int,distance int null)
--DECLARE @deleted_moves TABLE ([mover] [bit] NULL,[koma] [int] NOT NULL,[position] [int] NULL,[moves] [int] NULL,[promotion] [smallint] NULL,[moves_id] [int] NOT NULL
--	,[movesuji] [int] NULL,[movedan] [int] NULL,[movekakupara] [int] NULL,[movekakuorth] [int] NULL,bitmask int null,direction int,distance int null
--	, [reason] [varchar](500))
-- Get all possible moves
INSERT INTO @moves
	SELECT moves.*
	FROM @kyokumen kyokumen 
	JOIN moves moves ON moves.position=kyokumen.position
		AND moves.koma=kyokumen.koma
		AND moves.mover=kyokumen.mover
	;
DECLARE @nextmover BIT; SELECT TOP 1 @nextmover=next_mover FROM @kyokumen
DECLARE @player dbo.kyokumen_plus; INSERT INTO @player SELECT * FROM @kyokumen WHERE mover^@nextmover = 0
DECLARE @opponent dbo.kyokumen_plus; INSERT INTO @opponent SELECT * FROM @kyokumen WHERE mover^@nextmover = 1
DECLARE @longrange dbo.kyokumen_plus; INSERT INTO @longrange SELECT posn.* FROM @kyokumen posn JOIN koma ON koma.koma_id=posn.koma WHERE CSA_abbr IN ('HI','KA','KY','RY','UM')
DECLARE @shortrange dbo.kyokumen_plus; INSERT INTO @shortrange SELECT posn.* FROM @kyokumen posn JOIN koma ON koma.koma_id=posn.koma WHERE CSA_abbr IN ('OU','KI','GI','KE','FU','NG','NK','NY','TO')
	;
--select * from @longrange kyokumen
--		join @moves moves on moves.mover = kyokumen.mover and moves.position = kyokumen.position and moves.koma = kyokumen.koma
--		where kyokumen.position between 11 and 99;
DECLARE @kyokumenprint0 dbo.kyokumentype,@kyokumenprint1 dbo.kyokumentype,@kyokumenprint2 dbo.kyokumentype,@kyokumenprint3 dbo.kyokumentype
	;
insert into @kyokumenprint0
select mover,koma,moves,@nextmover,1 from @moves where mover=0
insert into @kyokumenprint1
select mover,koma,moves,@nextmover,1 from @moves where mover=1;

DECLARE @threatranges AS TABLE (mover bit,koma smallint, position smallint,next_mover int null,move_number int null,suji int,dan int, kakuparallel int, kakuorthogonal int
	,	[moves_id] [int] NOT NULL,[moves] [int] NULL,direction int,distance int null,[movesuji] [int] NULL,[movedan] [int] NULL,[movekakuorth] [int] NULL,[movekakupara] [int] NULL,bitmask int null)
	;
DECLARE @rangelimits AS TABLE (mover bit,koma smallint, position smallint, moves smallint,direction int,distance int, distindex int)
	;
INSERT INTO @threatranges
	SELECT kyokumen.*,moves._id moves_id,moves.moves,moves.direction,moves.distance,moves.movesuji,moves.movedan,moves.movekakuorth,moves.movekakupara,moves.bitmask
	FROM @longrange kyokumen
	JOIN moves ON moves.mover = kyokumen.mover and moves.position = kyokumen.position and moves.koma = kyokumen.koma
	WHERE kyokumen.position BETWEEN 11 AND 99
	;
WITH cte AS (
	SELECT threatranges.mover,threatranges.koma,threatranges.position,moves,direction,distance
		, ROW_NUMBER() OVER (PARTITION BY threatranges.mover,threatranges.koma,threatranges.position,threatranges.direction ORDER BY distance) distindex
	FROM @threatranges threatranges
	JOIN @kyokumen kyokumen ON kyokumen.position=threatranges.moves
	) INSERT INTO @rangelimits
	SELECT * FROM cte WHERE distindex IN (1,2)
	;
DELETE moves1
--select *
from @rangelimits rangelimits1
join @rangelimits rangelimits2 on rangelimits2.mover=rangelimits1.mover and rangelimits2.koma=rangelimits1.koma
	and rangelimits2.position=rangelimits1.position and rangelimits2.direction=rangelimits1.direction
	and rangelimits1.distindex=1 and rangelimits2.distindex=2
join @kyokumen ou on ou.koma in (1,2) and ou.position=rangelimits2.moves and ou.mover=~rangelimits2.mover and rangelimits2.distindex = 2
join @moves moves1 on moves1.position=rangelimits1.moves and moves1.mover=~rangelimits1.mover
	and not (moves1.direction = rangelimits2.direction or (moves1.direction/4=rangelimits2.direction/4 and abs(moves1.direction-rangelimits2.direction)=2))
	--Directions: N-E-S-W (0,1,2,3) and NE-SE-SW-NW (4,5,6,7)
--	FROM @moves moves1
--	JOIN @rangelimits rangelimits ON rangelimits.mover = ~moves1.mover --AND rangelimits.koma=moves1.koma
--		AND rangelimits.moves = moves1.position AND rangelimits.distindex = 1
	--JOIN @rangelimits ou ON rangelimits.mover = ~moves1.mover --AND rangelimits.koma=moves1.koma
	--	AND rangelimits.moves = moves1.position AND rangelimits.distindex = 2 AND ou.koma IN (1,2)
	--;
DELETE moves1
	FROM @moves moves1
	--join threatranges on moves1.moves_id=moves1.moves_id
	JOIN @rangelimits rangelimits ON rangelimits.mover = moves1.mover AND rangelimits.koma=moves1.koma
		AND rangelimits.position = moves1.position AND rangelimits.direction = moves1.direction AND rangelimits.distindex = 1
	WHERE moves1.distance > rangelimits.distance
	;
--INSERT INTO @deleted_moves
--	SELECT moves.*,CASE WHEN posn.mover = moves.mover THEN 'Self capture' ELSE 'Drop capture' END
DELETE moves1
	FROM @moves moves1
	JOIN @kyokumen posn ON moves1.moves = posn.position
	WHERE (	posn.mover = moves1.mover -- Remove self captures
		OR	posn.next_mover= moves1.position ) -- Remove drop captures
	;
--DELETE moves FROM @moves moves JOIN @deleted_moves deleted ON deleted.moves_id = moves.moves_id;
-- Remove nifu INSERT INTO @deleted_moves SELECT moves.*, 'Nifu';
DELETE moves1
	FROM @moves moves1
	JOIN @player posn ON posn.koma = moves1.koma AND posn.suji = moves1.movesuji
		AND moves1.position = posn.mover AND moves1.koma = 9
	;
--DELETE moves FROM @moves moves JOIN @deleted_moves deleted ON deleted.moves_id = moves.moves_id
--	;

--select distinct moves,kyokumen.mover,kyokumen.koma,kyokumen.position from @longrange kyokumen
--		join @moves moves on moves.mover = kyokumen.mover and moves.position = kyokumen.position and moves.koma = kyokumen.koma
--		where kyokumen.position between 11 and 99
--		and moves.koma=10
--		order by 2,3,4,1
insert into @kyokumenprint2
select mover,koma,moves,@nextmover,1 from @moves where mover=0 --and koma=10
insert into @kyokumenprint3
select mover,koma,moves,@nextmover,1 from @moves where mover=1 --and koma=10
select 'Sente Position'+char(10),dbo.f_printKyokumen(@kyokumenprint,0)
select 'Sente After'+char(10),dbo.f_printKyokumen(@kyokumenprint2,0)
select 'Sente Before'+char(10),dbo.f_printKyokumen(@kyokumenprint0,0)
select 'Gote Position'+char(10),dbo.f_printKyokumen(@kyokumenprint,1)
select 'Gote After'+char(10),dbo.f_printKyokumen(@kyokumenprint3,1)
select 'Gote Before'+char(10),dbo.f_printKyokumen(@kyokumenprint1,1)

/*

DECLARE @discoveredcheckscope dbo.kyokumen_plus;
insert into @discoveredcheckscope
select posn.* from @kyokumen posn
join @player ou on ou.koma in (1,2) and (posn.dan=ou.dan or posn.suji=ou.suji or posn.kakuorthogonal=ou.kakuorthogonal or posn.kakuparallel=ou.kakuparallel)

select * from @discoveredcheckscope order by koma













/*DECLARE @sfen NVARCHAR(256) = 
--8l/9/9/9/9/8l/9/7+bG/8K b - 1--test check
'b3r3b/4g4/2+N3l2/3S1S3/rg+l1KG3/3S+R4/6s2/1L7/4L4 b - 1'--test discovered check
DECLARE @kyokumen dbo.kyokumen_plus
DECLARE @kyokumenprint dbo.kyokumentype
INSERT INTO @kyokumen(mover,koma,position,next_mover,move_number,dan,suji,kakuorthogonal,kakuparallel)
SELECT mover,koma,position,next_mover,move_number,banmen.dan,banmen.suji,banmen.kakuorthogonal,banmen.kakuparallel FROM dbo.f_parseSFEN(@sfen) a
JOIN	banmen on banmen.masume=a.position
DECLARE @moves dbo.moves_udt
insert into @moves
SELECT _moves.* FROM @kyokumen kyokumen join moves _moves on _moves.position=kyokumen.position and _moves.koma=kyokumen.koma and _moves.mover=kyokumen.next_mover
insert into @kyokumenprint(mover,koma,position,next_mover,move_number) select mover,koma,position,next_mover,move_number from @kyokumen
--select dbo.f_printKyokumen(@kyokumenprint,0)
DECLARE @player dbo.kyokumen_plus; insert into @player select * from @kyokumen where mover^next_mover=0
DECLARE @opponent dbo.kyokumen_plus; insert into @opponent select * from @kyokumen where mover^next_mover=1
DECLARE @longrange dbo.kyokumen_plus; insert into @longrange select posn.* from @kyokumen posn join koma on koma.koma_id=posn.koma where CSA_abbr in('HI','KA','KY','RY','UM')
DECLARE @shortrange dbo.kyokumen_plus; insert into @shortrange select posn.* from @kyokumen posn join koma on koma.koma_id=posn.koma where CSA_abbr in('OU','KI','GI','KE','FU','NG','NK','NY','TO')

DECLARE @discoveredcheckscope dbo.kyokumen_plus;
insert into @discoveredcheckscope
select posn.* from @kyokumen posn
join @player ou on ou.koma in (1,2) and (posn.dan=ou.dan or posn.suji=ou.suji or posn.kakuorthogonal=ou.kakuorthogonal or posn.kakuparallel=ou.kakuparallel)

select * from @discoveredcheckscope order by koma/*
DECLARE @sfen NVARCHAR(256) = 'b7b/4r4/9/3SGS3/1r1GKG1r1/3S+RS3/9/4r4/b7b b  1'
DECLARE @kyokumen dbo.kyokumen_plus
DECLARE @kyokumenprint dbo.kyokumentype
INSERT INTO @kyokumen(mover,koma,position,next_mover,move_number,dan,suji,kakuorthogonal,kakuparallel)
SELECT mover,koma,position,next_mover,move_number,banmen.dan,banmen.suji,banmen.kakuorthogonal,banmen.kakuparallel
FROM dbo.f_parseSFEN(@sfen) a
JOIN	banmen on banmen.masume=a.position
DECLARE @moves dbo.moves_udt
insert into @moves
SELECT _moves.* FROM @kyokumen kyokumen join moves _moves on _moves.position=kyokumen.position and _moves.koma=kyokumen.koma and _moves.mover=kyokumen.next_mover
insert into @kyokumenprint(mover,koma,position,next_mover,move_number) select mover,koma,position,next_mover,move_number from @kyokumen
select dbo.f_printKyokumen(@kyokumenprint,0)
--todo, below query should give output but isn't so yeah check that
--Discovered check
	--if opp. piece long range on same diagonal as own king and own piece and no other piece in between
	--delete from _moves
	select ou.position ou,inbet.mover,inbet.koma,inbet.position,inbet.kakuorthogonal,inbet.kakuparallel,moves_id
		,kaku.mover,kaku.koma,kaku.position,kaku.kakuorthogonal,kaku.kakuparallel
	from @moves _moves
	join @kyokumen inbet on _moves.position=inbet.position and _moves.koma=inbet.koma and _moves.mover=inbet.next_mover and inbet.koma!=1
	join @kyokumen ou on ou.mover=inbet.mover and (inbet.kakuorthogonal=ou.kakuorthogonal or inbet.kakuparallel=ou.kakuparallel)and ou.koma=1
	join @kyokumen kaku on ou.mover=~kaku.mover and kaku.koma in (4,11) 
		and ((kaku.kakuorthogonal=inbet.kakuorthogonal and kaku.kakuorthogonal=ou.kakuorthogonal)
			or (kaku.kakuparallel=inbet.kakuparallel and kaku.kakuparallel=ou.kakuparallel))
	left join @kyokumen inbet2 
		on (	(inbet2.kakuorthogonal=inbet.kakuorthogonal and inbet2.kakuorthogonal=ou.kakuorthogonal and inbet2.kakuparallel-ou.kakuparallel<inbet.kakuparallel-ou.kakuparallel)
			or (inbet2.kakuparallel=inbet.kakuparallel and inbet2.kakuparallel=ou.kakuparallel and inbet2.kakuorthogonal-ou.kakuorthogonal<inbet.kakuorthogonal-ou.kakuorthogonal))
		and (inbet2.position!=ou.position)--or (inbet2.koma not in(4,11) and inbet2.mover=~inbet.mover))--this part is more useful in revealed check
	left join @kyokumen inbet3
		on (	(inbet3.kakuorthogonal=inbet.kakuorthogonal and inbet3.kakuorthogonal=kaku.kakuorthogonal and inbet3.kakuparallel-inbet.kakuparallel<kaku.kakuparallel-inbet.kakuparallel)
			or (inbet3.kakuparallel=inbet.kakuparallel and inbet3.kakuparallel=kaku.kakuparallel and inbet3.kakuorthogonal-inbet.kakuorthogonal<kaku.kakuorthogonal-inbet.kakuorthogonal))
		and (inbet3.position!=ou.position)
	--where inbet2.koma is null and inbet3.koma is null
	--join @kyokumen ou on ou.mover=inbet.mover and (inbet.dan=ou.dan or inbet.suji=ou.suji)
	--join @kyokumen kakuish on kakuish.mover=~ou.mover and (ou.kakuorthogonal=kakuish.kakuorthogonal or ou.kakuparallel=kakuish.kakuparallel)
	--left join @kyokumen hiish on hiish.mover=~ou.mover and (ou.dan=hiish.dan or ou.suji=hiish.suji)
	order by 1,2,3
	--order by _moves.mover,_moves.koma,_moves.position,_moves.moves
--long range pieces
	--kyo
	--hi
	--kaku
	--ryuu
	--uma
--if own piece in diagonal, range till and excluding it, if other piece in diagonal, range till and including the piece
	-- Piece cannot jump 
	-- Capture
	-- Own piece capture
--short range pieces
	--kin
	--gin
	--kei
	-- always legal except discovered oute?
--Walking into check
	--if opp. pieces' _moves exist on a square, then oute
--uchifuzume
--nifu
--Check ignored
--Tsume
--Resign
--Timeout
--Sennichite rep -2
--Sennichite -1
--Sennichite
--Renzoku Oute -2
--Renzoku Oute -1
--Renzoku Oute
--Impasse eligible
*/
*/
*/
