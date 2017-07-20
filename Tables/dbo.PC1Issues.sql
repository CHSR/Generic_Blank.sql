CREATE TABLE [dbo].[PC1Issues]
(
[PC1IssuesPK] [int] NOT NULL IDENTITY(1, 1),
[AlcoholAbuse] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CriminalActivity] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Depression] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DevelopmentalDisability] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DomesticViolence] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FinancialDifficulty] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Homeless] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HVCaseFK] [int] NOT NULL,
[InadequateBasics] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Interval] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MaritalProblems] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MentalIllness] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OtherIssue] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OtherIssueSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OtherLegalProblems] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1IssuesCreateDate] [datetime] NOT NULL CONSTRAINT [DF_PC1Issues_PC1IssuesCreateDate] DEFAULT (getdate()),
[PC1IssuesCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PC1IssuesDate] [datetime] NOT NULL,
[PC1IssuesEditDate] [datetime] NULL,
[PC1IssuesEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1IssuesPK_old] [int] NOT NULL,
[PhysicalDisability] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramFK] [int] NOT NULL,
[Smoking] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SocialIsolation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Stress] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubstanceAbuse] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_PC1IssuesEditDate ON PC1Issues
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_PC1IssuesEditDate] ON [dbo].[PC1Issues]
For Update 
AS
Update PC1Issues Set PC1Issues.PC1IssuesEditDate= getdate()
From [PC1Issues] INNER JOIN Inserted ON [PC1Issues].[PC1IssuesPK]= Inserted.[PC1IssuesPK]
GO
ALTER TABLE [dbo].[PC1Issues] ADD CONSTRAINT [PK__PC1Issue__B4E655D7503BEA1C] PRIMARY KEY CLUSTERED  ([PC1IssuesPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_PC1Issues_HVCaseFK] ON [dbo].[PC1Issues] ([HVCaseFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_PC1Issues_ProgramFK] ON [dbo].[PC1Issues] ([ProgramFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PC1Issues] WITH NOCHECK ADD CONSTRAINT [FK_PC1Issues_HVCaseFK] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[PC1Issues] WITH NOCHECK ADD CONSTRAINT [FK_PC1Issues_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
