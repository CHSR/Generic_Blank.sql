CREATE TABLE [dbo].[OtherChild]
(
[OtherChildPK] [int] NOT NULL IDENTITY(1, 1),
[BirthTerm] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BirthWtLbs] [int] NULL,
[BirthWtOz] [int] NULL,
[DOB] [datetime] NULL,
[FirstName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormFK] [int] NOT NULL,
[FormType] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GestationalWeeks] [int] NULL,
[HVCaseFK] [int] NOT NULL,
[LastName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LivingArrangement] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LivingArrangementSpecify] [char] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MultiBirth] [int] NULL,
[OtherChildCreateDate] [datetime] NOT NULL CONSTRAINT [DF_OtherChild_OtherChildCreateDate] DEFAULT (getdate()),
[OtherChildCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OtherChildEditDate] [datetime] NULL,
[OtherChildEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PregnancyOutcome] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrenatalCare] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramFK] [int] NULL,
[Relation2PC1] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Relation2PC1Specify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_OtherChildEditDate ON OtherChild
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_OtherChildEditDate] ON [dbo].[OtherChild]
For Update 
AS
Update OtherChild Set OtherChild.OtherChildEditDate= getdate()
From [OtherChild] INNER JOIN Inserted ON [OtherChild].[OtherChildPK]= Inserted.[OtherChildPK]
GO
ALTER TABLE [dbo].[OtherChild] ADD CONSTRAINT [PK__OtherChi__4C6128A742E1EEFE] PRIMARY KEY CLUSTERED  ([OtherChildPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_OtherChild_HVCaseFK] ON [dbo].[OtherChild] ([HVCaseFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_OtherChild_ProgramFK] ON [dbo].[OtherChild] ([ProgramFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OtherChild] WITH NOCHECK ADD CONSTRAINT [FK_OtherChild_HVCaseFK] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[OtherChild] WITH NOCHECK ADD CONSTRAINT [FK_OtherChild_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
