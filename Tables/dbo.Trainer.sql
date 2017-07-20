CREATE TABLE [dbo].[Trainer]
(
[TrainerPK] [int] NOT NULL IDENTITY(1, 1),
[ProgramFK] [int] NULL,
[TrainerCreateDate] [datetime] NOT NULL CONSTRAINT [DF_Trainer_TrainerCreateDate] DEFAULT (getdate()),
[TrainerCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TrainerEditDate] [datetime] NULL,
[TrainerEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrainerFirstName] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrainerLastName] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrainerOrganization] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrainerPK_old] [int] NULL,
[TrainerDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_TrainerEditDate ON Trainer
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_TrainerEditDate] ON [dbo].[Trainer]
For Update 
AS
Update Trainer Set Trainer.TrainerEditDate= getdate()
From [Trainer] INNER JOIN Inserted ON [Trainer].[TrainerPK]= Inserted.[TrainerPK]
GO
ALTER TABLE [dbo].[Trainer] ADD CONSTRAINT [PK__Trainer__3796C2A81209AD79] PRIMARY KEY CLUSTERED  ([TrainerPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_Trainer_ProgramFK] ON [dbo].[Trainer] ([ProgramFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Trainer] WITH NOCHECK ADD CONSTRAINT [FK_Trainer_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
