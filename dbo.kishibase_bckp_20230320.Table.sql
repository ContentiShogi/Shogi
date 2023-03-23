DROP TABLE [kishibase_bckp_20230320]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [kishibase_bckp_20230320](
	[#] [int] NULL,
	[Official_profile] [nvarchar](9) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Latest_info_@shogidata.info] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Games_name_in_JP] [nvarchar](11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Professional] [nvarchar](67) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Photo] [nvarchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Became_Pro_or_Joined_or_Born] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Retired_or_Withdrew_or_Passed_away] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Honors] [nvarchar](169) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Preferred_play_style] [nvarchar](137) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Meijin_or_Joryū_Meijin] [nvarchar](14) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Joō_or_Ryūō] [nvarchar](43) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Kisei_or_Kurashiki_Tōka] [nvarchar](14) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Ōi_or_Joryūōi] [nvarchar](52) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Joryūōza_or_Ōza] [nvarchar](13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Kiō_or_Seirei] [nvarchar](35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Joryūōshō_or_Ōshō] [nvarchar](14) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Hakurei_or_Eiō] [nvarchar](11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Totalmain] [nvarchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Totalall] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Totalother] [nvarchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Asahi_Open_or_Asahi_Cup] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Gingasen] [nvarchar](13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[NHK_cup_or_NHK_womens_cup] [nvarchar](18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Japan_series] [nvarchar](16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Past_tourneys] [nvarchar](90) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Rookie_or_Youth] [nvarchar](38) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Association] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Others] [nvarchar](248) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Place_of_birth_or_origin] [nvarchar](11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Master] [nvarchar](21) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Master_Student_Lineage] [nvarchar](154) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[On_the_internet] [nvarchar](260) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Other_or_Comments] [nvarchar](171) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
