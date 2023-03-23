DROP TABLE [koma]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [koma](
	[koma_id] [int] NOT NULL,
	[koma_full] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[koma] [nvarchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[koma_roma] [nvarchar](9) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[koma_en] [nvarchar](37) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[promoted_from] [int] NULL,
	[sfen_gote] [nvarchar](2) COLLATE Latin1_General_CS_AS NULL,
	[sfen_sente] [nvarchar](2) COLLATE Latin1_General_CS_AS NULL,
	[CSA_abbr] [nchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
