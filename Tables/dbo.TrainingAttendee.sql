CREATE TABLE [dbo].[TrainingAttendee]
(
[TrainingAttendeePK] [int] NOT NULL IDENTITY(1, 1),
[TrainingAttendeeCreateDate] [datetime] NOT NULL CONSTRAINT [DF_TrainingAttendee_TrainingAttendeeCreateDate] DEFAULT (getdate()),
[TrainingAttendeeCreator] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TrainingAttendeeEditDate] [datetime] NULL,
[TrainingAttendeeEditor] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrainingFK] [int] NULL,
[WorkerFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_TrainingAttendeeEditDate ON TrainingAttendee
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_TrainingAttendeeEditDate] ON [dbo].[TrainingAttendee]
For Update 
AS
Update TrainingAttendee Set TrainingAttendee.TrainingAttendeeEditDate= getdate()
From [TrainingAttendee] INNER JOIN Inserted ON [TrainingAttendee].[TrainingAttendeePK]= Inserted.[TrainingAttendeePK]
GO
ALTER TABLE [dbo].[TrainingAttendee] ADD CONSTRAINT [PK_TrainingAttend] PRIMARY KEY CLUSTERED  ([TrainingAttendeePK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_TrainingAttendee_TrainingFK] ON [dbo].[TrainingAttendee] ([TrainingFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TrainingFK] ON [dbo].[TrainingAttendee] ([TrainingFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_TrainingAttendee_WorkerFK] ON [dbo].[TrainingAttendee] ([WorkerFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TrainingWorkerFK] ON [dbo].[TrainingAttendee] ([WorkerFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TrainingAttendee] ADD CONSTRAINT [FK_TrainingAttendee_TrainingFK] FOREIGN KEY ([TrainingFK]) REFERENCES [dbo].[Training] ([TrainingPK])
GO
ALTER TABLE [dbo].[TrainingAttendee] ADD CONSTRAINT [FK_TrainingAttendee_WorkerFK] FOREIGN KEY ([WorkerFK]) REFERENCES [dbo].[Worker] ([WorkerPK])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Do not accept SVN changes', 'SCHEMA', N'dbo', 'TABLE', N'TrainingAttendee', 'COLUMN', N'TrainingAttendeePK'
GO
