CREATE TABLE [dbo].[listCaseFilterNameOption]
(
[listCaseFilterNameOptionPK] [int] NOT NULL IDENTITY(1, 1),
[CaseFilterNameFK] [int] NOT NULL,
[FilterOption] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FilterOptionCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[listCaseFilterNameOption] ADD CONSTRAINT [PK_listCaseFilterNameOption] PRIMARY KEY CLUSTERED  ([listCaseFilterNameOptionPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_listCaseFilterNameOption_CaseFilterNameFK] ON [dbo].[listCaseFilterNameOption] ([CaseFilterNameFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[listCaseFilterNameOption] WITH NOCHECK ADD CONSTRAINT [FK_listCaseFilterNameOption_CaseFilterNameFK] FOREIGN KEY ([CaseFilterNameFK]) REFERENCES [dbo].[listCaseFilterName] ([listCaseFilterNamePK])
GO
