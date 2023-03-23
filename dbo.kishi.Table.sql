DROP TABLE [kishi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [kishi](
	[_id] [bigint] NULL,
	[association] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[jsa_id] [int] NULL,
	[lpsa_id] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[firstname] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[lastname] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[jpname] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[rating] [int] NULL,
	[place] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[teacher] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[joined] [date] NULL,
	[retired] [date] NULL,
	[meijin] [int] NULL,
	[joou_ryuuou] [int] NULL,
	[kurashikitouka_kisei] [int] NULL,
	[oushou] [int] NULL,
	[oui] [int] NULL,
	[ouza] [int] NULL,
	[seirei_kiou] [int] NULL,
	[hakurei_eiou] [int] NULL,
	[hierarchy] [hierarchyid] NULL,
	[gingasen] [int] NULL,
	[asahicup] [int] NULL,
	[hayazashi] [int] NULL,
	[nhkcup] [int] NULL,
	[nhkcup_f] [int] NULL,
	[japanseries] [int] NULL,
	[alljapan_9dan_10dan] [int] NULL,
	[kakogawaseiryuu] [int] NULL,
	[yamadachallenge] [int] NULL,
	[yamadachallenge_f] [int] NULL,
	[kajimacup] [int] NULL,
	[ladiesopentourney] [int] NULL,
	[preferred_style] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
