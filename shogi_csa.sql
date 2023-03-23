--declare @moves_played_working moves_played_udt
--insert into @moves_played_working select * from dbo.f_parseCSA(N'$EVENT:Contenti''s Study - Chapter 4
--$SITE:https://lishogi.org/study/dkxSg6qS/UN4TuLA5
--P1-KY-KE-GI-KI-OU-KI-GI-KE-KY
--P2 * -HI *  *  *  *  * -KA * 
--P3-FU-FU-FU-FU-FU-FU-FU-FU-FU
--P4 *  *  *  *  *  *  *  *  * 
--P5 *  *  *  *  *  *  *  *  * 
--P6 *  *  *  *  *  *  *  *  * 
--P7+FU+FU+FU+FU+FU+FU+FU+FU+FU
--P8 * +KA *  *  *  *  * +HI * 
--P9+KY+KE+GI+KI+OU+KI+GI+KE+KY
--+
--+1716FU
---1314FU
--+1615FU
---2324FU
--+1514FU
---2425FU
--+1413TO
---1113KY
--+1913KY
---2526FU
--+1312NY
---2627TO
--+2827HI
---2213KA
--+1222NY
---3132GI
--+2232NY
---1346KA
--+0023GI
---2113KE
--+2312NG
---4142KI
--+1213NG
---3334FU
--+3928GI
---4344FU
--+2817GI
---3435FU
--+1726GI
---4445FU
--+2625GI
---5354FU
--+2524GI
---5455FU
--+2423GI
---6364FU
--+2334GI
---6465FU
--+3423GI
---5162OU
--+0022FU
---6272OU
--+0012FU
---6162KI
--+0019KY
---7374FU
--+0084KE')
--declare @a moves_played_udt
--insert into @a select * from f_parseCSA(@csa,0)
--select move_number,csa,dbo.f_printsfen(sfen,0) from f_validateCSA(@a)--where sfen is not null
--GO
CREATE OR ALTER FUNCTION f_parseCSA
	(	@csa		VARCHAR(8000) = '' )--validate doesn't check legality. Just very basic check 
-- can handle only 8000 chars, so that's about 530-540 moves 
RETURNS @moves_played TABLE 
	(	move_number INT IDENTITY(1,1)
	,	move_id		SMALLINT	, mover			BIT
	,	koma		SMALLINT	, from_position	SMALLINT
	,	to_position	SMALLINT	, promoted		BIT
	,	captured	BIT			, csa			NVARCHAR(7)
	,	sfen		NVARCHAR(256), valid		BIT	) 
AS	BEGIN  
	DECLARE	@original_position_working	VARCHAR(1000) = ''
		,	@csa_moves					VARCHAR(8000)
		,	@first_mover				BIT = NULL 
		;
	DECLARE	@original_sfen	NVARCHAR(256)=''
		;
	DECLARE	@kyokumen	dbo.kyokumentype 
		;
	IF LEFT(LTRIM(RTRIM(@csa)),1) IN ('$','V','N') -- rudimentary validation of format
		BEGIN 
		-- Parse CSA
		SET	@csa = REPLACE(REPLACE(@csa, CHAR(10)+CHAR(13), CHAR(10)), CHAR(13) + CHAR(10), CHAR(10)) 
			;
		SET	@first_mover = CASE
			WHEN CHARINDEX(CHAR(10) + '+' + CHAR(10), @csa) > 0 THEN 0
			WHEN CHARINDEX(CHAR(10) + '-' + CHAR(10), @csa) > 0 THEN 1
			END
			;
		SET	@csa = REPLACE(REPLACE(@csa, CHAR(10) + '+' + CHAR(10), '|'), CHAR(10) + '-' + CHAR(10), '|')
			;
		SET	@original_position_working = RIGHT(
				LEFT(@csa , CHARINDEX('|', @csa) - 1)
			,	LEN(LEFT(@csa, CHARINDEX('|', @csa) - 1)) - CHARINDEX('P1',LEFT(@csa,CHARINDEX('|',@csa) - 1)) + 1)
			; 
		SET	@csa_moves = RIGHT(@csa, LEN(@csa) - CHARINDEX('|', @csa)) 
			;
		WITH cte AS( 
			SELECT	CONVERT(SMALLINT, LEFT(value,1))	dan
				,	CONVERT(NVARCHAR(500), RIGHT(value, LEN(value)-1) COLLATE Latin1_General_CS_AS) txt
			FROM	STRING_SPLIT(@original_position_working,'P')
			WHERE	LEFT(value, 1) LIKE '[1-9]'
			)
		SELECT	@original_sfen = REPLACE(REPLACE(STRING_AGG(--DAN, 
			REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( 
			REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( 
			REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cte.txt,'*','* '),'*  ','* '),' * ','1')
			,'111111111','9'),'11111111','8'),'1111111','7'),'111111','6'),'11111','5'),'1111','4'),'111','3'),'11','2') 
			,'+OU','K'),'-OU','k'),'+HI','R'),'-HI','r'),'+KA','B'),'-KA','b'),'+KI','G'),'-KI','g'),'+GI','S'),'-GI','s'),'+KE','N'),'-KE','n'),'+KY','L'),'-KY','l') 
			,'+FU','P'),'-FU','p'),'+RY','+R'),'-RY','+r'),'+UM','+B'),'-UM','+b'),'+NG','+S'),'-NG','+s'),'+NK','+N'),'-NK','+n'),'+NY','+L'),'-NY','+l'),'+TO','+P'),'-TO','+p') 
			,'/')WITHIN GROUP (ORDER BY DAN),CHAR(13),''),CHAR(10),'') 
		FROM	cte
			; 
		SET @original_sfen = @original_sfen + CASE @first_mover WHEN 0 THEN ' b | 0' WHEN 1 THEN ' w | 1' END 
			;
		WITH cte AS ( 
			SELECT	CONVERT(SMALLINT, CASE LEFT(value,1) WHEN '+' THEN 0 WHEN '-' THEN 1 END)mover 
				,	CONVERT(NVARCHAR(500),RIGHT(value,LEN(value)-1)COLLATE Latin1_General_CS_AS) txt
			FROM	STRING_SPLIT(@original_position_working,'P')
			WHERE	LEFT(value,1) IN ('+','-')
			) 
		SELECT @original_sfen = REPLACE(@original_sfen,'|',ISNULL(REPLACE(STRING_AGG( 
			REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( 
			REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( 
			REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(txt, 
			'00KE00KE00KE00KE',CASE mover WHEN 1 THEN '4n' WHEN 0 THEN '4N' END), 
			'00KE00KE00KE',CASE mover WHEN 1 THEN '3n' WHEN 0 THEN '3N' END), 
			'00KE00KE',CASE mover WHEN 1 THEN '2n' WHEN 0 THEN '2N' END), 
			'00KE',CASE mover WHEN 1 THEN 'n' WHEN 0 THEN 'N' END), 
			'00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU',CASE mover WHEN 1 THEN '18p' WHEN 0 THEN '18P' END), 
			'00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU',CASE mover WHEN 1 THEN '17p' WHEN 0 THEN '17P' END), 
			'00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU',CASE mover WHEN 1 THEN '16p' WHEN 0 THEN '16P' END), 
			'00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU',CASE mover WHEN 1 THEN '15p' WHEN 0 THEN '15P' END), 
			'00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU',CASE mover WHEN 1 THEN '14p' WHEN 0 THEN '14P' END), 
			'00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU',CASE mover WHEN 1 THEN '13p' WHEN 0 THEN '13P' END), 
			'00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU',CASE mover WHEN 1 THEN '12p' WHEN 0 THEN '12P' END), 
			'00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU',CASE mover WHEN 1 THEN '11p' WHEN 0 THEN '11P' END), 
			'00FU00FU00FU00FU00FU00FU00FU00FU00FU00FU',CASE mover WHEN 1 THEN '10p' WHEN 0 THEN '10P' END), 
			'00FU00FU00FU00FU00FU00FU00FU00FU00FU',CASE mover WHEN 1 THEN '9p' WHEN 0 THEN '9P' END), 
			'00FU00FU00FU00FU00FU00FU00FU00FU',CASE mover WHEN 1 THEN '8p' WHEN 0 THEN '8P' END), 
			'00FU00FU00FU00FU00FU00FU00FU',CASE mover WHEN 1 THEN '7p' WHEN 0 THEN '7P' END), 
			'00FU00FU00FU00FU00FU00FU',CASE mover WHEN 1 THEN '6p' WHEN 0 THEN '6P' END), 
			'00FU00FU00FU00FU00FU',CASE mover WHEN 1 THEN '5p' WHEN 0 THEN '5P' END), 
			'00FU00FU00FU00FU',CASE mover WHEN 1 THEN '4p' WHEN 0 THEN '4P' END), 
			'00FU00FU00FU',CASE mover WHEN 1 THEN '3p' WHEN 0 THEN '3P' END), 
			'00FU00FU',CASE mover WHEN 1 THEN '2p' WHEN 0 THEN '2P' END), 
			'00FU',CASE mover WHEN 1 THEN 'p' WHEN 0 THEN 'P' END), 
			'00KA00KA',CASE mover WHEN 1 THEN '2b' WHEN 0 THEN '2B' END), 
			'00KA',CASE mover WHEN 1 THEN 'b' WHEN 0 THEN 'B' END), 
			'00KI00KI00KI00KI',CASE mover WHEN 1 THEN '4g' WHEN 0 THEN '4G' END), 
			'00KI00KI00KI',CASE mover WHEN 1 THEN '3g' WHEN 0 THEN '3G' END), 
			'00KI00KI',CASE mover WHEN 1 THEN '2g' WHEN 0 THEN '2G' END), 
			'00KI',CASE mover WHEN 1 THEN 'g' WHEN 0 THEN 'G' END), 
			'00GI00GI00GI00GI',CASE mover WHEN 1 THEN '4s' WHEN 0 THEN '4S' END), 
			'00GI00GI00GI',CASE mover WHEN 1 THEN '3s' WHEN 0 THEN '3S' END), 
			'00GI00GI',CASE mover WHEN 1 THEN '2s' WHEN 0 THEN '2S' END), 
			'00GI',CASE mover WHEN 1 THEN 's' WHEN 0 THEN 'S' END), 
			'00HI00HI',CASE mover WHEN 1 THEN '2r' WHEN 0 THEN '2R' END), 
			'00HI',CASE mover WHEN 1 THEN 'r' WHEN 0 THEN 'R' END), 
			'00KY00KY00KY00KY',CASE mover WHEN 1 THEN '4l' WHEN 0 THEN '4L' END), 
			'00KY00KY00KY',CASE mover WHEN 1 THEN '3l' WHEN 0 THEN '3L' END), 
			'00KY00KY',CASE mover WHEN 1 THEN '2l' WHEN 0 THEN '2L' END), 
			'00KY',CASE mover WHEN 1 THEN 'l' WHEN 0 THEN 'L' END),''),CHAR(10),''),'-')) 
		FROM cte 
			; 
		INSERT INTO @kyokumen SELECT * FROM f_parseSFEN(@original_sfen) 
			; 
		INSERT INTO @moves_played (move_id,mover,koma,from_position,to_position,promoted,captured,csa,sfen,valid)
			SELECT	NULL,~@first_mover,NULL,NULL,NULL,NULL,NULL,NULL,@original_sfen,1
		INSERT INTO @moves_played(csa) 
		--SELECT ROW_NUMBER()OVER (ORDER BY (SELECT 0)),value --not sure how reliable this way of generating ids is so.. better rely on identity
		SELECT	[value] 
		FROM	STRING_SPLIT(@csa_moves,CHAR(10)) AS input 
		WHERE	LEFT([value],1) NOT IN ('''','','%') -- skip comments
			; 
		UPDATE	moves_played 
		SET		moves_played.mover = CASE LEFT(moves_played.csa,1) WHEN '+' THEN 0 WHEN '-' THEN 1 END 
			,	moves_played.from_position = CONVERT(SMALLINT,SUBSTRING(csa,2,2)) 
			,	moves_played.to_position = CONVERT(SMALLINT,SUBSTRING(csa,4,2)) 
			,	moves_played.koma = koma.koma_id 
		FROM	@moves_played AS moves_played 
		LEFT JOIN koma ON koma.CSA_abbr = RIGHT(moves_played.csa,2) 
			; 
		UPDATE	moves_played 
		SET		moves_played.move_id = moves._id 
			,	moves_played.promoted = CASE WHEN moves.promotion = 1 THEN 0 ELSE NULL END -- the piece could've undergone promotion but did not
		FROM	@moves_played AS moves_played 
		LEFT JOIN moves 
			ON	moves.koma=moves_played.koma AND moves.mover=moves_played.mover  
			AND	CASE WHEN moves_played.from_position BETWEEN 11 AND 99 THEN moves_played.from_position 
					ELSE moves.mover/*this is how drops are stored in moves table*/  
					END = moves.position 
			AND moves.moves=moves_played.to_position 
			AND ISNULL(moves.promotion,0)!=2 
			;
		-- NORMALIZE MOVES WHERE PIECE GETS PROMOTED TO THE WAY I STORE THAT INFO IN MOVES TABLE 
		UPDATE	update_this
		SET		promoted = moves.promotion,koma=before_promotion_koma 
		FROM	@moves_played update_this 
		JOIN	(	SELECT	before_promotion_move_number, before_promotion_koma
						,	promoted.koma promoted_koma	, MIN(promoted.move_number) promoted_move_number
					FROM	@moves_played promoted 
					JOIN	koma ON koma.koma_id=promoted.koma 
					OUTER APPLY ( 
							SELECT	MAX(before_promotion.move_number) before_promotion_move_number
								,	before_promotion.koma before_promotion_koma 
							FROM	@moves_played before_promotion 
							WHERE	before_promotion.koma = koma.promoted_from 
								AND	before_promotion.move_number<promoted.move_number 
								AND	before_promotion.to_position = promoted.from_position 
								AND	NOT EXISTS  
								(	SELECT	1 
									FROM	@moves_played piecemovedaway  
									WHERE	piecemovedaway.koma = before_promotion.koma 
										AND	piecemovedaway.from_position = before_promotion.to_position 
										AND	piecemovedaway.move_number BETWEEN before_promotion.move_number+1 AND promoted.move_number-1
								)
								AND	NOT EXISTS  
								(	SELECT	1 
									FROM	@moves_played piecegottaken
									WHERE	piecegottaken.mover = ~before_promotion.mover
										AND	piecegottaken.to_position = before_promotion.to_position
										AND	piecegottaken.move_number BETWEEN before_promotion.move_number+1 AND promoted.move_number-1
								)
							GROUP BY before_promotion.koma 
						) AS before_promotion 
					GROUP BY	promoted.koma,before_promotion_koma,before_promotion_move_number 
						HAVING	before_promotion_move_number IS NOT NULL 
				) AS update_vals 
			ON update_vals.promoted_move_number=update_this.move_number 
		JOIN	moves
			ON	moves.koma = before_promotion_koma
			AND	moves.mover=update_this.mover
			AND	CASE WHEN update_this.from_position BETWEEN 11 AND 99 
					 THEN update_this.from_position END = moves.position 
			AND	moves.moves=update_this.to_position 
			AND	moves.promotion IN (1,2) 
			;
		/*UPDATE moves_played -- this logic wasn't correct for normalizing promotion 
		SET moves_played.move_id = moves._id 
		, moves_played.promoted = moves.promotion 
		, moves_played.koma = koma.promoted_from -- this is just how I prefer storing info of moves that involved promotion 
		FROM @moves_played AS moves_played 
		JOIN koma on koma.koma_id = moves_played.koma AND koma.promoted_from IS NOT NULL 
		LEFT JOIN moves 
		ON moves.koma=koma.promoted_from AND moves.mover=moves_played.mover  
		AND CASE WHEN moves_played.from_position BETWEEN 11 AND 99 THEN moves.position END = moves.position 
		AND moves.moves=moves_played.to_position 
		AND moves.position=moves_played.from_position 
		AND moves.promotion IN (1,2)*/ 
		-- UPDATE MOVES' CORRECT MOVE_ID 
		UPDATE	moves_played 
		SET		moves_played.move_id = moves._id 
		FROM	@moves_played AS moves_played 
		JOIN	moves 
			ON	moves.koma = moves_played.koma AND moves.mover = moves_played.mover  
			AND	CASE WHEN moves_played.from_position BETWEEN 11 AND 99 THEN moves_played.from_position 
					ELSE moves.mover /*this is how drops are stored in moves table*/  
					END = moves.position
			AND	moves.moves=moves_played.to_position 
		WHERE	ISNULL(moves.promotion,0) IN (1,2) AND moves_played.promoted != 0 
			;
		UPDATE	@moves_played
		SET		valid = NULL 
		WHERE	NOT (valid = 1 AND csa= NULL AND move_number = 1) -- first move is original positions, which is already valid.. hopefully
			; 
		--INSERT INTO @moves_played SELECT * FROM f_validateCSA((select * from @moves_played))
	END --IF 
	RETURN 
		; 
	END
	;
GO

CREATE OR ALTER FUNCTION f_generateCSA (@moves_played moves_played_udt READONLY)
RETURNS VARCHAR(8000)
AS
	BEGIN
	DECLARE	@moves_played_working	moves_played_udt
		,	@csa					VARCHAR(8000)
		;
	INSERT INTO	@moves_played_working (move_number, move_id, mover, koma, from_position, to_position, csa )
		SELECT	move_number, move_id, mover, koma, from_position, to_position, csa FROM @moves_played ORDER BY move_id
		;
	UPDATE	@moves_played_working
		SET	csa = CASE mover WHEN 1 THEN '-' WHEN 0 THEN '+' END 
				+ CASE WHEN from_position > 100 OR from_position IN (0,1) 
					THEN '00' ELSE CONVERT(CHAR(2),from_position)
					END
				+ CONVERT(CHAR(2),to_position)
		WHERE ISNULL(LTRIM(RTRIM(csa)), '') = ''
		;
	SELECT @CSA = STRING_AGG(csa, char(13)+char(10)) WITHIN GROUP (ORDER BY move_number)
		FROM @moves_played_working
		;
	RETURN @CSA
	;
	END
	;
GO

