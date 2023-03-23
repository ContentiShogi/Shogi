DROP TABLE [moves]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [moves](
	[mover] [bit] NULL,
	[koma] [int] NOT NULL,
	[position] [int] NULL,
	[moves] [int] NULL,
	[promotion] [smallint] NULL,
	[_id] [int] IDENTITY(1,1) NOT NULL,
	[movesuji] [int] NULL,
	[movedan] [int] NULL,
	[movekakupara] [int] NULL,
	[movekakuorth] [int] NULL,
	[bitmask] [int] NULL,
	[direction] [tinyint] NULL,
	[distance] [tinyint] NULL
) ON [PRIMARY]
GO
