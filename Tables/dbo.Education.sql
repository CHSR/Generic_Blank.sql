CREATE TABLE [dbo].[Education]
(
[EducationPK] [int] NOT NULL IDENTITY(1, 1),
[EducationCreateDate] [datetime] NOT NULL CONSTRAINT [DF_Education_EducationCreateDate] DEFAULT (getdate()),
[EducationCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EducationEditDate] [datetime] NULL,
[EducationEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EducationMonthlyHours] [int] NULL,
[FormDate] [datetime] NOT NULL,
[FormFK] [int] NOT NULL,
[FormType] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HVCaseFK] [int] NOT NULL,
[Interval] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PCType] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramFK] [int] NOT NULL,
[ProgramName] [char] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramType] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramTypeSpecify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_EducationEditDate ON Education
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_EducationEditDate] ON [dbo].[Education]
For Update 
AS
Update Education Set Education.EducationEditDate= getdate()
From [Education] INNER JOIN Inserted ON [Education].[EducationPK]= Inserted.[EducationPK]
GO
ALTER TABLE [dbo].[Education] ADD CONSTRAINT [PK__Educatio__4BBF34CC6383C8BA] PRIMARY KEY CLUSTERED  ([EducationPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_Education_HVCaseFK] ON [dbo].[Education] ([HVCaseFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_Education_ProgramFK] ON [dbo].[Education] ([ProgramFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Education] WITH NOCHECK ADD CONSTRAINT [FK_Education_HVCaseFK] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[Education] WITH NOCHECK ADD CONSTRAINT [FK_Education_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
