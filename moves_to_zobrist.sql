declare @moves_played_working moves_played_udt
insert into @moves_played_working select * from dbo.f_parseCSA(N'$EVENT:Contenti''s Study - Chapter 4
$SITE:https://lishogi.org/study/dkxSg6qS/UN4TuLA5
P1-KY-KE-GI-KI-OU-KI-GI-KE-KY
P2 * -HI *  *  *  *  * -KA * 
P3-FU-FU-FU-FU-FU-FU-FU-FU-FU
P4 *  *  *  *  *  *  *  *  * 
P5 *  *  *  *  *  *  *  *  * 
P6 *  *  *  *  *  *  *  *  * 
P7+FU+FU+FU+FU+FU+FU+FU+FU+FU
P8 * +KA *  *  *  *  * +HI * 
P9+KY+KE+GI+KI+OU+KI+GI+KE+KY
+
+1716FU
-1314FU
+1615FU
-2324FU
+1514FU
-2425FU
+1413TO
-1113KY
+1913KY
-2526FU
+1312NY
-2627TO
+2827HI
-2213KA
+1222NY
-3132GI
+2232NY
-1346KA
+0023GI
-2113KE
+2312NG
-4142KI
+1213NG
-3334FU
+3928GI
-4344FU
+2817GI
-3435FU
+1726GI
-4445FU
+2625GI
-5354FU
+2524GI
-5455FU
+2423GI
-6364FU
+2334GI
-6465FU
+3423GI
-5162OU
+0022FU
-6272OU
+0012FU
-6162KI
+0019KY
-7374FU
+0084KE')
declare @sfen nvarchar(256),@kyokumen kyokumentype,@move_number smallint,@next_mover bit
select @move_number=max(move_number)from @moves_played_working
SELECT mover,koma,from_position,~mover next_mover,0 move_number/*as in number of moves played.. or moves played+1 not sure.. yes bad name*/
from @moves_played_working where move_number in
(select min(original.move_number)move_number from @moves_played_working original group by original.mover,original.koma)
order by mover,koma,from_position
declare @tebangoterand bigint = convert(bigint,(select max(regval) from registry where regkey='teban_gote_rand'))
--select 'teban_gote_rand' regkey,convert(nvarchar(256),CONVERT(binary(8), NEWID()))regval into registry -- one-time insert made in registry
--select @tebangoterand,pseudorandom,@tebangoterand^pseudorandom from positions
declare @zobrist bigint=0
if exists (select 1 from @kyokumen where next_mover=1)set @zobrist=@zobrist^@tebangoterand
