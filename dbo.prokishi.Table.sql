DROP TABLE [prokishi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [prokishi](
	[_id] [bigint] NULL,
	[association] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[assoc_number] [int] NULL,
	[surname] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[name] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[highest_rating] [int] NULL,
	[meijin_number] [int] NULL,
	[ryuuou_number] [int] NULL,
	[kisei_number] [int] NULL,
	[oushou_number] [int] NULL,
	[oui_number] [int] NULL,
	[ouza_number] [int] NULL,
	[kiou_number] [int] NULL,
	[eiou_number] [int] NULL
) ON [PRIMARY]
GO
