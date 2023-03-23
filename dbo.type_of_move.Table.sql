DROP TABLE [type_of_move]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [type_of_move](
	[_id] [smallint] IDENTITY(1,1) NOT NULL,
	[movetype_name] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[movetype_desc] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[isillegal] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
