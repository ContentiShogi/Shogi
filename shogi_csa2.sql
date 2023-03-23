CREATE OR ALTER FUNCTION f_validateCSA(@moves_played moves_played_udt READONLY)
RETURNS @moves_played_out TABLE 
	(	move_number INT
	,	move_id		SMALLINT	, mover			BIT
	,	koma		SMALLINT	, from_position	SMALLINT
	,	to_position	SMALLINT	, promoted		BIT
	,	captured	BIT			, csa			NVARCHAR(7)
	,	sfen		NVARCHAR(256), valid		BIT	) 
AS
	BEGIN
	DECLARE	@kyokumen dbo.kyokumentype
		;
	INSERT INTO @moves_played_out SELECT * FROM @moves_played
		;
	INSERT INTO @kyokumen SELECT * FROM f_parseSFEN((SELECT TOP 1 sfen FROM @moves_played_out WHERE move_number=1 AND sfen IS NOT NULL))
		;
	DECLARE	@maxiter INT = ( SELECT MAX(move_number) FROM @moves_played_out WHERE move_id IS NOT NULL )
		,	@iter			INT = 1
		,	@move_id		INT		,	@kyokumen_position	SMALLINT
		,	@kyokumen_koma	SMALLINT,	@kyokumen_mover		BIT
		,	@kyokumen_next_mover BIT,	@kyokumen_last_move	SMALLINT 
		,	@captured_koma	SMALLINT,	@moved_to			SMALLINT
		,	@moved_from		SMALLINT,	@promoted			SMALLINT
		,	@valid			BIT = 1	;
	--DECLARE @debug as table (iter int,sfen nvarchar(256),comment nvarchar(256))  
	WHILE (@iter < @maxiter) 
		BEGIN 
		SET @valid = 1 ;
		SELECT TOP 1 @iter = move_number, @move_id = move_id, @moved_from = from_position, @moved_to = to_position 
			FROM	@moves_played_out
			WHERE	move_id IS NOT NULL AND valid IS NULL
			ORDER BY move_number
			;
		--UPDATE moves_played SET valid= CASE WHEN kyokumen.position IS NULL THEN 0 ELSE 1 END 
		SELECT	@kyokumen_position = kyokumen.position	,	@kyokumen_koma = kyokumen.koma
			,	@kyokumen_mover = kyokumen.mover		,	@kyokumen_next_mover = kyokumen.next_mover
			,	@kyokumen_last_move = kyokumen.move_number
			,	@captured_koma = captures.koma --(edit: I do not recall/understand this comment)ISNULL(koma.promoted_from,captures.koma)--added logic to set captured as promoted from if captured piece is a promoted one -- somehow this single line slows down the whole proc, I have no idea why
			,	@promoted = moves_played.promoted 
			FROM	@moves_played_out moves_played 
			JOIN	moves 
				ON	moves._id=moves_played.move_id 
			LEFT JOIN	@kyokumen kyokumen
				ON	moves.koma = kyokumen.koma
				AND	moves.mover = kyokumen.mover
				AND	CASE WHEN moves.position IN (0,1) THEN moves.koma 
						ELSE moves.position END 
					 =	CASE WHEN moves.position IN (0,1) THEN kyokumen.position/100 ELSE kyokumen.position END 
			LEFT JOIN	@kyokumen captures 
				ON	captures.position = moves_played.to_position
				AND	captures.position BETWEEN 11 AND 99
				AND captures.mover = ~moves.mover 
			--LEFT JOIN koma ON koma.koma_id = captures.koma AND koma.promoted_from IS NOT NULL 
			WHERE	moves_played.move_number = @iter
			;
		--insert into @debug SELECT @iter,dbo.f_generateSFEN(@kyokumen,NULL,NULL),'before move update' 
		-- Cannot capture own piece
		IF EXISTS (SELECT 1 FROM @kyokumen kyokumen WHERE kyokumen.position = @moved_to AND kyokumen.mover = @kyokumen_mover)
			BEGIN
			SET @valid = 0 ;
			END
		--CAPTURES 
		IF @captured_koma IS NOT NULL 
			BEGIN 
			IF @captured_koma IN (1,2) SET @valid = 0; -- Can't capture king
			UPDATE moves_played 
				SET captured = CASE WHEN @captured_koma IS NOT NULL THEN 1 END 
				FROM @moves_played_out moves_played 
				WHERE moves_played.move_number = @iter 
				; 
			DECLARE @captured_koma_p INT
				;
			SELECT @captured_koma_p = ISNULL((SELECT TOP 1 promoted_from FROM koma (NOLOCK) WHERE koma_id = @captured_koma),@captured_koma)
				;
			-- give captured piece to capturer 
			UPDATE kyokumen 
				SET position = position + 1 
				FROM @kyokumen kyokumen  
				WHERE kyokumen.position/100 = ISNULL(@captured_koma_p,@captured_koma ) 
					AND kyokumen.koma = ISNULL(@captured_koma_p,@captured_koma ) 
					AND kyokumen.mover = @kyokumen_mover 
				IF (@@ROWCOUNT = 0) 
					BEGIN
					INSERT INTO @kyokumen(mover,koma,position) 
					SELECT @kyokumen_mover, ISNULL(@captured_koma_p,@captured_koma ), ISNULL(@captured_koma_p,@captured_koma )*100 + 1
					END
				;
			-- take captured piece away from capturee 
			DELETE @kyokumen WHERE koma = @captured_koma AND position = @moved_to AND mover = ~@kyokumen_mover 
				;
			--insert into @debug SELECT @iter,dbo.f_generateSFEN(@kyokumen,NULL,NULL),'after capture update' 
			END 
		--DROPS 
		IF @moved_from IN (0,1) 
			BEGIN 
			UPDATE kyokumen SET position = position - 1 
				FROM	@kyokumen kyokumen  
				WHERE	kyokumen.position = @kyokumen_position
					AND	kyokumen.koma = @kyokumen_koma
					AND	kyokumen.mover = @kyokumen_mover 
					AND	kyokumen.position%100 > 1--we don't want to subtract 1 from position like 901, we can just update it to where piece is dropped
				IF (@@ROWCOUNT = 0) 
				BEGIN
				UPDATE kyokumen SET position = @moved_to 
					FROM @kyokumen kyokumen 
					WHERE kyokumen.position = @kyokumen_koma*100+1 AND kyokumen.mover = @kyokumen_mover 
					; 
				END
			ELSE 
				BEGIN
				IF EXISTS (SELECT 1 FROM @kyokumen kyokumen WHERE kyokumen.position=@moved_to) OR @moved_to/100>1
					BEGIN
					SET @valid = 0 ;
					END ;
				INSERT INTO @kyokumen(mover,koma,position) 
					SELECT @kyokumen_mover, @kyokumen_koma, @moved_to
					;
				END
			--insert into @debug SELECT @iter,dbo.f_generateSFEN(@kyokumen,NULL,NULL),'after capture update,drops' 
			END 
		--PROMOTIONS 
		IF @promoted = 1 
			BEGIN 
			UPDATE	kyokumen 
				SET		kyokumen.position = @moved_to, kyokumen.koma = koma.koma_id 
				FROM	@kyokumen kyokumen 
				JOIN	koma ON koma.promoted_from = kyokumen.koma 
				WHERE	kyokumen.koma=@kyokumen_koma 
					AND	kyokumen.mover = @kyokumen_mover AND kyokumen.position = @kyokumen_position 
				; 
			--insert into @debug SELECT @iter,dbo.f_generateSFEN(@kyokumen,NULL,NULL),'after capture update,drops,promotions' 
			END 
		--POSITION UPDATE 
		UPDATE	kyokumen
			SET		kyokumen.position = @moved_to 
			FROM	@kyokumen kyokumen 
			WHERE	kyokumen.koma = @kyokumen_koma
				AND	kyokumen.mover = @kyokumen_mover
				AND	kyokumen.position = @kyokumen_position 
			;
		--insert into @debug SELECT @iter,dbo.f_generateSFEN(@kyokumen,NULL,NULL),'after capture update,drops,promotions,positions' 
		--FINAL UPDATE IN KYOKUMEN 
		IF (@kyokumen_position IS NULL) SET @valid = 0;
		UPDATE	moves_played 
			SET		valid = @valid
				,	captured = CASE WHEN @captured_koma IS NOT NULL THEN 1 END 
			FROM	@moves_played_out moves_played 
			WHERE	moves_played.move_number = @iter 
			;
		UPDATE	@kyokumen SET next_mover = ~@kyokumen_next_mover, move_number = @kyokumen_last_move+1 
			;
		--insert into @debug SELECT @iter,dbo.f_generateSFEN(@kyokumen,NULL,NULL),'end of loop:' 
		--select * from @debug where iter=@iter 
		UPDATE	@moves_played_out SET sfen=dbo.f_generateSFEN(@kyokumen,NULL,NULL) WHERE move_number = @iter ;
		END --WHILE 
	RETURN;
	END
	;