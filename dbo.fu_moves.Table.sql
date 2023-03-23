DROP TABLE [fu_moves]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [fu_moves](
	[mover] [bit] NULL,
	[koma] [int] NOT NULL,
	[position] [int] NULL,
	[moves] [int] NULL,
	[promotion] [smallint] NULL,
	[_id] [int] IDENTITY(1,1) NOT NULL,
	[moves_id] [int] NULL
) ON [PRIMARY]
GO
