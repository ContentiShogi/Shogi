DROP TABLE [joryuukishi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [joryuukishi](
	[_id] [bigint] NULL,
	[association] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[assoc_number] [int] NULL,
	[surname] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[name] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[highest_rating] [int] NULL,
	[joryuumeijin_number] [int] NULL,
	[joou_number] [int] NULL,
	[kurashikitouka_number] [int] NULL,
	[joryuuoushou_number] [int] NULL,
	[joryuuoui_number] [int] NULL,
	[joryuuouza_number] [int] NULL,
	[seirei_number] [int] NULL,
	[hakurei_number] [int] NULL
) ON [PRIMARY]
GO
