CREATE TABLE [dbo].[Training]
(
[TrainingPK] [int] NOT NULL IDENTITY(1, 1),
[ProgramFK] [int] NULL,
[TrainerFK] [int] NULL,
[TrainingMethodFK] [int] NULL,
[TrainingCreateDate] [datetime] NULL CONSTRAINT [DF_Training_TrainingCreateDate] DEFAULT (getdate()),
[TrainingCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrainingDate] [datetime] NULL,
[TrainingDays] [int] NULL,
[TrainingDescription] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrainingDuration] [int] NULL,
[TrainingEditDate] [datetime] NULL,
[TrainingEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrainingHours] [int] NULL,
[TrainingMinutes] [int] NULL,
[TrainingTitle] [char] (70) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsExempt] [bit] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[fr_delete_training]
on [dbo].[Training]
After DELETE
AS
Declare @PK int

set @PK = (SELECT TrainingPK from deleted)

BEGIN
	EXEC spDeleteFormReview_Trigger @FormFK=@PK, @FormTypeValue='TR'
END
GO
DISABLE TRIGGER [dbo].[fr_delete_training] ON [dbo].[Training]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[fr_Training]
on [dbo].[Training]
After insert

AS

Declare @PK int

set @PK = (SELECT TrainingPK from inserted)

BEGIN
	EXEC spAddFormReview_userTriggernoHVCaseFK @FormFK=@PK, @FormTypeValue='TR'
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[fr_Training_Edit]
on [dbo].[Training]
AFTER UPDATE

AS

Declare @PK int
Declare @UpdatedFormDate datetime 
Declare @FormTypeValue varchar(2)

select @PK = TrainingPK FROM inserted
select @UpdatedFormDate = TrainingDate FROM inserted
set @FormTypeValue = 'TR'

BEGIN
	UPDATE FormReview
	SET 
	FormDate=@UpdatedFormDate
	WHERE FormFK=@PK 
	AND FormType=@FormTypeValue

END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_TrainingEditDate ON Training
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_TrainingEditDate] ON [dbo].[Training]
For Update 
AS
Update Training Set Training.TrainingEditDate= getdate()
From [Training] INNER JOIN Inserted ON [Training].[TrainingPK]= Inserted.[TrainingPK]
GO
ALTER TABLE [dbo].[Training] ADD CONSTRAINT [PK__Training__E8D0D89816CE6296] PRIMARY KEY CLUSTERED  ([TrainingPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_Training_ProgramFK] ON [dbo].[Training] ([ProgramFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_Training_TrainerFK] ON [dbo].[Training] ([TrainerFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TrainingDate] ON [dbo].[Training] ([TrainingDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_Training_TrainingMethodFK] ON [dbo].[Training] ([TrainingMethodFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [TrainingPK_ProgramFK] ON [dbo].[Training] ([TrainingPK], [ProgramFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Training] WITH NOCHECK ADD CONSTRAINT [FK_Training_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
ALTER TABLE [dbo].[Training] WITH NOCHECK ADD CONSTRAINT [FK_Training_TrainerFK] FOREIGN KEY ([TrainerFK]) REFERENCES [dbo].[Trainer] ([TrainerPK])
GO
ALTER TABLE [dbo].[Training] WITH NOCHECK ADD CONSTRAINT [FK_Training_TrainingMethodFK] FOREIGN KEY ([TrainingMethodFK]) REFERENCES [dbo].[TrainingMethod] ([TrainingMethodPK])
GO
