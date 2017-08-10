CREATE TABLE [dbo].[Preassessment]
(
[PreassessmentPK] [int] NOT NULL IDENTITY(1, 1),
[CaseStatus] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DischargeReason] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DischargeReasonSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DischargeSafetyReason] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DischargeSafetyReasonDV] [bit] NULL,
[DischargeSafetyReasonMH] [bit] NULL,
[DischargeSafetyReasonOther] [bit] NULL,
[DischargeSafetyReasonSA] [bit] NULL,
[DischargeSafetyReasonSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FSWAssignDate] [datetime] NULL,
[HVCaseFK] [int] NOT NULL,
[KempeDate] [datetime] NULL,
[KempeResult] [bit] NULL,
[PAActivitySpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PACall2Parent] [int] NULL,
[PACallFromParent] [int] NULL,
[PACaseReview] [int] NULL,
[PACreateDate] [datetime] NOT NULL CONSTRAINT [DF_Preassessment_PACreateDate] DEFAULT (getdate()),
[PACreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PADate] [datetime] NOT NULL,
[PAEditDate] [datetime] NULL,
[PAEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PAFAWFK] [int] NOT NULL,
[PAFSWFK] [int] NULL,
[PAGift] [int] NULL,
[PAOtherActivity] [int] NULL,
[PAOtherHVProgram] [int] NULL,
[PAParent2Office] [int] NULL,
[PAParentLetter] [int] NULL,
[PAProgramMaterial] [int] NULL,
[PAVisitAttempt] [int] NULL,
[PAVisitMade] [int] NULL,
[ProgramFK] [int] NOT NULL,
[TransferredtoProgram] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create TRIGGER [dbo].[fr_delete_preassessment]
on [dbo].[Preassessment]
After DELETE

AS

Declare @PK int

set @PK = (SELECT PREASSESSMENTPK from deleted)

BEGIN
	EXEC spDeleteFormReview_Trigger @FormFK=@PK, @FormTypeValue='PA'
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create TRIGGER [dbo].[fr_preassessment]
on [dbo].[Preassessment]
After insert

AS

Declare @PK int

set @PK = (SELECT PreassessmentPK from inserted)

BEGIN
	EXEC spAddFormReview_userTrigger @FormFK=@PK, @FormTypeValue='PA'
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
CREATE TRIGGER [dbo].[fr_Preassessment_Edit]
on [dbo].[Preassessment]
AFTER UPDATE

AS

Declare @PK int
Declare @UpdatedFormDate datetime 
Declare @FormTypeValue varchar(2)

select @PK = PreassessmentPK FROM inserted
select @UpdatedFormDate = PADate FROM inserted
set @FormTypeValue = 'PA'

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
-- create trigger TR_PAEditDate ON Preassessment
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_PAEditDate] ON [dbo].[Preassessment]
For Update 
AS
Update Preassessment Set Preassessment.PAEditDate= getdate()
From [Preassessment] INNER JOIN Inserted ON [Preassessment].[PreassessmentPK]= Inserted.[PreassessmentPK]
GO
ALTER TABLE [dbo].[Preassessment] ADD CONSTRAINT [PK__Preasses__686E4EF65D95E53A] PRIMARY KEY CLUSTERED  ([PreassessmentPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_Preassessment_HVCaseFK] ON [dbo].[Preassessment] ([HVCaseFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_Preassessment_PAFAWFK] ON [dbo].[Preassessment] ([PAFAWFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_Preassessment_ProgramFK] ON [dbo].[Preassessment] ([ProgramFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Preassessment] WITH NOCHECK ADD CONSTRAINT [FK_Preassessment_HVCaseFK] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[Preassessment] WITH NOCHECK ADD CONSTRAINT [FK_Preassessment_PAFAWFK] FOREIGN KEY ([PAFAWFK]) REFERENCES [dbo].[Worker] ([WorkerPK])
GO
ALTER TABLE [dbo].[Preassessment] WITH NOCHECK ADD CONSTRAINT [FK_Preassessment_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Do not accept SVN changes', 'SCHEMA', N'dbo', 'TABLE', N'Preassessment', 'COLUMN', N'PreassessmentPK'
GO
