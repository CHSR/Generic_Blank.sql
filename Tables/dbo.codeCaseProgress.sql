CREATE TABLE [dbo].[codeCaseProgress]
(
[codeCaseProgressPK] [int] NOT NULL IDENTITY(1, 1),
[CaseProgressCode] [numeric] (3, 1) NOT NULL,
[CaseProgressBrief] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CaseProgressDescription] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CaseProgressNote] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[codeCaseProgress] ADD CONSTRAINT [PK__codeCase__956E9D08286302EC] PRIMARY KEY CLUSTERED  ([codeCaseProgressPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_codeCaseProgress_CaseProgressCode] ON [dbo].[codeCaseProgress] ([CaseProgressCode]) ON [PRIMARY]
GO
