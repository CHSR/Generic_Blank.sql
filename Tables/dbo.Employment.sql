CREATE TABLE [dbo].[Employment]
(
[EmploymentPK] [int] NOT NULL IDENTITY(1, 1),
[EmploymentCreateDate] [datetime] NOT NULL CONSTRAINT [DF_Employment_EmploymentCreateDate] DEFAULT (getdate()),
[EmploymentCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EmploymentEditDate] [datetime] NULL,
[EmploymentEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmploymentEndDate] [datetime] NULL,
[EmploymentMonthlyHours] [int] NULL,
[EmploymentStartDate] [datetime] NULL,
[FormDate] [datetime] NOT NULL,
[FormFK] [int] NOT NULL,
[FormType] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HVCaseFK] [int] NOT NULL,
[Interval] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EmploymentMonthlyWages] [numeric] (6, 0) NULL,
[PCType] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramFK] [int] NOT NULL,
[StillWorking] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_EmploymentEditDate ON Employment
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_EmploymentEditDate] ON [dbo].[Employment]
For Update 
AS
Update Employment Set Employment.EmploymentEditDate= getdate()
From [Employment] INNER JOIN Inserted ON [Employment].[EmploymentPK]= Inserted.[EmploymentPK]
GO
ALTER TABLE [dbo].[Employment] ADD CONSTRAINT [PK__Employme__FDF531DC68487DD7] PRIMARY KEY CLUSTERED  ([EmploymentPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_Employment_HVCaseFK] ON [dbo].[Employment] ([HVCaseFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_Employment_ProgramFK] ON [dbo].[Employment] ([ProgramFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Employment] WITH NOCHECK ADD CONSTRAINT [FK_Employment_HVCaseFK] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[Employment] WITH NOCHECK ADD CONSTRAINT [FK_Employment_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
