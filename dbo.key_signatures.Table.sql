DROP TABLE [key_signatures]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [key_signatures](
	[rn] [bigint] NULL,
	[key_signature] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Major_key] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Minor_key] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[keysig_pat] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sharp_count] [int] NOT NULL,
	[flat_count] [int] NOT NULL,
	[in_radians] [float] NULL
) ON [PRIMARY]
GO
