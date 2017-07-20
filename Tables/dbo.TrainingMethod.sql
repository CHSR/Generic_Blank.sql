CREATE TABLE [dbo].[TrainingMethod]
(
[TrainingMethodPK] [int] NOT NULL IDENTITY(1, 1),
[TrainingCode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MethodName] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramFK] [int] NOT NULL,
[OldTMethodPK] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TrainingMethod] ADD CONSTRAINT [PK_TrainingMethod] PRIMARY KEY CLUSTERED  ([TrainingMethodPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_TrainingMethod_ProgramFK] ON [dbo].[TrainingMethod] ([ProgramFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TrainingMethod] ADD CONSTRAINT [FK_TrainingMethod_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
