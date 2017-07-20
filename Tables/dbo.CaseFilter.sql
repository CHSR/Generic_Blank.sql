CREATE TABLE [dbo].[CaseFilter]
(
[CaseFilterPK] [int] NOT NULL IDENTITY(1, 1),
[CaseFilterNameFK] [int] NOT NULL,
[CaseFilterCreateDate] [datetime] NOT NULL CONSTRAINT [DF_CaseFilter_CaseFilterCreateDate] DEFAULT (getdate()),
[CaseFilterCreator] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CaseFilterEditDate] [datetime] NULL,
[CaseFilterEditor] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CaseFilterNameChoice] [bit] NULL,
[CaseFilterNameDate] [date] NULL,
[CaseFilterNameOptionFK] [int] NULL,
[CaseFilterValue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HVCaseFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[TR_CaseFilterEditDate] ON [dbo].[CaseFilter]
For Update 
AS
Update CaseFilter Set CaseFilter.CaseFilterEditDate= getdate()
From [CaseFilter] INNER JOIN Inserted ON [CaseFilter].[CaseFilterPK]= Inserted.[CaseFilterPK]

GO
ALTER TABLE [dbo].[CaseFilter] ADD CONSTRAINT [PK__CaseFilt__9E62C9EB0CBAE877] PRIMARY KEY CLUSTERED  ([CaseFilterPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_CaseFilter_CaseFilterNameFK] ON [dbo].[CaseFilter] ([CaseFilterNameFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_CaseFilter_HVCaseFK] ON [dbo].[CaseFilter] ([HVCaseFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_CaseFilter_ProgramFK] ON [dbo].[CaseFilter] ([ProgramFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CaseFilter] WITH NOCHECK ADD CONSTRAINT [FK_CaseFilter_CaseFilterNameFK] FOREIGN KEY ([CaseFilterNameFK]) REFERENCES [dbo].[listCaseFilterName] ([listCaseFilterNamePK])
GO
ALTER TABLE [dbo].[CaseFilter] WITH NOCHECK ADD CONSTRAINT [FK_CaseFilter_HVCaseFK] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[CaseFilter] WITH NOCHECK ADD CONSTRAINT [FK_CaseFilter_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
