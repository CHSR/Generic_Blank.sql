CREATE TABLE [dbo].[HVLevel]
(
[HVLevelPK] [int] NOT NULL IDENTITY(1, 1),
[HVCaseFK] [int] NOT NULL,
[HVLevelCreateDate] [datetime] NOT NULL CONSTRAINT [DF_HVLevel_HVLevelCreateDate] DEFAULT (getdate()),
[HVLevelCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HVLevelEditDate] [datetime] NULL,
[HVLevelEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LevelAssignDate] [datetime] NOT NULL,
[LevelFK] [int] NULL,
[ProgramFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create TRIGGER [dbo].[fr_delete_hvlevel]
on [dbo].[HVLevel]
After DELETE

AS

Declare @PK int

set @PK = (SELECT HVLevelPK from deleted)

BEGIN
	EXEC spDeleteFormReview_Trigger @FormFK=@PK, @FormTypeValue='LV'
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[fr_hvlevel]
on [dbo].[HVLevel]
After insert

AS

Declare @PK int

set @PK = (SELECT HVLEVELPK from inserted)

BEGIN
	EXEC spAddFormReview_userTrigger @FormFK=@PK, @FormTypeValue='LV'
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 08/18/2010
-- Description:	Updates FormReview Table with form date on Supervisor Review of Form
-- =============================================
CREATE TRIGGER [dbo].[fr_HVLevel_Edit]
on [dbo].[HVLevel]
AFTER UPDATE

AS

Declare @PK int
Declare @UpdatedFormDate datetime 
Declare @FormTypeValue varchar(2)

select @PK = HVLevelPK  FROM inserted
select @UpdatedFormDate = LevelAssignDate FROM inserted
set @FormTypeValue = 'LV'

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
-- create trigger TR_HVLevelEditDate ON HVLevel
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_HVLevelEditDate] ON [dbo].[HVLevel]
For Update 
AS
Update HVLevel Set HVLevel.HVLevelEditDate= getdate()
From [HVLevel] INNER JOIN Inserted ON [HVLevel].[HVLevelPK]= Inserted.[HVLevelPK]
GO
ALTER TABLE [dbo].[HVLevel] ADD CONSTRAINT [PK__HVLevel__929D7A180E6E26BF] PRIMARY KEY CLUSTERED  ([HVLevelPK]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_HVLevel_LevelAssignDate] ON [dbo].[HVLevel] ([HVCaseFK], [LevelAssignDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_HVLevel_LevelFK] ON [dbo].[HVLevel] ([LevelFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HVLevel] WITH NOCHECK ADD CONSTRAINT [FK_HVLevel_HVCaseFK] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[HVLevel] WITH NOCHECK ADD CONSTRAINT [FK_HVLevel_LevelFK] FOREIGN KEY ([LevelFK]) REFERENCES [dbo].[codeLevel] ([codeLevelPK])
GO
