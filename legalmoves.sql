--todo: some problem with kyokumen print, fix it then check if nifu and uchifuzume work
SET NOCOUNT ON;
DECLARE @sfen NVARCHAR(256) = 
	--'8l/9/9/9/9/8l/7G1/7+b1/8K b - 1'--test check
	'1pppkpppp/9/4P4/9/9/9/4p4/9/1PPPKPPPP 1 Pp 1' --test nifu
	--'4k4/P8/P+R5l1/9/4b4/9/9/+l+b5L1/LB2K2L1 b - 1' --test ranged pieces
	--'1k1l1l3/9/2+B6/9/9/9/9/8+r/L3K4 b rb4g4s4nl18p 1' --don't walk into check
	--'b3r3b/4g4/2+N3l2/3S1S3/rg+l1KG3/3S+R4/6s2/1L7/4r4 b - 1'--test discovered check
	;
DECLARE @kyokumen dbo.kyokumen_plus
	;
DECLARE @kyokumenprint dbo.kyokumentype
	;
INSERT INTO @kyokumen(mover,koma,position,next_mover,move_number,dan,suji,kakuorthogonal,kakuparallel)
	SELECT a.mover,a.koma,ISNULL(banmen.masume,komadai.mover),next_mover,move_number,banmen.dan,banmen.suji,banmen.kakuorthogonal,banmen.kakuparallel FROM dbo.f_parseSFEN(@sfen) a
	LEFT JOIN	banmen ON banmen.masume=a.position
	LEFT JOIN	komadai ON komadai.position=a.position AND a.mover = komadai.mover
	WHERE komadai.position IS NOT NULL OR banmen.masume IS NOT NULL
--select * from @kyokumen order by position
INSERT INTO @kyokumenprint(mover,koma,position,next_mover,move_number)
	SELECT mover,koma,position,next_mover,move_number FROM @kyokumen
	;
DECLARE @moves TABLE ([mover] [bit] NULL,[koma] [int] NOT NULL,[position] [int] NULL,[moves] [int] NULL,[promotion] [smallint] NULL,[moves_id] [int] NOT NULL
	,[movesuji] [int] NULL,[movedan] [int] NULL,[movekakupara] [int] NULL,[movekakuorth] [int] NULL,bitmask int null,direction int,distance int null)
	;
-- Get all possible moves
INSERT INTO @moves
	SELECT moves.*
	FROM @kyokumen kyokumen 
	JOIN moves moves ON moves.position=kyokumen.position
		AND moves.koma=kyokumen.koma
		AND moves.mover=kyokumen.mover
	;
SELECT * FROM @kyokumen where position not between 11 and 99
DECLARE @nextmover BIT; SELECT TOP 1 @nextmover=next_mover FROM @kyokumen
--DECLARE @player dbo.kyokumen_plus; INSERT INTO @player SELECT * FROM @kyokumen WHERE mover^@nextmover = 0
--DECLARE @opponent dbo.kyokumen_plus; INSERT INTO @opponent SELECT * FROM @kyokumen WHERE mover^@nextmover = 1
DECLARE @longrange dbo.kyokumen_plus; INSERT INTO @longrange SELECT posn.* FROM @kyokumen posn JOIN koma ON koma.koma_id=posn.koma WHERE CSA_abbr IN ('HI','KA','KY','RY','UM')
--DECLARE @shortrange dbo.kyokumen_plus; INSERT INTO @shortrange SELECT posn.* FROM @kyokumen posn JOIN koma ON koma.koma_id=posn.koma WHERE CSA_abbr IN ('OU','KI','GI','KE','FU','NG','NK','NY','TO')
	;
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
-- Don't move piece if skewered to king
DELETE moves1
from @rangelimits rangelimits1
join @rangelimits rangelimits2 on rangelimits2.mover=rangelimits1.mover and rangelimits2.koma=rangelimits1.koma
	and rangelimits2.position=rangelimits1.position and rangelimits2.direction=rangelimits1.direction
	and rangelimits1.distindex=1 and rangelimits2.distindex=2
join @kyokumen ou on ou.koma in (1,2) and ou.position=rangelimits2.moves and ou.mover=~rangelimits2.mover and rangelimits2.distindex = 2
join @moves moves1 on moves1.position=rangelimits1.moves and moves1.mover=~rangelimits1.mover
	--Directions: N-E-S-W (0,1,2,3) and NE-SE-SW-NW (4,5,6,7)
	and not (moves1.direction = rangelimits2.direction or (moves1.direction/4=rangelimits2.direction/4 and abs(moves1.direction-rangelimits2.direction)=2))
-- Don't move ranged piece beyond blockers
DELETE moves1
	FROM @moves moves1
	JOIN @rangelimits rangelimits ON rangelimits.mover = moves1.mover AND rangelimits.koma=moves1.koma
		AND rangelimits.position = moves1.position AND rangelimits.direction = moves1.direction AND rangelimits.distindex = 1
	WHERE moves1.distance > rangelimits.distance
	;
-- Don't walk into check
DELETE moves1
	FROM @moves moves1
	JOIN @moves moves2
		ON moves1.moves = moves2.moves AND moves1.mover=~moves2.mover AND moves1.koma in (1,2)
	;
--Don't ignore check
DECLARE @check_range TABLE ([mover] [bit] NULL,[koma] [int] NOT NULL,[position] [int] NULL,[moves] [int] NULL,[promotion] [smallint] NULL,[moves_id] [int] NOT NULL
	,[movesuji] [int] NULL,[movedan] [int] NULL,[movekakupara] [int] NULL,[movekakuorth] [int] NULL,bitmask int null,direction int,distance int null)
	;
INSERT INTO @check_range
	SELECT range_squares.*
	FROM @moves moves
	JOIN @kyokumen ou ON moves.moves = ou.position AND ou.koma IN (1,2) AND moves.mover = ~ou.mover
	JOIN @moves range_squares ON range_squares.mover = moves.mover AND range_squares.koma = moves.koma AND range_squares.position = moves.position
		AND range_squares.direction = moves.direction AND range_squares.distance <= moves.moves
	;
DELETE moves1
	FROM @moves moves1
	JOIN @check_range check_range ON moves1.mover=~check_range.mover
	WHERE ( (moves1.koma IN (1,2) AND moves1.moves = check_range.moves) -- move king anywhere outside check line
		OR ( moves1.koma NOT IN (1,2) AND moves1.moves NOT IN (check_range.moves,check_range.position)) -- block or capture checking piece
		)
	;
-- Illegal captures
DELETE moves1
	FROM @moves moves1
	JOIN @kyokumen posn ON moves1.moves = posn.position
	WHERE (	posn.mover = moves1.mover -- Remove self captures
		OR	moves1.position IN (0,1)) -- Remove drop captures
	;
-- Don't nifu
DELETE moves1
	FROM @moves moves1
	JOIN @kyokumen posn ON posn.koma = moves1.koma AND posn.suji = moves1.movesuji
		AND moves1.position = posn.mover AND moves1.koma = 9
	;
-- Don't uchifuzume
DELETE moves1
	FROM @moves moves1
	JOIN @kyokumen ou ON ou.koma IN (1,2) AND ou.mover = ~moves1.mover
		AND CASE WHEN ou.mover = 0 THEN (ou.position/10)*10+(ou.position%10-1)
			WHEN ou.mover = 1 THEN (ou.position/10)*10+(ou.position%10+1)
			END = moves1.moves
	WHERE moves1.koma = 9 AND moves1.position = moves1.mover
		AND NOT EXISTS
		(	SELECT 1 FROM @moves moves2
			WHERE moves2.mover = ou.mover
			AND (moves2.moves = moves1.moves -- Can't capture pawn
				OR moves2.koma IN (1,2)-- Ou can't run
				)
		)
	;
--select distinct moves,kyokumen.mover,kyokumen.koma,kyokumen.position from @longrange kyokumen
--		join @moves moves on moves.mover = kyokumen.mover and moves.position = kyokumen.position and moves.koma = kyokumen.koma
--		where kyokumen.position between 11 and 99
--		and moves.koma=10
--		order by 2,3,4,1
insert into @kyokumenprint2
select mover,koma,moves,@nextmover,1 from @moves where mover=0
insert into @kyokumenprint3
select mover,koma,moves,@nextmover,1 from @moves where mover=1
select 'Sente Position'+char(10),dbo.f_printKyokumen(@kyokumenprint,0)
select 'Sente After'+char(10),dbo.f_printKyokumen(@kyokumenprint2,0)
select 'Sente Before'+char(10),dbo.f_printKyokumen(@kyokumenprint0,0)
select 'Gote Position'+char(10),dbo.f_printKyokumen(@kyokumenprint,1)
select 'Gote After'+char(10),dbo.f_printKyokumen(@kyokumenprint3,1)
select 'Gote Before'+char(10),dbo.f_printKyokumen(@kyokumenprint1,1)
--TODO:
--Sennichite rep -2
--Sennichite -1
--Sennichite
--Renzoku Oute -2
--Renzoku Oute -1
--Renzoku Oute
--Impasse eligible
