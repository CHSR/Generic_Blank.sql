CREATE TABLE [dbo].[AuditC]
(
[AuditCPK] [int] NOT NULL IDENTITY(1, 1),
[AuditCCreateDate] [datetime] NOT NULL CONSTRAINT [DF_AuditC_AuditCCreateDate] DEFAULT (getdate()),
[AuditCCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AuditCEditDate] [datetime] NULL,
[AuditCEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DailyDrinks] [int] NULL,
[FormFK] [int] NOT NULL,
[FormInterval] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FormType] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HowOften] [int] NULL,
[HVCaseFK] [int] NOT NULL,
[Invalid] [bit] NULL,
[MoreThanSix] [int] NULL,
[Positive] [bit] NULL,
[ProgramFK] [int] NOT NULL,
[TotalScore] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_CaseProgramEditDate ON CaseProgram
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
create TRIGGER [dbo].[TR_AuditCEditDate] ON [dbo].[AuditC]
For Update 
AS
Update AuditC Set AuditC.AuditCEditDate= getdate()
From [AuditC] INNER JOIN Inserted ON [AuditC].[AuditCPK]= Inserted.[AuditCPK]
GO
ALTER TABLE [dbo].[AuditC] ADD CONSTRAINT [PK_AuditC] PRIMARY KEY CLUSTERED  ([AuditCPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_AuditC_HVCaseFK] ON [dbo].[AuditC] ([HVCaseFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_AuditC_ProgramFK] ON [dbo].[AuditC] ([ProgramFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AuditC] ADD CONSTRAINT [FK_AuditC_DailyDrinks] FOREIGN KEY ([DailyDrinks]) REFERENCES [dbo].[codeAuditC] ([codeAuditCPK])
GO
ALTER TABLE [dbo].[AuditC] ADD CONSTRAINT [FK_AuditC_HowOften] FOREIGN KEY ([HowOften]) REFERENCES [dbo].[codeAuditC] ([codeAuditCPK])
GO
ALTER TABLE [dbo].[AuditC] ADD CONSTRAINT [FK_AuditC_HVCaseFK] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[AuditC] ADD CONSTRAINT [FK_AuditC_MoreThanSix] FOREIGN KEY ([MoreThanSix]) REFERENCES [dbo].[codeAuditC] ([codeAuditCPK])
GO
ALTER TABLE [dbo].[AuditC] ADD CONSTRAINT [FK_AuditC_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
