CREATE TABLE [dbo].[TrainingDetail]
(
[TrainingDetailPK] [int] NOT NULL IDENTITY(1, 1),
[CulturalCompetency] [bit] NULL,
[ProgramFK] [int] NULL,
[SubTopicFK] [int] NULL,
[SubTopicTime] [int] NULL,
[TopicFK] [int] NOT NULL,
[TrainingDetailCreateDate] [datetime] NOT NULL CONSTRAINT [DF_TrainingDetail_TrainingDetailCreateDate] DEFAULT (getdate()),
[TrainingDetailCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TrainingDetailEditDate] [datetime] NULL,
[TrainingDetailEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrainingDetailPK_old] [int] NULL,
[TrainingFK] [int] NOT NULL,
[ExemptDescription] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExemptType] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_TrainingDetailEditDate ON TrainingDetail
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_TrainingDetailEditDate] ON [dbo].[TrainingDetail]
For Update 
AS
Update TrainingDetail Set TrainingDetail.TrainingDetailEditDate= getdate()
From [TrainingDetail] INNER JOIN Inserted ON [TrainingDetail].[TrainingDetailPK]= Inserted.[TrainingDetailPK]
GO
ALTER TABLE [dbo].[TrainingDetail] ADD CONSTRAINT [PK__Training__F23C2E472057CCD0] PRIMARY KEY CLUSTERED  ([TrainingDetailPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_TrainingDetail_ProgramFK] ON [dbo].[TrainingDetail] ([ProgramFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TrainingDetailSubtopicFK] ON [dbo].[TrainingDetail] ([SubTopicFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [TopicFK] ON [dbo].[TrainingDetail] ([TopicFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_TrainingDetail_TrainingFK] ON [dbo].[TrainingDetail] ([TrainingFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TrainingDetailTrainingFK] ON [dbo].[TrainingDetail] ([TrainingFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TrainingDetail] WITH NOCHECK ADD CONSTRAINT [FK_TrainingDetail_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
ALTER TABLE [dbo].[TrainingDetail] WITH NOCHECK ADD CONSTRAINT [FK_TrainingDetail_TrainingFK] FOREIGN KEY ([TrainingFK]) REFERENCES [dbo].[Training] ([TrainingPK])
GO
