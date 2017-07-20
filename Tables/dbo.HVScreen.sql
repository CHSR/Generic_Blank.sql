CREATE TABLE [dbo].[HVScreen]
(
[HVScreenPK] [int] NOT NULL IDENTITY(1, 1),
[DischargeReason] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DischargeReasonSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FAWFK] [int] NULL,
[HVCaseFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL,
[ReferralMade] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferralSource] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferralSourceFK] [int] NULL,
[ReferralSourceSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Relation2TC] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Relation2TCSpecify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RiskAbortionHistory] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RiskAbortionTry] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RiskAdoption] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RiskDepressionHistory] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RiskEducation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RiskInadequateSupports] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RiskMaritalProblems] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RiskNoPhone] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RiskNoPrenatalCare] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RiskNotMarried] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RiskPartnerJobless] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RiskPoor] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RiskPsychiatricHistory] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RiskSubstanceAbuseHistory] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RiskUnder21] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RiskUnstableHousing] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScreenCreateDate] [datetime] NOT NULL CONSTRAINT [DF_HVScreen_ScreenCreateDate] DEFAULT (getdate()),
[ScreenCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ScreenDate] [datetime] NOT NULL,
[ScreenEditDate] [datetime] NULL,
[ScreenEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScreenerFirstName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScreenerLastName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScreenerMiddleInitial] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScreenerPhone] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScreenResult] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ScreenVersion] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TargetArea] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransferredtoProgram] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create TRIGGER [dbo].[fr_delete_screen]
on [dbo].[HVScreen]
After DELETE

AS

Declare @PK int

set @PK = (SELECT HVSCREENPK from deleted)

BEGIN
	EXEC spDeleteFormReview_Trigger @FormFK=@PK, @FormTypeValue='SC'
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[fr_hvscreen]
on [dbo].[HVScreen]
After insert

AS

Declare @PK int

set @PK = (SELECT HVScreenPK from inserted)

BEGIN
	EXEC spAddFormReview_userTrigger @FormFK=@PK, @FormTypeValue='SC'
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
CREATE TRIGGER [dbo].[fr_hvscreen_edit]
on [dbo].[HVScreen]
AFTER UPDATE

AS

Declare @PK int
Declare @UpdatedFormDate datetime 
Declare @FormTypeValue varchar(2)


select @PK = HVScreenPK  FROM inserted
select @UpdatedFormDate = ScreenDate FROM inserted
set @FormTypeValue = 'SC'

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
-- create trigger TR_ScreenEditDate ON HVScreen
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_ScreenEditDate] ON [dbo].[HVScreen]
For Update 
AS
Update HVScreen Set HVScreen.ScreenEditDate= getdate()
From [HVScreen] INNER JOIN Inserted ON [HVScreen].[HVScreenPK]= Inserted.[HVScreenPK]
GO
ALTER TABLE [dbo].[HVScreen] ADD CONSTRAINT [PK__HVScreen__3751BFE51BC821DD] PRIMARY KEY CLUSTERED  ([HVScreenPK]) ON [PRIMARY]
GO
