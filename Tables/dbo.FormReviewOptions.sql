CREATE TABLE [dbo].[FormReviewOptions]
(
[FormReviewOptionsPK] [int] NOT NULL IDENTITY(1, 1),
[FormReviewEndDate] [datetime] NULL,
[FormReviewOptionsCreateDate] [datetime] NOT NULL CONSTRAINT [DF_FormReviewOptions_FormReviewOptionsCreateDate] DEFAULT (getdate()),
[FormReviewOptionsCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FormReviewOptionsEditDate] [datetime] NULL,
[FormReviewOptionsEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormReviewStartDate] [datetime] NOT NULL,
[FormType] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_FormReviewOptionsEditDate ON FormReviewOptions
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_FormReviewOptionsEditDate] ON [dbo].[FormReviewOptions]
For Update 
AS
Update FormReviewOptions Set FormReviewOptions.FormReviewOptionsEditDate= getdate()
From [FormReviewOptions] INNER JOIN Inserted ON [FormReviewOptions].[FormReviewOptionsPK]= Inserted.[FormReviewOptionsPK]
GO
ALTER TABLE [dbo].[FormReviewOptions] ADD CONSTRAINT [PK__FormRevi__D92F2DB27B5B524B] PRIMARY KEY CLUSTERED  ([FormReviewOptionsPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_FormReviewOptions_ProgramFK] ON [dbo].[FormReviewOptions] ([ProgramFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FormReviewOptions] WITH NOCHECK ADD CONSTRAINT [FK_FormReviewOptions_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
