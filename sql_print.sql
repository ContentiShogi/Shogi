--DECLARE @sfen nvarchar(256)='7k1/9/7N1/6K2/9/9/9/9/9 b BG2P2rb3g4s3n4l16p 3'
----'ln5nl/2G2R+P2/kp2+S3p/p1Pp3p1/9/P1s5P/1P1P1+p3/2KS5/LN2rLPNB w BGS2P2g3p 92'
--declare @kyokumen dbo.kyokumentype
--insert into @kyokumen select mover,koma,position,next_mover,move_number from dbo.f_parseSFEN(@sfen)
CREATE OR ALTER FUNCTION f_printKyokumen (@kyokumen kyokumentype READONLY,@perspective bit=0)returns nvarchar(4000)as
begin
declare @next_mover bit,@move_number smallint
declare @board_gote nvarchar(4000),@board_sente nvarchar(4000)
declare @numbered_board_sente nvarchar(4000)=
N'	☖	9	8	7	6	5	4	3	2	1	☖	
	一	91	81	71	61	51	41	31	21	11	一	
	二	92	82	72	62	52	42	32	22	12	二	
	三	93	83	73	63	53	43	33	23	13	三	
	四	94	84	74	64	54	44	34	24	14	四	
	五	95	85	75	65	55	45	35	25	15	五	
	六	96	86	76	66	56	46	36	26	16	六	
	七	97	87	77	67	57	47	37	27	17	七	
	八	98	88	78	68	58	48	38	28	18	八	
	九	99	89	79	69	59	49	39	29	19	九	
	☗	9	8	7	6	5	4	3	2	1	☗	'
, @numbered_board_gote nvarchar(4000)=
N'	☗	1	2	3	4	5	6	7	8	9	☗	
	九	19	29	39	49	59	69	79	89	99	九	
	八	18	28	38	48	58	68	78	88	98	八	
	七	17	27	37	47	57	67	77	87	97	七	
	六	16	26	36	46	56	66	76	86	96	六	
	五	15	25	35	45	55	65	75	85	95	五	
	四	14	24	34	44	54	64	74	84	94	四	
	三	13	23	33	43	53	63	73	83	93	三	
	二	12	22	32	42	52	62	72	82	92	二	
	一	11	21	31	41	51	61	71	81	91	一	
	☖	1	2	3	4	5	6	7	8	9	☖	'

declare @gote_komadai nvarchar(4000)
			= N'		|1301|1302|1401|1402|1501|1502|1503|1504|1601|1602|1603|1604|1701|1702|1703|1704|1801|1802|1803|1804|1901|1902|1903|1904|1905|1906|1907|1908|1909|1910|1911|1912|1913|1914|1915|1916|1917|1918|~'
	,   @sente_komadai nvarchar(4000)
			= N'		|0301|0302|0401|0402|0501|0502|0503|0504|0601|0602|0603|0604|0701|0702|0703|0704|0801|0802|0803|0804|0901|0902|0903|0904|0905|0906|0907|0908|0909|0910|0911|0912|0913|0914|0915|0916|0917|0918|~'
--set komadai print variables
select @sente_komadai
	=	replace(replace(
			@sente_komadai,convert(nvarchar(1),komadai.mover)+convert(nvarchar(3),komadai.position)
		,isnull(koma.koma+
					case when komadai.komacount/10>0 then NCHAR(0x2080+komadai.komacount/10) else ''end+
					NCHAR(0x2080+komadai.komacount%10)
				,N'')),'||','|')
	, @gote_komadai
	=	replace(replace(
			@gote_komadai,convert(nvarchar(1),komadai.mover)+convert(nvarchar(3),komadai.position)
		,isnull(koma.koma+
					case when komadai.komacount/10>0 then NCHAR(0x2080+komadai.komacount/10) else ''end+
					NCHAR(0x2080+komadai.komacount%10)
				,N'')),'||','|')
from komadai
left join @kyokumen kyokumen on komadai.position=kyokumen.position and komadai.mover=kyokumen.mover
left join koma on koma.koma_id=kyokumen.koma	;
--set banmen print variables
select @board_sente=@numbered_board_sente,@board_gote=@numbered_board_gote
select @board_sente=replace(@board_sente,convert(nvarchar(2),masume),isnull(koma.koma+case when kyokumen.mover=1 then N'△'else ''end,N'')) 
	,  @board_gote=replace(@board_gote,convert(nvarchar(2),masume),isnull(koma.koma+case when kyokumen.mover=0 then N'▲'else ''end,N'')) 
from banmen
left join @kyokumen kyokumen on banmen.masume=kyokumen.position
left join koma on koma.koma_id=kyokumen.koma	;
--select @board_gote=reverse(replace(@board_sente,char(13)+char(10),char(10)+char(13)));
select @next_mover=next_mover from @kyokumen
select @move_number=max(move_number) from @kyokumen
set @gote_komadai
	=replace(replace(@gote_komadai,'~',replicate('	',9 -len(@gote_komadai)+len(replace(@gote_komadai,'|','')))+'~'),'|','	')
select @sente_komadai
	=replace(replace(@sente_komadai,'~',replicate('	',9 -len(@sente_komadai)+len(replace(@sente_komadai,'|','')))+'~'),'|','	')
set @gote_komadai = replace(@gote_komadai,'~',case when @next_mover=1 then N'手番' else N'手数:'+convert(nvarchar(5),@move_number) end)
set @sente_komadai = replace(@sente_komadai,'~',case when @next_mover=0 then N'手番' else N'手数:'+convert(nvarchar(5),@move_number) end)
declare @print nvarchar(4000)
if @perspective=0
	set @print = isnull(@gote_komadai
	+	char(13)+replace(@board_sente,char(13)+char(10),char(13))+char(13)
	+	@sente_komadai,@numbered_board_sente)
else
	set @print =  isnull(@sente_komadai
	+	char(13)+replace(@board_gote,char(13)+char(10),char(13))+char(13)
	+	@gote_komadai,@numbered_board_gote);
return @print;
end
go
CREATE OR ALTER FUNCTION f_printSFEN (@sfen nvarchar(256),@perspective bit=0)returns nvarchar(4000)as
begin
declare @next_mover bit,@move_number smallint,@kyokumen kyokumentype
insert into @kyokumen select * from dbo.f_parseSFEN(@sfen)
declare @board_gote nvarchar(4000),@board_sente nvarchar(4000)
declare @numbered_board_sente nvarchar(4000)=
N'	☖	9	8	7	6	5	4	3	2	1	☖	
	一	91	81	71	61	51	41	31	21	11	一	
	二	92	82	72	62	52	42	32	22	12	二	
	三	93	83	73	63	53	43	33	23	13	三	
	四	94	84	74	64	54	44	34	24	14	四	
	五	95	85	75	65	55	45	35	25	15	五	
	六	96	86	76	66	56	46	36	26	16	六	
	七	97	87	77	67	57	47	37	27	17	七	
	八	98	88	78	68	58	48	38	28	18	八	
	九	99	89	79	69	59	49	39	29	19	九	
	☗	9	8	7	6	5	4	3	2	1	☗	'
, @numbered_board_gote nvarchar(4000)=
N'	☗	1	2	3	4	5	6	7	8	9	☗	
	九	19	29	39	49	59	69	79	89	99	九	
	八	18	28	38	48	58	68	78	88	98	八	
	七	17	27	37	47	57	67	77	87	97	七	
	六	16	26	36	46	56	66	76	86	96	六	
	五	15	25	35	45	55	65	75	85	95	五	
	四	14	24	34	44	54	64	74	84	94	四	
	三	13	23	33	43	53	63	73	83	93	三	
	二	12	22	32	42	52	62	72	82	92	二	
	一	11	21	31	41	51	61	71	81	91	一	
	☖	1	2	3	4	5	6	7	8	9	☖	'

declare @gote_komadai nvarchar(4000)
			= N'		|1301|1302|1401|1402|1501|1502|1503|1504|1601|1602|1603|1604|1701|1702|1703|1704|1801|1802|1803|1804|1901|1902|1903|1904|1905|1906|1907|1908|1909|1910|1911|1912|1913|1914|1915|1916|1917|1918|~'
	,   @sente_komadai nvarchar(4000)
			= N'		|0301|0302|0401|0402|0501|0502|0503|0504|0601|0602|0603|0604|0701|0702|0703|0704|0801|0802|0803|0804|0901|0902|0903|0904|0905|0906|0907|0908|0909|0910|0911|0912|0913|0914|0915|0916|0917|0918|~'
--set komadai print variables
select @sente_komadai
	=	replace(replace(
			@sente_komadai,convert(nvarchar(1),komadai.mover)+convert(nvarchar(3),komadai.position)
		,isnull(koma.koma+
					case when komadai.komacount/10>0 then NCHAR(0x2080+komadai.komacount/10) else ''end+
					NCHAR(0x2080+komadai.komacount%10)
				,N'')),'||','|')
	, @gote_komadai
	=	replace(replace(
			@gote_komadai,convert(nvarchar(1),komadai.mover)+convert(nvarchar(3),komadai.position)
		,isnull(koma.koma+
					case when komadai.komacount/10>0 then NCHAR(0x2080+komadai.komacount/10) else ''end+
					NCHAR(0x2080+komadai.komacount%10)
				,N'')),'||','|')
from komadai
left join @kyokumen kyokumen on komadai.position=kyokumen.position and komadai.mover=kyokumen.mover
left join koma on koma.koma_id=kyokumen.koma	;
--set banmen print variables
select @board_sente=@numbered_board_sente,@board_gote=@numbered_board_gote
select @board_sente=replace(@board_sente,convert(nvarchar(2),masume),isnull(koma.koma+case when kyokumen.mover=1 then N'△'else ''end,N'')) 
	,  @board_gote=replace(@board_gote,convert(nvarchar(2),masume),isnull(koma.koma+case when kyokumen.mover=0 then N'▲'else ''end,N'')) 
from banmen
left join @kyokumen kyokumen on banmen.masume=kyokumen.position
left join koma on koma.koma_id=kyokumen.koma	;
--select @board_gote=reverse(replace(@board_sente,char(13)+char(10),char(10)+char(13)));
select @next_mover=next_mover from @kyokumen
select @move_number=max(move_number) from @kyokumen
set @gote_komadai
	=replace(replace(@gote_komadai,'~',replicate('	',9 -len(@gote_komadai)+len(replace(@gote_komadai,'|','')))+'~'),'|','	')
select @sente_komadai
	=replace(replace(@sente_komadai,'~',replicate('	',9 -len(@sente_komadai)+len(replace(@sente_komadai,'|','')))+'~'),'|','	')
set @gote_komadai = replace(@gote_komadai,'~',case when @next_mover=1 then N'手番' else N'手数:'+convert(nvarchar(5),@move_number) end)
set @sente_komadai = replace(@sente_komadai,'~',case when @next_mover=0 then N'手番' else N'手数:'+convert(nvarchar(5),@move_number) end)
declare @print nvarchar(4000)
if @perspective=0
	set @print = isnull(@gote_komadai
	+	char(13)+replace(@board_sente,char(13)+char(10),char(13))+char(13)
	+	@sente_komadai,@numbered_board_sente)
else
	set @print =  isnull(@sente_komadai
	+	char(13)+replace(@board_gote,char(13)+char(10),char(13))+char(13)
	+	@gote_komadai,@numbered_board_gote);
return @print;
end
go
create or alter PROCEDURE sp_replayCSA(@csa VARCHAR(8000))as
BEGIN
SET NOCOUNT ON;
declare @iter int=0,@maxiter int,@movesplayed moves_played_udt,@print nvarchar(4000)
insert into @movesplayed select move_number,move_id,mover,koma,from_position,to_position,promoted,captured,csa,sfen FROM DBO.f_parseCSA(@CSA,1)where valid=1
select @maxiter = count(*) from @movesplayed
while @iter<@maxiter
begin
set @iter=@iter+1
select @print=csa+char(13)+case when sfen is not null then replace(dbo.f_printSFEN(sfen,0),char(13),char(13)+'')else '-'end --replace(sfen,'/',nchar(10)+'		')
FROM @movesplayed where move_number=@iter
print @print
end
END