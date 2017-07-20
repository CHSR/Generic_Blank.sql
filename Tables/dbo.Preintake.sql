CREATE TABLE [dbo].[Preintake]
(
[PreintakePK] [int] NOT NULL IDENTITY(1, 1),
[CaseStatus] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DischargeReason] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DischargeReasonSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DischargeSafetyReason] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DischargeSafetyReasonDV] [bit] NULL,
[DischargeSafetyReasonMH] [bit] NULL,
[DischargeSafetyReasonOther] [bit] NULL,
[DischargeSafetyReasonSA] [bit] NULL,
[DischargeSafetyReasonSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HVCaseFK] [int] NOT NULL,
[KempeFK] [int] NOT NULL,
[PIActivitySpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PICall2Parent] [int] NULL,
[PICallFromParent] [int] NULL,
[PICaseReview] [int] NULL,
[PICreateDate] [datetime] NOT NULL CONSTRAINT [DF_Preintake_PICreateDate] DEFAULT (getdate()),
[PICreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PIDate] [datetime] NOT NULL,
[PIEditDate] [datetime] NULL,
[PIEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PIFSWFK] [int] NOT NULL,
[PIGift] [int] NULL,
[PIOtherActivity] [int] NULL,
[PIOtherHVProgram] [int] NULL,
[PIParent2Office] [int] NULL,
[PIParentLetter] [int] NULL,
[PIProgramMaterial] [int] NULL,
[PIVisitAttempt] [int] NULL,
[PIVisitMade] [int] NULL,
[ProgramFK] [int] NOT NULL,
[TransferredtoProgram] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create TRIGGER [dbo].[fr_delete_preintake]
on [dbo].[Preintake]
After DELETE

AS

Declare @PK int

set @PK = (SELECT PREINTAKEPK from deleted)

BEGIN
	EXEC spDeleteFormReview_Trigger @FormFK=@PK, @FormTypeValue='PI'
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[fr_preintake]
on [dbo].[Preintake]
After insert

AS

Declare @PK int

set @PK = (SELECT PreintakePK from inserted)

BEGIN
	EXEC spAddFormReview_userTrigger @FormFK=@PK, @FormTypeValue='PI'
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
CREATE TRIGGER [dbo].[fr_Preintake_Edit]
on [dbo].[Preintake]
AFTER UPDATE

AS

Declare @PK int
Declare @UpdatedFormDate datetime 
Declare @FormTypeValue varchar(2)

select @PK = PreintakePK FROM inserted
select @UpdatedFormDate = PIDate FROM inserted
set @FormTypeValue = 'PI'

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
-- create trigger TR_PIEditDate ON Preintake
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_PIEditDate] ON [dbo].[Preintake]
For Update 
AS
Update Preintake Set Preintake.PIEditDate= getdate()
From [Preintake] INNER JOIN Inserted ON [Preintake].[PreintakePK]= Inserted.[PreintakePK]
GO
ALTER TABLE [dbo].[Preintake] ADD CONSTRAINT [PK__Preintak__0D9DD8F3625A9A57] PRIMARY KEY CLUSTERED  ([PreintakePK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_Preintake_HVCaseFK] ON [dbo].[Preintake] ([HVCaseFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_Preintake_KempeFK] ON [dbo].[Preintake] ([KempeFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_Preintake_PIFSWFK] ON [dbo].[Preintake] ([PIFSWFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_Preintake_ProgramFK] ON [dbo].[Preintake] ([ProgramFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Preintake] WITH NOCHECK ADD CONSTRAINT [FK_Preintake_HVCaseFK] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[Preintake] WITH NOCHECK ADD CONSTRAINT [FK_Preintake_KempeFK] FOREIGN KEY ([KempeFK]) REFERENCES [dbo].[Kempe] ([KempePK])
GO
ALTER TABLE [dbo].[Preintake] WITH NOCHECK ADD CONSTRAINT [FK_Preintake_PIFSWFK] FOREIGN KEY ([PIFSWFK]) REFERENCES [dbo].[Worker] ([WorkerPK])
GO
ALTER TABLE [dbo].[Preintake] WITH NOCHECK ADD CONSTRAINT [FK_Preintake_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
