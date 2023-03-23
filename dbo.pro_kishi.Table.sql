DROP TABLE [pro_kishi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [pro_kishi](
	[jsa_id] [int] NULL,
	[lastname] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[firstname] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[jpname] [nvarchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[rating] [int] NULL,
	[place] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[teacher] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[joined] [date] NULL,
	[retired] [date] NULL,
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
