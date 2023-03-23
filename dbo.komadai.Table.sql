DROP TABLE [komadai]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [komadai](
	[position] [int] NULL,
	[mover] [bit] NULL,
	[koma] [int] NOT NULL,
	[komacount] [int] NULL,
	[sfen] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
