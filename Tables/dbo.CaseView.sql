CREATE TABLE [dbo].[CaseView]
(
[CaseViewPK] [int] NOT NULL IDENTITY(1, 1),
[PC1ID] [nchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Username] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ViewDate] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CaseView] ADD CONSTRAINT [PK_CaseView] PRIMARY KEY CLUSTERED  ([CaseViewPK]) ON [PRIMARY]
GO
