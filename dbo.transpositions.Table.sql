DROP TABLE [transpositions]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [transpositions](
	[_id] [bigint] IDENTITY(1,1) NOT NULL,
	[zobrist] [bigint] NOT NULL
) ON [PRIMARY]
GO
