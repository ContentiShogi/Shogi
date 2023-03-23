declare @sfen nvarchar(256)='3gkg3/9/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL w RB2S2N2L 1'
,@kyokumen kyokumentype,@move_number smallint,@next_mover bit

INSERT INTO @kyokumen select mover,koma,position,next_mover,move_number from dbo.f_parseSFEN(@sfen)
declare @zobrist bigint = 0; select @zobrist=dbo.f_generatezobrist(@kyokumen)
if not exists (select 1 from transpositions where zobrist=@zobrist)
insert into transpositions(zobrist) select @zobrist
--select zobrist from transpositions group by zobrist having count(*)>1
select * from transpositions