CREATE TABLE [dbo].[codeTraining]
(
[codeTrainingPK] [int] NOT NULL IDENTITY(1, 1),
[codeTrainingPK_old] [int] NOT NULL,
[ProgramFK] [int] NULL,
[TrainingCode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TrainingCodeDescription] [char] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TrainingCodeGroup] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TrainingCodeUsedWhere] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[codeTraining] ADD CONSTRAINT [PK__codeTrai__C0D5D6495629CD9C] PRIMARY KEY CLUSTERED  ([codeTrainingPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_codeTraining_ProgramFK] ON [dbo].[codeTraining] ([ProgramFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[codeTraining] WITH NOCHECK ADD CONSTRAINT [FK_codeTraining_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
