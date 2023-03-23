DROP TABLE [positions]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [positions](
	[_id] [bigint] NULL,
	[mover] [bit] NULL,
	[koma] [int] NOT NULL,
	[position] [int] NULL,
	[max_pieces_allowed] [smallint] NULL,
	[pseudorandom] [bigint] NULL
) ON [PRIMARY]
GO
