DROP TABLE [joryuu_kishi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [joryuu_kishi](
	[_id] [float] NULL,
	[jsa_id] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[lpsa_id] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[lastname] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[firstname] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[jpname] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[rating] [int] NULL,
	[place] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[teacher] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[joined] [date] NULL,
	[retired] [date] NULL,
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
