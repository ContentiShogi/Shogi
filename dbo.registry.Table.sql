DROP TABLE [registry]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [registry](
	[regkey] [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[regval] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
