DECLARE @url_jsa_m nvarchar(256) = 'https://www.shogi.or.jp/player/pro/|query|.html'
	,	@url_jsa_f nvarchar(256) = 'https://www.shogi.or.jp/player/lady/|query|.html'
	,	@url_lpsa nvarchar(256) = 'https://joshi-shogi.com/|query|/'
	,	@url_shogidb nvarchar(256) = 'https://shogidb2.com/search?q=|query|'
	,  @dan nchar(1) = N'段', @kyuu nchar(1) = N'級', @joryuu nchar(2) = N'女流'
	, @meijin_title nvarchar(50) = N'名人'	, @joryuumeijin_title nvarchar(50) = N'女流名人'
    , @ryuuou_title nvarchar(50) = N'竜王'	, @joou_title nvarchar(50) = N'女王'
	, @kisei_title nvarchar(50) = N'棋聖'	, @kurashikitouka_title nvarchar(50) = N'倉敷藤花'
	, @oushou_title nvarchar(50) = N'王将'	, @joryuuoushou_title nvarchar(50) = N'女流王将'
	, @oui_title nvarchar(50) = N'王位'		, @joryuuoui_title nvarchar(50) = N'女流王位'
	, @ouza_title nvarchar(50) = N'王座'		, @joryuuouza_title nvarchar(50) = N'女流王座'
	, @kiou_title nvarchar(50) = N'棋王'		, @seirei_title nvarchar(50) = N'清麗'
	, @eiou_title nvarchar(50) = N'叡王'		, @hakurei_title nvarchar(50) = N'白玲'
	, @asahiopen_title nvarchar(50) = N'朝日オープン'	, @asahicup_title nvarchar(50) = N'朝日杯'
	, @sanshaBclass_title nvarchar(50) = N'三社杯B級', @meijinAclass_title nvarchar(50) = N'名人A級'
	, @gingasen_title nvarchar(50) = N'銀河戦', @japanseries_title nvarchar(50) = N'日本シリーズ'
	, @nhkcup_title nvarchar(50) = N'NHK杯', @nhkcup_f_title nvarchar(50) = N'女流棋士のNHK杯'
	, @kakogawaseiryuu_title nvarchar(50) = N'加古川青流', @kajimacup_title nvarchar(50) = N'鹿島杯'
	, @yamadachallenge_title nvarchar(50) = N'YAMADAチャレンジ', @yamadachallenge_f_title nvarchar(50) = N'YAMADA女流チャレンジ'
	, @ladiesopentourney_title nvarchar(50) = N'レディースオープン'
	;
select _id [#]
	,case 
	 when left(association,5) = 'JSA-M'AND jsa_id is not null THEN '=HYPERLINK("'+replace(@url_jsa_m,N'|query|',convert(nvarchar(10),jsa_id))+'", "'+association+'#'+convert(nvarchar(10),isnull(jsa_id,lpsa_id))+'")'
	 when left(association,5) = 'JSA-F'AND jsa_id is not null THEN '=HYPERLINK("'+replace(@url_jsa_f,N'|query|',convert(nvarchar(10),jsa_id))+'", "'+association+'#'+convert(nvarchar(10),isnull(jsa_id,lpsa_id))+'")'
	 when left(association,4) = 'LPSA'AND lpsa_id is not null THEN '=HYPERLINK("'
			+replace(@url_lpsa,N'|query|'
				, case when lpsa_id IN (1,3,19) then convert(nvarchar(10),lpsa_id+11499)
					when lpsa_id IN (4,6,20) then convert(nvarchar(10),lpsa_id+11501)
					when lpsa_id = 5 then convert(nvarchar(10),lpsa_id+11504)/*11507*/
					when lpsa_id IN (8,21) then convert(nvarchar(10),lpsa_id+11506)
					when lpsa_id = 9 then convert(nvarchar(10),lpsa_id+11507)/*11511*/
					when lpsa_id = 11 then convert(nvarchar(10),lpsa_id+11518)
					when lpsa_id = 12 then convert(nvarchar(10),lpsa_id+11519)
					when lpsa_id = 13 then convert(nvarchar(10),lpsa_id+11483)
					when lpsa_id = 15 then convert(nvarchar(10),lpsa_id+11509)
					when lpsa_id = 16 then convert(nvarchar(10),lpsa_id+11478)
					when lpsa_id = 18 then convert(nvarchar(10),lpsa_id+11473)
					when lpsa_id = 22 then convert(nvarchar(10),lpsa_id+18073)
					else ''
					end)
			+'", "'+association+'#'+convert(nvarchar(10),isnull(jsa_id,lpsa_id))+'")'
	 else association+'#'+convert(nvarchar(10),isnull(jsa_id,lpsa_id))
	 end as [ID]
	,'=HYPERLINK("'+replace(@url_shogidb,N'|query|',replace(ltrim(rtrim(kishi.jpname)),' ','+'))+'","'+kishi.jpname+'")' as [Games]
	,REPLACE(REPLACE(
		REPLACE(REPLACE(
			REPLACE(REPLACE(lastname+' '+firstname+' ' COLLATE SQL_Latin1_General_CP1_CS_AS,'Oo',N'Ō'),'oo',N'ō')
			,'Ou',N'Ō'),'ou',N'ō')
		,'uu',N'ū'),'Inōe','Inoue')	+
	case when isnull(eiou.current_holder,0)|isnull(meijin.current_holder,0)|isnull(ryuuou.current_holder,0)|isnull(kisei.current_holder,0)|isnull(oushou.current_holder,0)|isnull(oui.current_holder,0)|isnull(ouza.current_holder,0)|isnull(kiou.current_holder,0)
		|isnull(hakurei.current_holder,0)|isnull(joryuumeijin.current_holder,0)|isnull(kurashikitouka.current_holder,0)|isnull(joryuuoushou.current_holder,0)|isnull(joou.current_holder,0)|isnull(joryuuoui.current_holder,0)|isnull(seirei.current_holder,0)|isnull(joryuuouza.current_holder,0)=1
	then N'・' 
      +replace(replace(convert(nchar(1),isnull(ryuuou.current_holder,0)),'0',''),'1',@ryuuou_title+N'・')
	  +replace(replace(convert(nchar(1),isnull(joou.current_holder,0)),'0',''),'1',@joou_title+N'・')
	  +replace(replace(convert(nchar(1),isnull(meijin.current_holder,0)),'0',''),'1',@meijin_title+ N'・')
	  +replace(replace(convert(nchar(1),isnull(joryuumeijin.current_holder,0)),'0',''),'1',@joryuumeijin_title+N'・')
	  +replace(replace(convert(nchar(1),isnull(oui.current_holder,0)),'0',''),'1',@oui_title+N'・')
	  +replace(replace(convert(nchar(1),isnull(joryuuoui.current_holder,0)),'0',''),'1',@joryuuoui_title+N'・')
	  +replace(replace(convert(nchar(1),isnull(eiou.current_holder,0)),'0',''),'1',@eiou_title+N'・')
	  +replace(replace(convert(nchar(1),isnull(hakurei.current_holder,0)),'0',''),'1',@hakurei_title+N'・')
	  +replace(replace(convert(nchar(1),isnull(ouza.current_holder,0)),'0',''),'1',@ouza_title+N'・')
	  +replace(replace(convert(nchar(1),isnull(joryuuouza.current_holder,0)),'0',''),'1',@joryuuouza_title+N'・')
	  +replace(replace(convert(nchar(1),isnull(kiou.current_holder,0)),'0',''),'1',@kiou_title+N'・')
	  +replace(replace(convert(nchar(1),isnull(seirei.current_holder,0)),'0',''),'1',@seirei_title+N'・')
	  +replace(replace(convert(nchar(1),isnull(oushou.current_holder,0)),'0',''),'1',@oushou_title+N'・')
	  +replace(replace(convert(nchar(1),isnull(joryuuoushou.current_holder,0)),'0',''),'1',@joryuuoushou_title+N'・')
	  +replace(replace(convert(nchar(1),isnull(kisei.current_holder,0)),'0',''),'1',@kisei_title+N'・')
	  +replace(replace(convert(nchar(1),isnull(kurashikitouka.current_holder,0)),'0',''),'1',@kurashikitouka_title+N'・')
	else CASE WHEN association in ('LPSA','JSA-F') THEN @joryuu+N' ' ELSE N'' END + convert(nvarchar(5),abs(rating)) +	case when rating>=0 then @dan else @kyuu end end
	AS [Kishi]
	,REPLACE(REPLACE(
		REPLACE(REPLACE(
			REPLACE(REPLACE(Place COLLATE SQL_Latin1_General_CP1_CS_AS,'Oo',N'Ō'),'oo',N'ō')
			,'Ou',N'Ō'),'ou',N'ō')
		,'uu',N'ū'),'Inōe','Inoue') as Place
	,REPLACE(REPLACE(
		REPLACE(REPLACE(
			REPLACE(REPLACE(Teacher COLLATE SQL_Latin1_General_CP1_CS_AS,'Oo',N'Ō'),'oo',N'ō')
			,'Ou',N'Ō'),'ou',N'ō')
		,'uu',N'ū'),'Inōe','Inoue') as Teacher
	,Joined,Retired
	,NULLIF(convert(int,isnull(eiou.number_of_times_won,0))+convert(int,isnull(meijin.number_of_times_won,0))+convert(int,isnull(ryuuou.number_of_times_won,0))+convert(int,isnull(kisei.number_of_times_won,0))+convert(int,isnull(oushou.number_of_times_won,0))+convert(int,isnull(oui.number_of_times_won,0))+convert(int,isnull(ouza.number_of_times_won,0))+convert(int,isnull(kiou.number_of_times_won,0))
		+convert(int,isnull(hakurei.number_of_times_won,0))+convert(int,isnull(joryuumeijin.number_of_times_won,0))+convert(int,isnull(kurashikitouka.number_of_times_won,0))+convert(int,isnull(joryuuoushou.number_of_times_won,0))+convert(int,isnull(joou.number_of_times_won,0))+convert(int,isnull(joryuuoui.number_of_times_won,0))+convert(int,isnull(seirei.number_of_times_won,0))+convert(int,isnull(joryuuouza.number_of_times_won,0))
		,0) as [Number_of_Titles]

	--,	case when isnull(eiou.number_of_times_won,0)+isnull(meijin.number_of_times_won,0)+isnull(ryuuou.number_of_times_won,0)+isnull(kisei.number_of_times_won,0)+isnull(oushou.number_of_times_won,0)+isnull(oui.number_of_times_won,0)+isnull(ouza.number_of_times_won,0)+isnull(kiou.number_of_times_won,0)+isnull(hakurei.number_of_times_won,0)+isnull(joryuumeijin.number_of_times_won,0)+isnull(kurashikitouka.number_of_times_won,0)+isnull(joryuuoushou.number_of_times_won,0)+isnull(joou.number_of_times_won,0)+isnull(joryuuoui.number_of_times_won,0)+isnull(seirei.number_of_times_won,0)+isnull(joryuuouza.number_of_times_won,0)>0
	--	then '=HYPERLINK("'
	--	+replace(@url_shogidb,N'|query|',replace(ltrim(rtrim(kishi.jpname)),' ','+'))+'","'+
	--	case when isnull(ryuuou.number_of_times_won,joou.number_of_times_won)>0 then convert(varchar(5),isnull(ryuuou.ryuuou_number,joou.joou_number))  + case when isnull(ryuuou.ryuuou_number,joou.joou_number) in (11,12,13) then 'th' else case isnull(ryuuou.ryuuou_number,joou.joou_number)%10 when 1 then 'st' when 2 then 'nd' when 3 then 'rd' else 'th' end end + isnull(N' '+@ryuuou_title+' ('+ convert(nvarchar(5),ryuuou.number_of_times_won)+')','')+isnull(N' '+@joou_title+' ('+convert(nvarchar(5),joou.number_of_times_won)+')','') else ''end
	--	+'")'else '' end AS [ryuuou / joou]
	--,	case when isnull(eiou.number_of_times_won,0)+isnull(meijin.number_of_times_won,0)+isnull(ryuuou.number_of_times_won,0)+isnull(kisei.number_of_times_won,0)+isnull(oushou.number_of_times_won,0)+isnull(oui.number_of_times_won,0)+isnull(ouza.number_of_times_won,0)+isnull(kiou.number_of_times_won,0)+isnull(hakurei.number_of_times_won,0)+isnull(joryuumeijin.number_of_times_won,0)+isnull(kurashikitouka.number_of_times_won,0)+isnull(joryuuoushou.number_of_times_won,0)+isnull(joou.number_of_times_won,0)+isnull(joryuuoui.number_of_times_won,0)+isnull(seirei.number_of_times_won,0)+isnull(joryuuouza.number_of_times_won,0)>0
	--	then '=HYPERLINK("'
	--	+replace(@url_shogidb,N'|query|',replace(ltrim(rtrim(kishi.jpname)),' ','+'))+'","'+
	--	case when isnull(meijin.number_of_times_won,joryuumeijin.number_of_times_won)>0 then convert(varchar(5),isnull(meijin.meijin_number,joryuumeijin.joryuumeijin_number))  + case when isnull(meijin.meijin_number,joryuumeijin.joryuumeijin_number) in (11,12,13) then 'th' else case isnull(meijin.meijin_number,joryuumeijin.joryuumeijin_number)%10 when 1 then 'st' when 2 then 'nd' when 3 then 'rd' else 'th' end end + isnull(N' '+@meijin_title+' ('+ convert(nvarchar(5),meijin.number_of_times_won)+')','')+isnull(N' '+@joryuumeijin_title+' ('+convert(nvarchar(5),joryuumeijin.number_of_times_won)+')','') else ''end 
	--	+'")'else '' end AS [meijin / joryuumeijin]
	--,	case when isnull(eiou.number_of_times_won,0)+isnull(meijin.number_of_times_won,0)+isnull(ryuuou.number_of_times_won,0)+isnull(kisei.number_of_times_won,0)+isnull(oushou.number_of_times_won,0)+isnull(oui.number_of_times_won,0)+isnull(ouza.number_of_times_won,0)+isnull(kiou.number_of_times_won,0)+isnull(hakurei.number_of_times_won,0)+isnull(joryuumeijin.number_of_times_won,0)+isnull(kurashikitouka.number_of_times_won,0)+isnull(joryuuoushou.number_of_times_won,0)+isnull(joou.number_of_times_won,0)+isnull(joryuuoui.number_of_times_won,0)+isnull(seirei.number_of_times_won,0)+isnull(joryuuouza.number_of_times_won,0)>0
	--	then '=HYPERLINK("'
	--	+replace(@url_shogidb,N'|query|',replace(ltrim(rtrim(kishi.jpname)),' ','+'))+'","'+
	--	case when isnull(oui.number_of_times_won,joryuuoui.number_of_times_won)>0 then convert(varchar(5),isnull(oui.oui_number,joryuuoui.joryuuoui_number))  + case when isnull(oui.oui_number,joryuuoui.joryuuoui_number) in (11,12,13) then 'th' else case isnull(oui.oui_number,joryuuoui.joryuuoui_number)%10 when 1 then 'st' when 2 then 'nd' when 3 then 'rd' else 'th' end end + isnull(N' '+@oui_title+' ('+ convert(nvarchar(5),oui.number_of_times_won)+')','')+isnull(N' '+@joryuuoui_title+' ('+convert(nvarchar(5),joryuuoui.number_of_times_won)+')','') else ''end
	--	+'")'else '' end AS [oui / joryuuoui]
	--,	case when isnull(eiou.number_of_times_won,0)+isnull(meijin.number_of_times_won,0)+isnull(ryuuou.number_of_times_won,0)+isnull(kisei.number_of_times_won,0)+isnull(oushou.number_of_times_won,0)+isnull(oui.number_of_times_won,0)+isnull(ouza.number_of_times_won,0)+isnull(kiou.number_of_times_won,0)+isnull(hakurei.number_of_times_won,0)+isnull(joryuumeijin.number_of_times_won,0)+isnull(kurashikitouka.number_of_times_won,0)+isnull(joryuuoushou.number_of_times_won,0)+isnull(joou.number_of_times_won,0)+isnull(joryuuoui.number_of_times_won,0)+isnull(seirei.number_of_times_won,0)+isnull(joryuuouza.number_of_times_won,0)>0
	--	then '=HYPERLINK("'
	--	+replace(@url_shogidb,N'|query|',replace(ltrim(rtrim(kishi.jpname)),' ','+'))+'","'+
	--	case when isnull(eiou.number_of_times_won,hakurei.number_of_times_won)>0 then convert(varchar(5),isnull(eiou.eiou_number,hakurei.hakurei_number))  + case when isnull(eiou.eiou_number,hakurei.hakurei_number) in (11,12,13) then 'th' else case isnull(eiou.eiou_number,hakurei.hakurei_number)%10 when 1 then 'st' when 2 then 'nd' when 3 then 'rd' else 'th' end end + isnull(N' '+@eiou_title+' ('+ convert(nvarchar(5),eiou.number_of_times_won)+')','')+isnull(N' '+@hakurei_title+' ('+convert(nvarchar(5),hakurei.number_of_times_won)+')','') else ''end 
	--	+'")'else '' end AS [eiou / hakurei]
	--,	case when isnull(eiou.number_of_times_won,0)+isnull(meijin.number_of_times_won,0)+isnull(ryuuou.number_of_times_won,0)+isnull(kisei.number_of_times_won,0)+isnull(oushou.number_of_times_won,0)+isnull(oui.number_of_times_won,0)+isnull(ouza.number_of_times_won,0)+isnull(kiou.number_of_times_won,0)+isnull(hakurei.number_of_times_won,0)+isnull(joryuumeijin.number_of_times_won,0)+isnull(kurashikitouka.number_of_times_won,0)+isnull(joryuuoushou.number_of_times_won,0)+isnull(joou.number_of_times_won,0)+isnull(joryuuoui.number_of_times_won,0)+isnull(seirei.number_of_times_won,0)+isnull(joryuuouza.number_of_times_won,0)>0
	--	then '=HYPERLINK("'
	--	+replace(@url_shogidb,N'|query|',replace(ltrim(rtrim(kishi.jpname)),' ','+'))+'","'+
	--	case when isnull(ouza.number_of_times_won,joryuuouza.number_of_times_won)>0 then convert(varchar(5),isnull(ouza.ouza_number,joryuuouza.joryuuouza_number))  + case when isnull(ouza.ouza_number,joryuuouza.joryuuouza_number) in (11,12,13) then 'th' else case isnull(ouza.ouza_number,joryuuouza.joryuuouza_number)%10 when 1 then 'st' when 2 then 'nd' when 3 then 'rd' else 'th' end end + isnull(N' '+@ouza_title+' ('+ convert(nvarchar(5),ouza.number_of_times_won)+')','')+isnull(N' '+@joryuuouza_title+' ('+convert(nvarchar(5),joryuuouza.number_of_times_won)+')','') else ''end 
	--	+'")'else '' end AS [ouza / joryuuouza]
	--,	case when isnull(eiou.number_of_times_won,0)+isnull(meijin.number_of_times_won,0)+isnull(ryuuou.number_of_times_won,0)+isnull(kisei.number_of_times_won,0)+isnull(oushou.number_of_times_won,0)+isnull(oui.number_of_times_won,0)+isnull(ouza.number_of_times_won,0)+isnull(kiou.number_of_times_won,0)+isnull(hakurei.number_of_times_won,0)+isnull(joryuumeijin.number_of_times_won,0)+isnull(kurashikitouka.number_of_times_won,0)+isnull(joryuuoushou.number_of_times_won,0)+isnull(joou.number_of_times_won,0)+isnull(joryuuoui.number_of_times_won,0)+isnull(seirei.number_of_times_won,0)+isnull(joryuuouza.number_of_times_won,0)>0
	--	then '=HYPERLINK("'
	--	+replace(@url_shogidb,N'|query|',replace(ltrim(rtrim(kishi.jpname)),' ','+'))+'","'+
	--	case when isnull(kiou.number_of_times_won,seirei.number_of_times_won)>0 then convert(varchar(5),isnull(kiou.kiou_number,seirei.seirei_number))  + case when isnull(kiou.kiou_number,seirei.seirei_number) in (11,12,13) then 'th' else case isnull(kiou.kiou_number,seirei.seirei_number)%10 when 1 then 'st' when 2 then 'nd' when 3 then 'rd' else 'th' end end + isnull(N' '+@kiou_title+' ('+ convert(nvarchar(5),kiou.number_of_times_won)+')','')+isnull(N' '+@seirei_title+' ('+convert(nvarchar(5),seirei.number_of_times_won)+')','') else ''end
	--	+'")'else '' end AS [kiou / seirei]
	--,	case when isnull(eiou.number_of_times_won,0)+isnull(meijin.number_of_times_won,0)+isnull(ryuuou.number_of_times_won,0)+isnull(kisei.number_of_times_won,0)+isnull(oushou.number_of_times_won,0)+isnull(oui.number_of_times_won,0)+isnull(ouza.number_of_times_won,0)+isnull(kiou.number_of_times_won,0)+isnull(hakurei.number_of_times_won,0)+isnull(joryuumeijin.number_of_times_won,0)+isnull(kurashikitouka.number_of_times_won,0)+isnull(joryuuoushou.number_of_times_won,0)+isnull(joou.number_of_times_won,0)+isnull(joryuuoui.number_of_times_won,0)+isnull(seirei.number_of_times_won,0)+isnull(joryuuouza.number_of_times_won,0)>0
	--	then '=HYPERLINK("'
	--	+replace(@url_shogidb,N'|query|',replace(ltrim(rtrim(kishi.jpname)),' ','+'))+'","'+
	--	case when isnull(oushou.number_of_times_won,joryuuoushou.number_of_times_won)>0 then convert(varchar(5),isnull(oushou.oushou_number,joryuuoushou.joryuuoushou_number))  + case when isnull(oushou.oushou_number,joryuuoushou.joryuuoushou_number) in (11,12,13) then 'th' else case isnull(oushou.oushou_number,joryuuoushou.joryuuoushou_number)%10 when 1 then 'st' when 2 then 'nd' when 3 then 'rd' else 'th' end end + isnull(N' '+@oushou_title+' ('+ convert(nvarchar(5),oushou.number_of_times_won)+')','')+isnull(N' '+@joryuuoushou_title+' ('+convert(nvarchar(5),joryuuoushou.number_of_times_won)+')','') else ''end 
	--	+'")'else '' end AS [oushou / joryuuoushou]
	--,	case when isnull(eiou.number_of_times_won,0)+isnull(meijin.number_of_times_won,0)+isnull(ryuuou.number_of_times_won,0)+isnull(kisei.number_of_times_won,0)+isnull(oushou.number_of_times_won,0)+isnull(oui.number_of_times_won,0)+isnull(ouza.number_of_times_won,0)+isnull(kiou.number_of_times_won,0)+isnull(hakurei.number_of_times_won,0)+isnull(joryuumeijin.number_of_times_won,0)+isnull(kurashikitouka.number_of_times_won,0)+isnull(joryuuoushou.number_of_times_won,0)+isnull(joou.number_of_times_won,0)+isnull(joryuuoui.number_of_times_won,0)+isnull(seirei.number_of_times_won,0)+isnull(joryuuouza.number_of_times_won,0)>0
	--	then '=HYPERLINK("'
	--	+replace(@url_shogidb,N'|query|',replace(ltrim(rtrim(kishi.jpname)),' ','+'))+'","'+
	--	case when isnull(kisei.number_of_times_won,kurashikitouka.number_of_times_won)>0 then convert(varchar(5),isnull(kisei.kisei_number,kurashikitouka.kurashikitouka_number))  + case when isnull(kisei.kisei_number,kurashikitouka.kurashikitouka_number) in (11,12,13) then 'th' else case isnull(kisei.kisei_number,kurashikitouka.kurashikitouka_number)%10 when 1 then 'st' when 2 then 'nd' when 3 then 'rd' else 'th' end end + isnull(N' '+@kisei_title+' ('+ convert(nvarchar(5),kisei.number_of_times_won)+')','')+isnull(N' '+@kurashikitouka_title+' ('+convert(nvarchar(5),kurashikitouka.number_of_times_won)+')','') else ''end 
	--	+'")'else '' end AS [kisei / kurashikitouka]
 , /*case when isnull(ryuuou.number_of_times_won,0)+isnull(joou.number_of_times_won,0)>0    then '=HYPERLINK("'    +replace(@url_shogidb,N'|query|',replace(ltrim(rtrim(kishi.jpname)),' ','+'))+'+'    +case when isnull(ryuuou.number_of_times_won,0) != 0 then @ryuuou_title+ N'戦' else @joou_title+ N'戦' end    +'","'+    */
		case when isnull(ryuuou.number_of_times_won,joou.number_of_times_won)>0 
			then convert(varchar(5),isnull(ryuuou.ryuuou_number,joou.joou_number))
				+ case when isnull(ryuuou.ryuuou_number,joou.joou_number) in (11,12,13)then 'th' 
					else case isnull(ryuuou.ryuuou_number,joou.joou_number)%10 
						when 1 then 'st' when 2 then 'nd' when 3 then 'rd' else 'th' end end 
				+ isnull(N' '+@ryuuou_title+' ('+ convert(nvarchar(5),ryuuou.number_of_times_won)+')','')
				+isnull(N' '+@joou_title+' ('+convert(nvarchar(5),joou.number_of_times_won)+') ','')else ''end /*   +'")'else '' end */+
		case when ladiesopentourney.number_of_times_won>0
			then convert(varchar(5),ladiesopentourney.ladiesopentourney_number) + case when ladiesopentourney.ladiesopentourney_number in (11,12,13) then 'th' else case ladiesopentourney.ladiesopentourney_number%10 when 1 then 'st' when 2 then 'nd' when 3 then 'rd' else 'th' end end
				+isnull(N' '+@ladiesopentourney_title+' ('+convert(nvarchar(5),ladiesopentourney.number_of_times_won)+')','')
				else ''end /*   +'")'else '' end */
		AS [ryuuou / joou]
 , /*case when isnull(meijin.number_of_times_won,0)+isnull(joryuumeijin.number_of_times_won,0)>0    then '=HYPERLINK("'    +replace(@url_shogidb,N'|query|',replace(ltrim(rtrim(kishi.jpname)),' ','+'))+'+'    +case when isnull(meijin.number_of_times_won,0) != 0 then @meijin_title+ N'戦' else @joryuumeijin_title+ N'戦' end    +'","'+    */
		case when isnull(meijin.number_of_times_won,joryuumeijin.number_of_times_won)>0 then convert(varchar(5),isnull(meijin.meijin_number,joryuumeijin.joryuumeijin_number))  + case when isnull(meijin.meijin_number,joryuumeijin.joryuumeijin_number) in (11,12,13) then 'th' else case isnull(meijin.meijin_number,joryuumeijin.joryuumeijin_number)%10 when 1 then 'st' when 2 then 'nd' when 3 then 'rd' else 'th' end end + isnull(N' '+@meijin_title+' ('+ convert(nvarchar(5),meijin.number_of_times_won)+')','')+isnull(N' '+@joryuumeijin_title+' ('+convert(nvarchar(5),joryuumeijin.number_of_times_won)+')','') else ''end /*   +'")'else '' end */
		AS [meijin / joryuumeijin]
 , /*case when isnull(oui.number_of_times_won,0)+isnull(joryuuoui.number_of_times_won,0)>0    then '=HYPERLINK("'    +replace(@url_shogidb,N'|query|',replace(ltrim(rtrim(kishi.jpname)),' ','+'))+'+'    +case when isnull(oui.number_of_times_won,0) != 0 then @oui_title+ N'戦' else @joryuuoui_title+ N'戦' end    +'","'+    */
		case when isnull(oui.number_of_times_won,joryuuoui.number_of_times_won)>0 then convert(varchar(5),isnull(oui.oui_number,joryuuoui.joryuuoui_number))  + case when isnull(oui.oui_number,joryuuoui.joryuuoui_number) in (11,12,13) then 'th' else case isnull(oui.oui_number,joryuuoui.joryuuoui_number)%10 when 1 then 'st' when 2 then 'nd' when 3 then 'rd' else 'th' end end + isnull(N' '+@oui_title+' ('+ convert(nvarchar(5),oui.number_of_times_won)+')','')+isnull(N' '+@joryuuoui_title+' ('+convert(nvarchar(5),joryuuoui.number_of_times_won)+')','') else ''end /*   +'")'else '' end */
		AS [oui / joryuuoui]
 , /*case when isnull(eiou.number_of_times_won,0)+isnull(hakurei.number_of_times_won,0)>0    then '=HYPERLINK("'    +replace(@url_shogidb,N'|query|',replace(ltrim(rtrim(kishi.jpname)),' ','+'))+'+'    +case when isnull(eiou.number_of_times_won,0) != 0 then @eiou_title+ N'戦' else @hakurei_title+ N'戦' end    +'","'+    */
		case when isnull(eiou.number_of_times_won,hakurei.number_of_times_won)>0 then convert(varchar(5),isnull(eiou.eiou_number,hakurei.hakurei_number))  + case when isnull(eiou.eiou_number,hakurei.hakurei_number) in (11,12,13) then 'th' else case isnull(eiou.eiou_number,hakurei.hakurei_number)%10 when 1 then 'st' when 2 then 'nd' when 3 then 'rd' else 'th' end end + isnull(N' '+@eiou_title+' ('+ convert(nvarchar(5),eiou.number_of_times_won)+')','')+isnull(N' '+@hakurei_title+' ('+convert(nvarchar(5),hakurei.number_of_times_won)+')','') else ''end /*   +'")'else '' end */
		AS [eiou / hakurei]
 , /*case when isnull(ouza.number_of_times_won,0)+isnull(joryuuouza.number_of_times_won,0)>0    then '=HYPERLINK("'    +replace(@url_shogidb,N'|query|',replace(ltrim(rtrim(kishi.jpname)),' ','+'))+'+'    +case when isnull(ouza.number_of_times_won,0) != 0 then @ouza_title+ N'戦' else @joryuuouza_title+ N'戦' end    +'","'+    */
		case when isnull(ouza.number_of_times_won,joryuuouza.number_of_times_won)>0 then convert(varchar(5),isnull(ouza.ouza_number,joryuuouza.joryuuouza_number))  + case when isnull(ouza.ouza_number,joryuuouza.joryuuouza_number) in (11,12,13) then 'th' else case isnull(ouza.ouza_number,joryuuouza.joryuuouza_number)%10 when 1 then 'st' when 2 then 'nd' when 3 then 'rd' else 'th' end end + isnull(N' '+@ouza_title+' ('+ convert(nvarchar(5),ouza.number_of_times_won)+')','')+isnull(N' '+@joryuuouza_title+' ('+convert(nvarchar(5),joryuuouza.number_of_times_won)+')','') else ''end /*   +'")'else '' end */
		AS [ouza / joryuuouza]
 , /*case when isnull(kiou.number_of_times_won,0)+isnull(seirei.number_of_times_won,0)>0    then '=HYPERLINK("'    +replace(@url_shogidb,N'|query|',replace(ltrim(rtrim(kishi.jpname)),' ','+'))+'+'    +case when isnull(kiou.number_of_times_won,0) != 0 then @kiou_title+ N'戦' else @seirei_title+ N'戦' end    +'","'+    */
		case when isnull(kiou.number_of_times_won,seirei.number_of_times_won)>0 then convert(varchar(5),isnull(kiou.kiou_number,seirei.seirei_number))  + case when isnull(kiou.kiou_number,seirei.seirei_number) in (11,12,13) then 'th' else case isnull(kiou.kiou_number,seirei.seirei_number)%10 when 1 then 'st' when 2 then 'nd' when 3 then 'rd' else 'th' end end + isnull(N' '+@kiou_title+' ('+ convert(nvarchar(5),kiou.number_of_times_won)+')','')+isnull(N' '+@seirei_title+' ('+convert(nvarchar(5),seirei.number_of_times_won)+')','') else ''end /*   +'")'else '' end */
		AS [kiou / seirei]
 , /*case when isnull(oushou.number_of_times_won,0)+isnull(joryuuoushou.number_of_times_won,0)>0    then '=HYPERLINK("'    +replace(@url_shogidb,N'|query|',replace(ltrim(rtrim(kishi.jpname)),' ','+'))+'+'    +case when isnull(oushou.number_of_times_won,0) != 0 then @oushou_title+ N'戦' else @joryuuoushou_title+ N'戦' end    +'","'+    */
		case when isnull(oushou.number_of_times_won,joryuuoushou.number_of_times_won)>0 then convert(varchar(5),isnull(oushou.oushou_number,joryuuoushou.joryuuoushou_number))  + case when isnull(oushou.oushou_number,joryuuoushou.joryuuoushou_number) in (11,12,13) then 'th' else case isnull(oushou.oushou_number,joryuuoushou.joryuuoushou_number)%10 when 1 then 'st' when 2 then 'nd' when 3 then 'rd' else 'th' end end + isnull(N' '+@oushou_title+' ('+ convert(nvarchar(5),oushou.number_of_times_won)+')','')+isnull(N' '+@joryuuoushou_title+' ('+convert(nvarchar(5),joryuuoushou.number_of_times_won)+')','') else ''end /*   +'")'else '' end */
		AS [oushou / joryuuoushou]
 , /*case when isnull(kisei.number_of_times_won,0)+isnull(kurashikitouka.number_of_times_won,0)>0    then '=HYPERLINK("'    +replace(@url_shogidb,N'|query|',replace(ltrim(rtrim(kishi.jpname)),' ','+'))+'+'    +case when isnull(kisei.number_of_times_won,0) != 0 then @kisei_title+ N'戦' else @kurashikitouka_title+ N'戦' end    +'","'+    */
		case when isnull(kisei.number_of_times_won,kurashikitouka.number_of_times_won)>0 then convert(varchar(5),isnull(kisei.kisei_number,kurashikitouka.kurashikitouka_number))  + case when isnull(kisei.kisei_number,kurashikitouka.kurashikitouka_number) in (11,12,13) then 'th' else case isnull(kisei.kisei_number,kurashikitouka.kurashikitouka_number)%10 when 1 then 'st' when 2 then 'nd' when 3 then 'rd' else 'th' end end + isnull(N' '+@kisei_title+' ('+ convert(nvarchar(5),kisei.number_of_times_won)+')','')+isnull(N' '+@kurashikitouka_title+' ('+convert(nvarchar(5),kurashikitouka.number_of_times_won)+')','') else ''end /*   +'")'else '' end */
		AS [kisei / kurashikitouka]
 , /*case when isnull(asahicup.number_of_times_won,0)+isnull(kurashikitouka.number_of_times_won,0)>0    then '=HYPERLINK("'    +replace(@url_shogidb,N'|query|',replace(ltrim(rtrim(kishi.jpname)),' ','+'))+'+'    +case when isnull(asahicup.number_of_times_won,0) != 0 then @asahicup_title+ N'戦' else @kurashikitouka_title+ N'戦' end    +'","'+    */
		case when asahicup.number_of_times_won>0 then convert(varchar(5),asahicup.asahicup_number) + case when asahicup.asahicup_number in (11,12,13) then 'th' else case asahicup.asahicup_number%10 when 1 then 'st' when 2 then 'nd' when 3 then 'rd' else 'th' end end + N' '+CASE WHEN asahicup.asahicup_number<=11 then @asahiopen_title else @asahicup_title end +' ('+ convert(nvarchar(5),asahicup.number_of_times_won)+')'else ''end /*   +'")'else '' end */
		AS [asahiopen / asahicup]
 , /*case when isnull(gingasen.number_of_times_won,0)+isnull(kurashikitouka.number_of_times_won,0)>0    then '=HYPERLINK("'    +replace(@url_shogidb,N'|query|',replace(ltrim(rtrim(kishi.jpname)),' ','+'))+'+'    +case when isnull(gingasen.number_of_times_won,0) != 0 then @gingasen_title+ N'戦' else @kurashikitouka_title+ N'戦' end    +'","'+    */
		case when gingasen.number_of_times_won>0 then convert(varchar(5),gingasen.gingasen_number) + case when gingasen.gingasen_number in (11,12,13) then 'th' else case gingasen.gingasen_number%10 when 1 then 'st' when 2 then 'nd' when 3 then 'rd' else 'th' end end + N' '+@gingasen_title +' ('+ convert(nvarchar(5),gingasen.number_of_times_won)+')'else ''end /*   +'")'else '' end */
		AS [gingasen]
 , /*case when isnull(nhkcup.number_of_times_won,0)+isnull(nhkcup_f.number_of_times_won,0)>0    then '=HYPERLINK("'    +replace(@url_shogidb,N'|query|',replace(ltrim(rtrim(kishi.jpname)),' ','+'))+'+'    +case when isnull(nhkcup.number_of_times_won,0) != 0 then @nhkcup_title+ N'戦' else @nhkcup_f_title+ N'戦' end    +'","'+    */
		case when isnull(nhkcup.number_of_times_won,nhkcup_f.number_of_times_won)>0 then convert(varchar(5),isnull(nhkcup.nhkcup_number,nhkcup_f.nhkcup_f_number))  + case when isnull(nhkcup.nhkcup_number,nhkcup_f.nhkcup_f_number) in (11,12,13) then 'th' else case isnull(nhkcup.nhkcup_number,nhkcup_f.nhkcup_f_number)%10 when 1 then 'st' when 2 then 'nd' when 3 then 'rd' else 'th' end end + isnull(N' '+@nhkcup_title+' ('+ convert(nvarchar(5),nhkcup.number_of_times_won)+')','')+isnull(N' '+@nhkcup_f_title+' ('+convert(nvarchar(5),nhkcup_f.number_of_times_won)+')','') else ''end /*   +'")'else '' end */
		AS [nhkcup / nhkcup_f]
 , /*case when isnull(japanseries.number_of_times_won,0)+isnull(kurashikitouka.number_of_times_won,0)>0    then '=HYPERLINK("'    +replace(@url_shogidb,N'|query|',replace(ltrim(rtrim(kishi.jpname)),' ','+'))+'+'    +case when isnull(japanseries.number_of_times_won,0) != 0 then @japanseries_title+ N'戦' else @kurashikitouka_title+ N'戦' end    +'","'+    */
		case when japanseries.number_of_times_won>0 then convert(varchar(5),japanseries.japanseries_number) + case when japanseries.japanseries_number in (11,12,13) then 'th' else case japanseries.japanseries_number%10 when 1 then 'st' when 2 then 'nd' when 3 then 'rd' else 'th' end end + N' '+@japanseries_title +' ('+ convert(nvarchar(5),japanseries.number_of_times_won)+')'else ''end /*   +'")'else '' end */
		AS [japanseries]
 , /*case when isnull(kakogawaseiryuu.number_of_times_won,0)+isnull(kurashikitouka.number_of_times_won,0)>0    then '=HYPERLINK("'    +replace(@url_shogidb,N'|query|',replace(ltrim(rtrim(kishi.jpname)),' ','+'))+'+'    +case when isnull(kakogawaseiryuu.number_of_times_won,0) != 0 then @kakogawaseiryuu_title+ N'戦' else @kurashikitouka_title+ N'戦' end    +'","'+    */
		case when kakogawaseiryuu.number_of_times_won>0 then convert(varchar(5),kakogawaseiryuu.kakogawaseiryuu_number) + case when kakogawaseiryuu.kakogawaseiryuu_number in (11,12,13) then 'th' else case kakogawaseiryuu.kakogawaseiryuu_number%10 when 1 then 'st' when 2 then 'nd' when 3 then 'rd' else 'th' end end + N' '+@kakogawaseiryuu_title +' ('+ convert(nvarchar(5),kakogawaseiryuu.number_of_times_won)+')'else ''end /*   +'")'else '' end */
		AS [kakogawaseiryuu]
 , /*case when isnull(yamadachallenge.number_of_times_won,0)+isnull(yamadachallenge_f.number_of_times_won,0)>0    then '=HYPERLINK("'    +replace(@url_shogidb,N'|query|',replace(ltrim(rtrim(kishi.jpname)),' ','+'))+'+'    +case when isnull(yamadachallenge.number_of_times_won,0) != 0 then @yamadachallenge_title+ N'戦' else @yamadachallenge_f_title+ N'戦' end    +'","'+    */
		case when isnull(yamadachallenge.number_of_times_won,yamadachallenge_f.number_of_times_won)>0 then convert(varchar(5),isnull(yamadachallenge.yamadachallenge_number,yamadachallenge_f.yamadachallenge_f_number))  + case when isnull(yamadachallenge.yamadachallenge_number,yamadachallenge_f.yamadachallenge_f_number) in (11,12,13) then 'th' else case isnull(yamadachallenge.yamadachallenge_number,yamadachallenge_f.yamadachallenge_f_number)%10 when 1 then 'st' when 2 then 'nd' when 3 then 'rd' else 'th' end end + isnull(N' '+@yamadachallenge_title+' ('+ convert(nvarchar(5),yamadachallenge.number_of_times_won)+')','')+isnull(N' '+@yamadachallenge_f_title+' ('+convert(nvarchar(5),yamadachallenge_f.number_of_times_won)+')','') else ''end /*   +'")'else '' end */
		AS [yamadachallenge / yamadachallenge_f]
 , /*case when isnull(kajimacup.number_of_times_won,0)+isnull(kurashikitouka.number_of_times_won,0)>0    then '=HYPERLINK("'    +replace(@url_shogidb,N'|query|',replace(ltrim(rtrim(kishi.jpname)),' ','+'))+'+'    +case when isnull(kajimacup.number_of_times_won,0) != 0 then @kajimacup_title+ N'戦' else @kurashikitouka_title+ N'戦' end    +'","'+    */
		case when kajimacup.number_of_times_won>0 then convert(varchar(5),kajimacup.kajimacup_number) + case when kajimacup.kajimacup_number in (11,12,13) then 'th' else case kajimacup.kajimacup_number%10 when 1 then 'st' when 2 then 'nd' when 3 then 'rd' else 'th' end end + N' '+@kajimacup_title +' ('+ convert(nvarchar(5),kajimacup.number_of_times_won)+')'else ''end /*   +'")'else '' end */
		AS [kajimacup]
from kishi
left join meijin on meijin.meijin_number = kishi.meijin and association = 'JSA-M'
left join ryuuou on ryuuou.ryuuou_number = kishi.joou_ryuuou and association = 'JSA-M'
left join kisei on kisei.kisei_number =kishi. kurashikitouka_kisei and association = 'JSA-M'
left join oushou on oushou.oushou_number = kishi.oushou and association = 'JSA-M'
left join oui on oui.oui_number = kishi.oui and association = 'JSA-M'
left join ouza on ouza.ouza_number =kishi. ouza and association = 'JSA-M'
left join kiou on kiou.kiou_number = kishi.seirei_kiou and association = 'JSA-M'
left join eiou on eiou.eiou_number =kishi. hakurei_eiou and association = 'JSA-M'
left join asahicup on asahicup.asahicup_number =kishi.asahicup and association = 'JSA-M'
left join gingasen on gingasen.gingasen_number =kishi.gingasen and association = 'JSA-M'
left join nhkcup on nhkcup.nhkcup_number = kishi.nhkcup and association = 'JSA-M'
left join yamadachallenge on yamadachallenge.yamadachallenge_number = kishi.yamadachallenge and association = 'JSA-M'
left join japanseries on japanseries.japanseries_number = kishi.japanseries and association = 'JSA-M'
left join kakogawaseiryuu on kakogawaseiryuu.kakogawaseiryuu_number =kishi.kakogawaseiryuu and association = 'JSA-M'
left join joryuumeijin on joryuumeijin.joryuumeijin_number = kishi.meijin and association in ('JSA-F','LPSA')
left join joou on joou.joou_number = kishi.joou_ryuuou and association in ('JSA-F','LPSA')
left join kurashikitouka on kurashikitouka.kurashikitouka_number =kishi. kurashikitouka_kisei and association in ('JSA-F','LPSA')
left join joryuuoushou on joryuuoushou.joryuuoushou_number = kishi.oushou and association in ('JSA-F','LPSA')
left join joryuuoui on joryuuoui.joryuuoui_number = kishi.oui and association in ('JSA-F','LPSA')
left join joryuuouza on joryuuouza.joryuuouza_number =kishi. ouza and association in ('JSA-F','LPSA')
left join seirei on seirei.seirei_number = kishi.seirei_kiou and association in ('JSA-F','LPSA')
left join hakurei on hakurei.hakurei_number =kishi. hakurei_eiou and association in ('JSA-F','LPSA')
left join nhkcup_f on nhkcup_f.nhkcup_f_number = kishi.nhkcup_f and association in('JSA-F','LPSA')
left join yamadachallenge_f on yamadachallenge_f.yamadachallenge_f_number = kishi.yamadachallenge_f and association in('JSA-F','LPSA')
left join kajimacup on kajimacup.kajimacup_number =kishi.kajimacup and association in('JSA-F','LPSA')
left join ladiesopentourney on ladiesopentourney.ladiesopentourney_number =kishi.ladiesopentourney and association in('JSA-F','LPSA')
order by kishi._id
/*
Highest_rating,RyuuOu_JoOu,Kisei_KurashikiTouka,Oushou_JoryuuOushou,Oui_JoryuuOui,Ouza_JoryuuOuza,KiOu_Seirei,EiOu_Hakurei)
drop if exists #prokishi 
select * into #prokishi from (values
('JSA-M','264','Toyoshima','Masayuki',null,'14thMeijin*1','10thRyuuOu*2','19thKisei*1',null,'14thOui*1',null,null,'3rdEiou*1')
,('JSA-M','307','Fujii','Souta',null,null,'11thRyuuOu*2','21stKisei*3','16thOushou*1','16thOui*3',null,null,'4thEiou*2')
,('JSA-F','16','Yauchi','Rieko','5dan','7thJoryuuMeijin*3','1stJoOu*2',null,null,'3rdJoryuuOui*1',null,null,null)
,('JSA-M','146','Shima','Akira','9dan',null,'1stRyuuOu*1',null,null,null,null,null,null)
,('JSA-F','21','Kai','Tomomi','5dan',null,'2ndJoOu*1','6thKurashikiTouka*2',null,'5thJoryuuOui*4',null,null,null)
,('JSA-M','175','Yoshiharu','Habu',null,'9thMeijin*9','2ndRyuuOu*7','15thKisei*16','10thOushou*12','10thOui*18','5thOuza*24','9thKiou*13',null)
,('JSA-F','26','Ueda','Hatsumi','4dan',null,'3rdJoOu*2',null,null,null,null,null,null)
,('JSA-M','131','Tanigawa','Kouji',null,'7thMeijin*5','3rdRyuuOu*4','14thKisei*4','9thOushou*4','7thOui*6','3rdOuza*1','6thKiou*3',null)
,('JSA-F','33','Kana','Satomi','6dan','8thJoryuuMeijin*12','4thJoOu*1','5thKurashikiTouka*13','8thJoryuuOushou*8','6thJoryuuOui*8','2ndJoryuuOuza*6','1stSeirei*3','2ndHakurei*1')
,('JSA-M','182','Satou','Yasumitsu',null,'10thMeijin*2','4thRyuuOu*1','18thKisei*6','11thOushou*2',null,null,'12thKiou*2',null)
,('JSA-F','67','Katou','Momoko','3dan',null,'5thJoOu*4',null,null,null,'1stJoryuuOuza*4','2ndSeirei*1',null)
,('JSA-M','198','Fujii','Takeshi',null,null,'5thRyuuOu*3',null,null,null,null,null,null)
,('JSA-F','73','Nishiyama','Tomoka','4dan',null,'6thJoOu*5',null,'10thJoryuuOushou*3',null,'3ndJoryuuOuza*1',null,'1stHakurei*1')
,('JSA-M','183','Moriuchi','Toshiyuki',null,'12thMeijin*8','6thRyuuOu*2',null,'12thOushou*1',null,null,'11thKiou*1',null)
,('JSA-M','235','Watanabe','Akira',null,'15thMeijin*3','7thRyuuOu*11','20thKisei*1','14thOushou*5',null,'6thOuza*1','15thKiou*10',null)
,('JSA-M','260','Itodani','Tetsurou',null,null,'8thRyuuOu*1',null,null,null,null,null,null)
,('JSA-M','255','Hirose','Akihito',null,null,'9thRyuuOu*1',null,null,'12thOui*1',null,null,null)
,('-','-1','Kinjirou','Sekine','8dan','0thMeijin*1',null,null,null,null,null,null,null)
,('JSA-M','194','Maruyama','Tadahisa',null,'11thMeijin*2',null,null,null,null,null,'10thKiou*1',null)
,('JSA-M','263','Satou','Amahiko',null,'13thMeijin*3',null,null,null,null,null,null,null)
,('LPSA','1','Takojima','Akiko','6dan','1stJoryuuMeijin*4',null,null,'1stJoryuuOushou*3',null,null,null,null)
,('JSA-M','2','Kimura','Yoshio','8dan','1stMeijin*8',null,null,null,null,null,null,null)
,('LPSA','3','Yamashita','Kazuko','5dan','2ndJoryuuMeijin*4',null,null,null,null,null,null,null)
,('JSA-M','11','Tsukada','Masao','10dan','2ndMeijin*2',null,null,null,null,null,null,null)
,('-','-1','Hayashiba','Naoko','5dan','3rdJoryuuMeijin*4',null,'1stKurashikiTouka*2','2ndJoryuuOushou*10',null,null,null,null)
,('JSA-M','26','Ooyama','Yasuharu','9dan','3rdMeijin*18',null,'1stKisei*16','2ndOushou*20','1stOui*12',null,null,null)
,('LPSA','7','Nakai','Hiroe','6dan','4thJoryuuMeijin*9',null,'3rdKurashikiTouka*3','4thJoryuuOushou*4','1stJoryuuOui*3',null,null,null)
,('JSA-M','18','Masuda','Kouzou','9dan','4thMeijin*2',null,null,'1stOushou*3',null,null,null,null)
,('JSA-F','7','Shimizu','Ichiyo','7dan','5thJoryuuMeijin*10',null,'2ndKurashikiTouka*10','3rdJoryuuOushou*6','2ndJoryuuOui*14',null,null,null)
,('JSA-M','92','Makoto','Nakahara','9dan','5thMeijin*15',null,'4thKisei*16','4thOushou*7','3rdOui*8','1stOuza*6','4thKiou*1',null)
,('JSA-F','9','Saida','Haruko','5dan','6thJoryuuMeijin*1',null,'4thKurashikiTouka*1','5thJoryuuOushou*2',null,null,null,null)
,('JSA-M','64','Katou','Hifumi','9dan','6thMeijin*1',null,null,'5thOushou*1','6thOui*1',null,'2ndKiou*2',null)
,('JSA-M','85','Yonenaga','Kunio','9dan','8thMeijin*1',null,'7thKisei*7','6thOushou*3','4thOui*1',null,'3rdKiou*5',null)
,('JSA-F','52','Itou','Sae','3dan','9thJoryuuMeijin*1',null,null,null,null,null,null,null)
,('JSA-M','207','Kubo','Toshiaki',null,null,null,null,'13thOushou*4',null,null,'13thKiou*3',null)
,('JSA-M','57','Futakami','Tatsuya','9dan',null,null,'2ndKisei*4','3rdOushou*1',null,null,null,null)
,('LPSA','10','Ishibashi','Sachio','4dan',null,null,null,'6thJoryuuOushou*1','4thJoryuuOui*2',null,null,null)
,('JSA-F','17','Chiba','Ryouko','4dan',null,null,null,'7thJoryuuOushou*2',null,null,null,null)
,('JSA-M','143','Nakamura','Osamu',null,null,null,null,'7thOushou*2',null,null,null,null)
,('JSA-M','147','Minami','Yoshikazu',null,null,null,'11thKisei*2','8thOushou*3',null,null,'8thKiou*2',null)
,('JSA-F','40','Kagawa','Manao','4dan',null,null,null,'9thJoryuuOushou*2',null,null,null,null)
,('JSA-M','284','Takami','Taichi','7dan',null,null,null,null,null,null,null,'1stEiou*1')
,('JSA-M','276','Nagase','Takuya',null,null,null,null,null,null,'9thOuza*4',null,'2ndEiou*1')
,('JSA-M','195','Gouda','Masataka',null,null,null,'17thKisei*2',null,'9thOui*1',null,'14thKiou*1',null)
,('JSA-M','86','Oouchi','Nobuyuki',null,null,null,null,null,null,null,'1stKiou*1',null)
,('JSA-M','93','Kiriyama','Kiyozumi',null,null,null,'10thKisei*3',null,null,null,'5thKiou*1',null)
,('JSA-M','142','Takahashi','Michio',null,null,null,null,null,'5thOui*3',null,'7thKiOu*1',null)
,('JSA-M','201','Fukaura','Kouichi',null,null,null,null,null,'11thOui*3',null,null,null)
,('JSA-M','278','Sugai','Tatsuya',null,null,null,null,null,'13thOui*1',null,null,null)
,('JSA-M','222','Kimura','Kazuki',null,null,null,null,null,'15thOui*1',null,null,null)
,('JSA-M','77','Naitou','Kunio','9dan',null,null,'5thKisei*2',null,'2ndOui*2',null,null,null)
,('LPSA','19','Watanabe','Mana','3dan',null,null,null,null,'7thJoryuuOui*1',null,null,null)
,('JSA-M','100','Mori','Keiji',null,null,null,'8thKisei*1',null,'8thOui*1',null,null,null)
,('-','-1','Amano','Souho','7dan',null,null,'0thKisei*1',null,null,null,null,null)
,('JSA-M','127','Tanaka','Torahiko',null,null,null,'12thKisei*1',null,null,null,null,null)
,('JSA-M','189','Yashiki','Nobuyuki',null,null,null,'13thKisei*3',null,null,null,null,null)
,('JSA-M','204','Miura','Hiroyuki',null,null,null,'16thKisei*1',null,null,null,null,null)
,('JSA-M','-1','Yamada','Michiyoshi','9dan',null,null,'3rdKisei*2',null,null,null,null,null)
,('JSA-M','66','Ariyoshi','Michio','9dan',null,null,'6thKisei*1',null,null,null,null,null)
,('JSA-M','99','Moriyasu','Hidemitsu',null,null,null,'9thKisei*1',null,null,null,null,null)
,('JSA-M','148','Tsukada','Yasuaki',null,null,null,null,null,null,'2ndOuza*1',null,null)
,('JSA-M','135','Fukusaki','Bungo',null,null,null,null,null,null,'4thOuza*1',null,null)
,('JSA-M','261','Nakamura','Taichi',null,null,null,null,null,null,'7thOuza*1',null,null)
,('JSA-M','286','Saitou','Shintarou',null,null,null,null,null,null,'8thOuza*1',null,null)
,('-','-1','Doi','Ichitarou','8dan',null,null,null,null,null,null,null,null)
,('-','-1','Sakata','Sankichi','8dan',null,null,null,null,null,null,null,null)
,('-','-1','Hanada','Choutarou','9dan',null,null,null,null,null,null,null,null)
,('JSA-M','3','Kaneko','Kingorou','9dan',null,null,null,null,null,null,null,null)
,('JSA-M','7','Oono','Gen''ichi','9dan',null,null,null,null,null,null,null,null)
,('JSA-M','14','Katou','Jirou','9dan',null,null,null,null,null,null,null,null)
,('JSA-M','25','Matsuda','Shigeyuki','9dan',null,null,null,null,null,null,null,null)
,('JSA-M','39','Hanamura','Genji','9dan',null,null,null,null,null,null,null,null)
,('JSA-M','123','Kobayashi','Kenji','9dan',null,null,null,null,null,null,null,null)
,('JSA-M','161','Morishita','Taku','9dan',null,null,null,null,null,null,null,null)
,('JSA-M','176','Nakata','Isao','8dan',null,null,null,null,null,null,null,null)
,('JSA-M','197','Sugimoto','Masataka','8dan',null,null,null,null,null,null,null,null)
,('JSA-M','210','Kubota','Yoshiyuki','7dan',null,null,null,null,null,null,null,null)
,('JSA-M','213','Suzuki','Daisuke','9dan',null,null,null,null,null,null,null,null)
,('JSA-M','220','Kondou','Masakazu','7dan',null,null,null,null,null,null,null,null)
)as t (Association,Number,Surname,Name,Highest_rating,Meijin_JoryuuMeijin,RyuuOu_JoOu,Kisei_KurashikiTouka,Oushou_JoryuuOushou,Oui_JoryuuOui,Ouza_JoryuuOuza,KiOu_Seirei,EiOu_Hakurei)
drop table if exists #joryuukishi 
Select * into #joryuukishi from #prokishi 
where association in ('JSA-F','LPSA') OR SURNAME='HAYASHIBA';
/*
drop table if exists hakurei
select	convert(int,left(EiOu_Hakurei,CHARINDEX('*',EiOu_Hakurei)-1))hakurei_number
,		convert(int,right(EiOu_Hakurei,len(EiOu_Hakurei)-CHARINDEX('*',EiOu_Hakurei)))number_of_times_won
into hakurei
from (select name,surname,highest_rating= 
			/*convert(int,*/replace(replace(replace(replace(
				replace(replace(replace(replace(replace(
					replace(replace(replace(replace(replace(highest_rating,'dan',''),'th',''),'nd',''),'rd',''),'st','')
				,'joryuumeijin',''),'joryuuoushou',''),'joryuuoui',''),'joryuuouza',''),'joou','')
			,'kurashikitouka',''),'seirei',''),'hakurei',''),'*','*')/*)*/
		,Meijin_JoryuuMeijin=/*convert(int,*/replace(replace(replace(replace(
				replace(replace(replace(replace(replace(
					replace(replace(replace(replace(replace(Meijin_JoryuuMeijin,'dan',''),'th',''),'nd',''),'rd',''),'st','')
				,'joryuumeijin',''),'joryuuoushou',''),'joryuuoui',''),'joryuuouza',''),'joou','')
			,'kurashikitouka',''),'seirei',''),'hakurei',''),'*','*')/*)*/
		,RyuuOu_JoOu=/*convert(int,*/replace(replace(replace(replace(
				replace(replace(replace(replace(replace(
					replace(replace(replace(replace(replace(RyuuOu_JoOu,'dan',''),'th',''),'nd',''),'rd',''),'st','')
				,'joryuumeijin',''),'joryuuoushou',''),'joryuuoui',''),'joryuuouza',''),'joou','')
			,'kurashikitouka',''),'seirei',''),'hakurei',''),'*','*')/*)*/
		,Kisei_KurashikiTouka=/*convert(int,*/replace(replace(replace(replace(
				replace(replace(replace(replace(replace(
					replace(replace(replace(replace(replace(Kisei_KurashikiTouka,'dan',''),'th',''),'nd',''),'rd',''),'st','')
				,'joryuumeijin',''),'joryuuoushou',''),'joryuuoui',''),'joryuuouza',''),'joou','')
			,'kurashikitouka',''),'seirei',''),'hakurei',''),'*','*')/*)*/
		,Oushou_JoryuuOushou=/*convert(int,*/replace(replace(replace(replace(
				replace(replace(replace(replace(replace(
					replace(replace(replace(replace(replace(Oushou_JoryuuOushou,'dan',''),'th',''),'nd',''),'rd',''),'st','')
				,'joryuumeijin',''),'joryuuoushou',''),'joryuuoui',''),'joryuuouza',''),'joou','')
			,'kurashikitouka',''),'seirei',''),'hakurei',''),'*','*')/*)*/
		,Oui_JoryuuOui=/*convert(int,*/replace(replace(replace(replace(
				replace(replace(replace(replace(replace(
					replace(replace(replace(replace(replace(Oui_JoryuuOui,'dan',''),'th',''),'nd',''),'rd',''),'st','')
				,'joryuumeijin',''),'joryuuoushou',''),'joryuuoui',''),'joryuuouza',''),'joou','')
			,'kurashikitouka',''),'seirei',''),'hakurei',''),'*','*')/*)*/
		,Ouza_JoryuuOuza=/*convert(int,*/replace(replace(replace(replace(
				replace(replace(replace(replace(replace(
					replace(replace(replace(replace(replace(Ouza_JoryuuOuza,'dan',''),'th',''),'nd',''),'rd',''),'st','')
				,'joryuumeijin',''),'joryuuoushou',''),'joryuuoui',''),'joryuuouza',''),'joou','')
			,'kurashikitouka',''),'seirei',''),'hakurei',''),'*','*')/*)*/
		,KiOu_Seirei=/*convert(int,*/replace(replace(replace(replace(
				replace(replace(replace(replace(replace(
					replace(replace(replace(replace(replace(KiOu_Seirei,'dan',''),'th',''),'nd',''),'rd',''),'st','')
				,'joryuumeijin',''),'joryuuoushou',''),'joryuuoui',''),'joryuuouza',''),'joou','')
			,'kurashikitouka',''),'seirei',''),'hakurei',''),'*','*')/*)*/
		,EiOu_Hakurei=/*convert(int,*/replace(replace(replace(replace(
				replace(replace(replace(replace(replace(
					replace(replace(replace(replace(replace(EiOu_Hakurei,'dan',''),'st',''),'nd',''),'rd',''),'th','')
				,'joryuumeijin',''),'joryuuoushou',''),'joryuuoui',''),'joryuuouza',''),'joou','')
			,'kurashikitouka',''),'seirei',''),'hakurei',''),'*','*')/*)*/
	from #joryuukishi  ) as joryuu
	where EiOu_Hakurei is not null
	order by hakurei_number
select * from hakurei
*/

select * from joryuumeijin order by 1
select * from kurashikitouka order by 1
select * from joou order by 1
select * from joryuuoushou order by 1
select * from joryuuoui order by 1
select * from joryuuouza order by 1
select * from seirei order by 1
select * from hakurei order by 1
--update #joryuukishi
--set meijin_joryuumeijin=convert(int,left(meijin_joryuumeijin,CHARINDEX('*',meijin_joryuumeijin)-1)),
--RyuuOu_JoOu=convert(int,left(RyuuOu_JoOu,CHARINDEX('*',RyuuOu_JoOu)-1)),
--Kisei_KurashikiTouka=convert(int,left(Kisei_KurashikiTouka,CHARINDEX('*',Kisei_KurashikiTouka)-1)),
--Oushou_JoryuuOushou=convert(int,left(Oushou_JoryuuOushou,CHARINDEX('*',Oushou_JoryuuOushou)-1)),
--Oui_JoryuuOui=convert(int,left(Oui_JoryuuOui,CHARINDEX('*',Oui_JoryuuOui)-1)),
--Ouza_JoryuuOuza=convert(int,left(Ouza_JoryuuOuza,CHARINDEX('*',Ouza_JoryuuOuza)-1)),
--KiOu_Seirei=convert(int,left(KiOu_Seirei,CHARINDEX('*',KiOu_Seirei)-1)),
--EiOu_Hakurei=convert(int,left(EiOu_Hakurei,CHARINDEX('*',EiOu_Hakurei)-1))
select * from joryuukishi

--select a,c,
--',a.'+a+'_number=b.'+a+'_number',
--',a.'+c+'_number=b.'+c+'_number'
----'left join '+a+' on '+a+'.'+a+'_number = '+b+'
----'isnull('+a+'.number_of_times_won,0)*9+
----','+b+',convert(int,left('+b+',CHARINDEX(''*'','+b+')-1))'+a+'_number,convert(int,right('+b+',len('+b+')-CHARINDEX(''*'','+b+')))number_of_times_won'
----',#joryuukishi.'+b+' '+a+'_number'
--from (values('joryuumeijin'),('joou'),('kurashikitouka'),('joryuuoushou'),('joryuuoui'),('joryuuouza'),('seirei'),('hakurei')
--)as a(a)
--join (values('meijin_joryuumeijin'),('RyuuOu_JoOu'),('Kisei_KurashikiTouka'),('Oushou_JoryuuOushou'),('Oui_JoryuuOui'),('Ouza_JoryuuOuza'),('KiOu_Seirei'),('EiOu_Hakurei')
--)as b(b)
--on right(b,len(a))=a--on left(b,len(a))=a
--join (values('meijin'),('ryuuou'),('kisei'),('oushou'),('oui'),('ouza'),('kiou'),('eiou')
--)as c(c)
--on left(b,len(c))=c

begin try
if exists (select 1 from #joryuukishi) drop table if exists joryuukishi
select 
row_number() over (order by 
isnull(joryuumeijin.number_of_times_won,0)*9+    
isnull(joou.number_of_times_won,0)*9+    
isnull(kurashikitouka.number_of_times_won,0)*9+    
isnull(joryuuoushou.number_of_times_won,0)*9+    
isnull(joryuuoui.number_of_times_won,0)*9+    
isnull(joryuuouza.number_of_times_won,0)*9+    
isnull(seirei.number_of_times_won,0)*9+    
isnull(hakurei.number_of_times_won,0)*9 desc) _id
,#joryuukishi.association,#joryuukishi.number assoc_number
,#joryuukishi.surname,#joryuukishi.name,#joryuukishi.highest_rating
,#joryuukishi.meijin_joryuumeijin joryuumeijin_number
,#joryuukishi.RyuuOu_JoOu joou_number
,#joryuukishi.Kisei_KurashikiTouka kurashikitouka_number
,#joryuukishi.Oushou_JoryuuOushou joryuuoushou_number
,#joryuukishi.Oui_JoryuuOui joryuuoui_number
,#joryuukishi.Ouza_JoryuuOuza joryuuouza_number
,#joryuukishi.KiOu_Seirei seirei_number
,#joryuukishi.EiOu_Hakurei hakurei_number
into joryuukishi
from #joryuukishi
left join joryuumeijin on joryuumeijin.joryuumeijin_number = meijin_joryuumeijin  
left join joou on joou.joou_number = RyuuOu_JoOu  
left join kurashikitouka on kurashikitouka.kurashikitouka_number = Kisei_KurashikiTouka  
left join joryuuoushou on joryuuoushou.joryuuoushou_number = Oushou_JoryuuOushou  
left join joryuuoui on joryuuoui.joryuuoui_number = Oui_JoryuuOui  
left join joryuuouza on joryuuouza.joryuuouza_number = Ouza_JoryuuOuza  
left join seirei on seirei.seirei_number = KiOu_Seirei  
left join hakurei on hakurei.hakurei_number = EiOu_Hakurei
drop table if exists #joryuukishi
end try
begin catch
drop table if exists joryuukishi
end catch
*/
/*
select name,surname,highest_rating
,meijin_joryuumeijin,convert(int,left(meijin_joryuumeijin,CHARINDEX('*',meijin_joryuumeijin)-1))meijin_number,convert(int,right(meijin_joryuumeijin,len(meijin_joryuumeijin)-CHARINDEX('*',meijin_joryuumeijin)))number_of_times_won
,RyuuOu_JoOu,convert(int,left(RyuuOu_JoOu,CHARINDEX('*',RyuuOu_JoOu)-1))ryuuou_number,convert(int,right(RyuuOu_JoOu,len(RyuuOu_JoOu)-CHARINDEX('*',RyuuOu_JoOu)))number_of_times_won
,Kisei_KurashikiTouka,convert(int,left(Kisei_KurashikiTouka,CHARINDEX('*',Kisei_KurashikiTouka)-1))kisei_number,convert(int,right(Kisei_KurashikiTouka,len(Kisei_KurashikiTouka)-CHARINDEX('*',Kisei_KurashikiTouka)))number_of_times_won
,Oushou_JoryuuOushou,convert(int,left(Oushou_JoryuuOushou,CHARINDEX('*',Oushou_JoryuuOushou)-1))oushou_number,convert(int,right(Oushou_JoryuuOushou,len(Oushou_JoryuuOushou)-CHARINDEX('*',Oushou_JoryuuOushou)))number_of_times_won
,Oui_JoryuuOui,convert(int,left(Oui_JoryuuOui,CHARINDEX('*',Oui_JoryuuOui)-1))oui_number,convert(int,right(Oui_JoryuuOui,len(Oui_JoryuuOui)-CHARINDEX('*',Oui_JoryuuOui)))number_of_times_won
,Ouza_JoryuuOuza,convert(int,left(Ouza_JoryuuOuza,CHARINDEX('*',Ouza_JoryuuOuza)-1))ouza_number,convert(int,right(Ouza_JoryuuOuza,len(Ouza_JoryuuOuza)-CHARINDEX('*',Ouza_JoryuuOuza)))number_of_times_won
,KiOu_Seirei,convert(int,left(KiOu_Seirei,CHARINDEX('*',KiOu_Seirei)-1))kiou_number,convert(int,right(KiOu_Seirei,len(KiOu_Seirei)-CHARINDEX('*',KiOu_Seirei)))number_of_times_won
,EiOu_Hakurei,convert(int,left(EiOu_Hakurei,CHARINDEX('*',EiOu_Hakurei)-1))eiou_number,convert(int,right(EiOu_Hakurei,len(EiOu_Hakurei)-CHARINDEX('*',EiOu_Hakurei)))number_of_times_won
from (select name,surname,highest_rating= 
			/*convert(int,*/replace(replace(replace(replace(
				replace(replace(replace(replace(replace(
					replace(replace(replace(replace(replace(highest_rating,'dan',''),'st',''),'nd',''),'rd',''),'th','')
				,'meijin',''),'oushou',''),'oui',''),'ouza',''),'ryuuou','')
			,'kisei',''),'kiou',''),'eiou',''),'*','*')/*)*/
		,Meijin_JoryuuMeijin=/*convert(int,*/replace(replace(replace(replace(
				replace(replace(replace(replace(replace(
					replace(replace(replace(replace(replace(Meijin_JoryuuMeijin,'dan',''),'st',''),'nd',''),'rd',''),'th','')
				,'meijin',''),'oushou',''),'oui',''),'ouza',''),'ryuuou','')
			,'kisei',''),'kiou',''),'eiou',''),'*','*')/*)*/
		,RyuuOu_JoOu=/*convert(int,*/replace(replace(replace(replace(
				replace(replace(replace(replace(replace(
					replace(replace(replace(replace(replace(RyuuOu_JoOu,'dan',''),'st',''),'nd',''),'rd',''),'th','')
				,'meijin',''),'oushou',''),'oui',''),'ouza',''),'ryuuou','')
			,'kisei',''),'kiou',''),'eiou',''),'*','*')/*)*/
		,Kisei_KurashikiTouka=/*convert(int,*/replace(replace(replace(replace(
				replace(replace(replace(replace(replace(
					replace(replace(replace(replace(replace(Kisei_KurashikiTouka,'dan',''),'st',''),'nd',''),'rd',''),'th','')
				,'meijin',''),'oushou',''),'oui',''),'ouza',''),'ryuuou','')
			,'kisei',''),'kiou',''),'eiou',''),'*','*')/*)*/
		,Oushou_JoryuuOushou=/*convert(int,*/replace(replace(replace(replace(
				replace(replace(replace(replace(replace(
					replace(replace(replace(replace(replace(Oushou_JoryuuOushou,'dan',''),'st',''),'nd',''),'rd',''),'th','')
				,'meijin',''),'oushou',''),'oui',''),'ouza',''),'ryuuou','')
			,'kisei',''),'kiou',''),'eiou',''),'*','*')/*)*/
		,Oui_JoryuuOui=/*convert(int,*/replace(replace(replace(replace(
				replace(replace(replace(replace(replace(
					replace(replace(replace(replace(replace(Oui_JoryuuOui,'dan',''),'st',''),'nd',''),'rd',''),'th','')
				,'meijin',''),'oushou',''),'oui',''),'ouza',''),'ryuuou','')
			,'kisei',''),'kiou',''),'eiou',''),'*','*')/*)*/
		,Ouza_JoryuuOuza=/*convert(int,*/replace(replace(replace(replace(
				replace(replace(replace(replace(replace(
					replace(replace(replace(replace(replace(Ouza_JoryuuOuza,'dan',''),'st',''),'nd',''),'rd',''),'th','')
				,'meijin',''),'oushou',''),'oui',''),'ouza',''),'ryuuou','')
			,'kisei',''),'kiou',''),'eiou',''),'*','*')/*)*/
		,KiOu_Seirei=/*convert(int,*/replace(replace(replace(replace(
				replace(replace(replace(replace(replace(
					replace(replace(replace(replace(replace(KiOu_Seirei,'dan',''),'st',''),'nd',''),'rd',''),'th','')
				,'meijin',''),'oushou',''),'oui',''),'ouza',''),'ryuuou','')
			,'kisei',''),'kiou',''),'eiou',''),'*','*')/*)*/
		,EiOu_Hakurei=/*convert(int,*/replace(replace(replace(replace(
				replace(replace(replace(replace(replace(
					replace(replace(replace(replace(replace(EiOu_Hakurei,'dan',''),'st',''),'nd',''),'rd',''),'th','')
				,'meijin',''),'oushou',''),'oui',''),'ouza',''),'ryuuou','')
			,'kisei',''),'kiou',''),'eiou',''),'*','*')/*)*/
	from #prokishi  ) as prokishi
select * from meijin order by 1
select * from ryuuou order by 1
select * from kisei order by 1
select * from oushou order by 1
select * from oui order by 1
select * from ouza order by 1
select * from kiou order by 1
select * from eiou order by 1
update #prokishi
set meijin_joryuumeijin=convert(int,left(meijin_joryuumeijin,CHARINDEX('*',meijin_joryuumeijin)-1)),
RyuuOu_JoOu=convert(int,left(RyuuOu_JoOu,CHARINDEX('*',RyuuOu_JoOu)-1)),
Kisei_KurashikiTouka=convert(int,left(Kisei_KurashikiTouka,CHARINDEX('*',Kisei_KurashikiTouka)-1)),
Oushou_JoryuuOushou=convert(int,left(Oushou_JoryuuOushou,CHARINDEX('*',Oushou_JoryuuOushou)-1)),
Oui_JoryuuOui=convert(int,left(Oui_JoryuuOui,CHARINDEX('*',Oui_JoryuuOui)-1)),
Ouza_JoryuuOuza=convert(int,left(Ouza_JoryuuOuza,CHARINDEX('*',Ouza_JoryuuOuza)-1)),
KiOu_Seirei=convert(int,left(KiOu_Seirei,CHARINDEX('*',KiOu_Seirei)-1)),
EiOu_Hakurei=convert(int,left(EiOu_Hakurei,CHARINDEX('*',EiOu_Hakurei)-1))
select * from #prokishi
update #prokishi set
highest_rating=convert(int,highest_rating),
meijin_joryuumeijin=convert(int,meijin_joryuumeijin),
RyuuOu_JoOu=convert(int,RyuuOu_JoOu),
Kisei_KurashikiTouka=convert(int,Kisei_KurashikiTouka),
Oushou_JoryuuOushou=convert(int,Oushou_JoryuuOushou),
Oui_JoryuuOui=convert(int,Oui_JoryuuOui),
Ouza_JoryuuOuza=convert(int,Ouza_JoryuuOuza),
KiOu_Seirei=convert(int,KiOu_Seirei),
EiOu_Hakurei=convert(int,EiOu_Hakurei)
select 
row_number() over (order by 
isnull(meijin.number_of_times_won,0)*9+
isnull(ryuuou.number_of_times_won,0)*8+
isnull(kisei.number_of_times_won,0)*7+
isnull(oushou.number_of_times_won,0)*6+
isnull(oui.number_of_times_won,0)*5+
isnull(kiou.number_of_times_won,0)*4+
isnull(ouza.number_of_times_won,0)*3+
isnull(eiou.number_of_times_won,0)*2+highest_rating desc) _id
,#prokishi.association,convert(int,#prokishi.number) assoc_number
,#prokishi.surname,#prokishi.name,convert(int,#prokishi.highest_rating)highest_rating,
convert(int,#prokishi.meijin_joryuumeijin) meijin_number,
convert(int,#prokishi.RyuuOu_JoOu) ryuuou_number,
convert(int,#prokishi.Kisei_KurashikiTouka) kisei_number,
convert(int,#prokishi.Oushou_JoryuuOushou) oushou_number,
convert(int,#prokishi.Oui_JoryuuOui) oui_number,
convert(int,#prokishi.Ouza_JoryuuOuza) ouza_number,
convert(int,#prokishi.KiOu_Seirei) kiou_number,
convert(int,#prokishi.EiOu_Hakurei) eiou_number
into prokishi
from #prokishi
left join meijin on meijin.meijin_number = meijin_joryuumeijin
left join ryuuou on ryuuou.ryuuou_number = RyuuOu_JoOu
left join kisei on kisei.kisei_number = Kisei_KurashikiTouka
left join oushou on oushou.oushou_number = Oushou_JoryuuOushou
left join oui on oui.oui_number = Oui_JoryuuOui
left join ouza on ouza.ouza_number = Ouza_JoryuuOuza
left join kiou on kiou.kiou_number = KiOu_Seirei
left join eiou on eiou.eiou_number = EiOu_Hakurei
select * from prokishi
*/
/*
--select joryuumeijin_number,* from joryuukishi where joryuumeijin_number is not null
select a.joryuumeijin_number ,* from joryuumeijin a
join  joryuukishi b on a.joryuumeijin_number = b.joryuumeijin_number
where current_holder=1; select *from joou a
join  joryuukishi b on a.joou_number = b.joou_number
where current_holder=1; select *from kurashikitouka a
join  joryuukishi b on a.kurashikitouka_number = b.kurashikitouka_number
where current_holder=1; select *from joryuuoushou a
join  joryuukishi b on a.joryuuoushou_number = b.joryuuoushou_number
where current_holder=1; select *from joryuuoui a
join  joryuukishi b on a.joryuuoui_number = b.joryuuoui_number
where current_holder=1; select *from joryuuouza a
join  joryuukishi b on a.joryuuouza_number = b.joryuuouza_number
where current_holder=1; select *from seirei a
join  joryuukishi b on a.seirei_number = b.seirei_number
where current_holder=1; select *from hakurei a
join  joryuukishi b on a.hakurei_number = b.hakurei_number
where current_holder=1; select *from meijin a
join prokishi  b on a.meijin_number = b.meijin_number
where current_holder=1; select *from ryuuou a
join prokishi  b on a.ryuuou_number = b.ryuuou_number
where current_holder=1; select *from kisei a
join prokishi  b on a.kisei_number = b.kisei_number
where current_holder=1; select *from oushou a
join prokishi  b on a.oushou_number = b.oushou_number
where current_holder=1; select *from oui a
join prokishi  b on a.oui_number = b.oui_number
where current_holder=1; select *from ouza a
join prokishi  b on a.ouza_number = b.ouza_number
where current_holder=1; select *from kiou a
join prokishi  b on a.kiou_number = b.kiou_number
where current_holder=1; select *from eiou a
join prokishi  b on a.eiou_number = b.eiou_number
where current_holder=1
--select
--'	,	case when isnull('+a+'.number_of_times_won,0)+isnull('+aa+'.number_of_times_won,0)>0
--		then ''=HYPERLINK("''
--		+replace(@url_shogidb,N''|query|'',replace(ltrim(rtrim(kishi.jpname)),'' '',''+''))+''+''
--		+case when isnull('+a+'.number_of_times_won,0) != 0 then @'+a+N'_title+ N''戦'' else @'+aa+N'_title+ N''戦'' end
--		+''","''+
--		case when isnull('+a+'.number_of_times_won,'+aa+'.number_of_times_won)>0 then convert(varchar(5),isnull('+a+'.'+a+'_number,'+aa+'.'+aa+'_number))  + case when isnull('+a+'.'+a+'_number,'+aa+'.'+aa+'_number) in (11,12,13) then ''th'' else case isnull('+a+'.'+a+'_number,'+aa+'.'+aa+'_number)%10 when 1 then ''st'' when 2 then ''nd'' when 3 then ''rd'' else ''th'' end end + isnull(N'' ''+@'+a+'_title+'' (''+ convert(nvarchar(5),'+a+'.number_of_times_won)+'')'','''')+isnull(N'' ''+@'+aa+'_title+'' (''+convert(nvarchar(5),'+aa+'.number_of_times_won)+'')'','''') else ''''end
--		+''")''else '''' end AS ['+a+' / '+aa+']'
--from (values
--	 ('ryuuou',N'竜王','joou',N'女王')
--	,('meijin',N'名人','joryuumeijin',N'女流名人')
--	,('oui',N'王位','joryuuoui',N'女流王位')
--	,('eiou',N'叡王','hakurei',N'白玲')
--	,('ouza',N'王座','joryuuouza',N'女流王座')
--	,('kiou',N'棋王','seirei',N'清麗')
--	,('oushou',N'王将','joryuuoushou',N'女流王将')
--	,('kisei',N'棋聖','kurashikitouka',N'倉敷藤花')
--)a(a,b,aa,bb)
*/

/*
select row_number()over (order by joined,_id,rating desc,association desc)_id,
case association when 0 then 'JSA-M' when 1 then 'LPSA' when 2 then 'JSA-F' end association
,jsa_id,lpsa_id,firstname,lastname,jpname,rating,place,teacher,joined,retired,
meijin, joou_ryuuou, kurashikitouka_kisei, oushou, oui, ouza, seirei_kiou, hakurei_eiou
from (
select 
case when lpsa_id is not null then 1
	when (jsa_id=43 and lpsa_id=17) or jsa_id is not null 
		or (lastname='Hayashi'and firstname='Mayumi')
		or (lastname='Murayama'and firstname='Yukiko')
		or (lastname='Hayashiba'and firstname='Naoko')
		or (lastname='Satou'and firstname='Hisako')
		or (lastname='Fukusaki'and firstname='Mutsumi')
	    or (lastname='Sugisaki'and firstname='Satoko') then 2 else 3 end
association,
_id,jsa_id,lpsa_id,firstname,lastname,jpname,rating,place,teacher,joined,retired,
joryuumeijin_number meijin,joou_number joou_ryuuou,kurashikitouka_number kurashikitouka_kisei,
joryuuoushou_number oushou,joryuuoui_number oui,joryuuouza_number ouza,
seirei_number seirei_kiou,hakurei_number hakurei_eiou
from joryuu_kishi
union all 
select 0 association,
jsa_id _id,jsa_id,NULL,firstname,lastname,jpname,rating,place,teacher,joined,retired,
meijin_number,ryuuou_number,kisei_number,oushou_number,oui_number,ouza_number,kiou_number,eiou_number
from pro_kishi)
as kishi(association,_id,jsa_id,lpsa_id,firstname,lastname,jpname,rating,place,teacher,joined,retired,
meijin, joou_ryuuou, kurashikitouka_kisei, oushou, oui, ouza, seirei_kiou, hakurei_eiou)
order by 1
*/

--drop table if exists #temp
--select yearr,
--	replace(replace(replace(replace(
--	replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
--	replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
--	replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
--	replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(jpname
--	,N'前名人',''),N'永世十段',''),N'十五世',''),N'八段',''),N'九段',''),N'(2)',''),N'(3)',''),N'(4)',''),N'棋聖',''),N'七段','')
--	,N'竜王',''),N'(5)',''),N'(6)',''),N'(7)',''),N'(8)',''),N'(9)',''),N'(10)',''),N'(11)',''),N'名人',''),N'棋王','')
--	,N'十段',''),N'女流',''),N'女王',''),N'倉敷藤花',''),N'王将',''),N'王位',''),N'王座',''),N'清麗',''),N'白玲',''),N'叡王','')
--	,N'一級',''),N'二級',''),N'六段',''),N'王位',''),N'二冠',''),N'三冠',''),N'四冠',''),N'五冠',''),N'六冠',''),N'七冠','')
--	,N'五段',''),N'四段',''),N'八冠',''),N'・','')jpname into #temp
--from (values
--)as a(yearr, jpname)
----alter table kishi add nhkcup int null
----select gingasen_number nhkcup_number,number_of_times_won,current_holder into nhkcup from gingasen;delete from nhkcup
--insert into nhkcup(nhkcup_number,number_of_times_won)
--select nhkcup_number,times from 
----update a set a.nhkcup=nhkcup.nhkcup_number from
--(select jpname,count(*)times,row_number()over(order by min(yearr))nhkcup_number from #temp group by jpname)nhkcup(jpname,times,nhkcup_number)
----(values

----)as nhkcup(jpname,times,nhkcup_number)
--join kishi a on a.jpname=nhkcup.jpname
