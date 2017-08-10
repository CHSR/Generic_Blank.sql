CREATE TABLE [dbo].[FollowUp]
(
[FollowUpPK] [int] NOT NULL IDENTITY(1, 1),
[BCAbstinence] [bit] NULL,
[BCCervicalCap] [bit] NULL,
[BCCondom] [bit] NULL,
[BCDiaphragm] [bit] NULL,
[BCEmergencyContraception] [bit] NULL,
[BCFemaleCondom] [bit] NULL,
[BCImplant] [bit] NULL,
[BCIUD] [bit] NULL,
[BCPatch] [bit] NULL,
[BCPill] [bit] NULL,
[BCShot] [bit] NULL,
[BCSpermicide] [bit] NULL,
[BCSterilization] [bit] NULL,
[BCVaginalRing] [bit] NULL,
[BCVasectomy] [bit] NULL,
[BCWithdrawal] [bit] NULL,
[BCRhythm] [bit] NULL,
[BirthControlUse] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPSACSReport] [bit] NULL,
[DYFSOpenCase] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DYFSReport] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DYFSReportBy] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DYFSReportBySpecify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DYFSSubstantiated] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FollowUpCreateDate] [datetime] NOT NULL CONSTRAINT [DF_FollowUp_FollowUpCreateDate] DEFAULT (getdate()),
[FollowUpCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FollowUpDate] [datetime] NOT NULL,
[FollowUpEditDate] [datetime] NULL,
[FollowUpEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FollowUpInterval] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FSWFK] [int] NOT NULL,
[FUPInWindow] [bit] NOT NULL,
[HVCaseFK] [int] NOT NULL,
[IFSPAdultRelationship] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IFSPChildDevelopment] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IFSPChildHealthSafety] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IFSPEducation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IFSPEmployment] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IFSPFamilyPlanning] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IFSPHousing] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IFSPNonTC] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IFSPParentChildInteraction] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IFSPParentHealthSafety] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LeadAssessment] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LiveBirths] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MonthsBirthControlUse] [int] NULL,
[PC1InHome] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PC1IssuesFK] [int] NOT NULL,
[PC2InHome] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Pregnant] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramFK] [int] NOT NULL,
[SafetyPlan] [bit] NULL,
[SixMonthHome] [bit] NULL,
[TimesPregnant] [int] NULL,
[HealthCareCoverageContinuity] [bit] NULL,
[HOMECompleted] [bit] NULL,
[TCDentalCareSource] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create TRIGGER [dbo].[fr_delete_FollowUP]
on [dbo].[FollowUp]
After DELETE

AS

Declare @PK int

set @PK = (SELECT FollowUpPK from deleted)

BEGIN
	EXEC spDeleteFormReview_Trigger @FormFK=@PK, @FormTypeValue='FU'
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[fr_followup]
on [dbo].[FollowUp]
After insert

AS

Declare @PK int

set @PK = (SELECT FollowUpPK from inserted)

BEGIN
	EXEC spAddFormReview_userTrigger @FormFK=@PK, @FormTypeValue='FU'
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
CREATE TRIGGER [dbo].[fr_FollowUp_Edit]
on [dbo].[FollowUp]
AFTER UPDATE

AS

Declare @PK int
Declare @UpdatedFormDate datetime 
Declare @FormTypeValue varchar(2)

select @PK = FollowUpPK  FROM inserted
select @UpdatedFormDate = FollowUpDate FROM inserted
set @FormTypeValue = 'FU'

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
-- create trigger TR_FollowUpEditDate ON FollowUp
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_FollowUpEditDate] ON [dbo].[FollowUp]
For Update 
AS
Update FollowUp Set FollowUp.FollowUpEditDate= getdate()
From [FollowUp] INNER JOIN Inserted ON [FollowUp].[FollowUpPK]= Inserted.[FollowUpPK]
GO
ALTER TABLE [dbo].[FollowUp] ADD CONSTRAINT [PK__FollowUp__D50BBDE871D1E811] PRIMARY KEY CLUSTERED  ([FollowUpPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FollowUpInterval] ON [dbo].[FollowUp] ([FollowUpInterval]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_FollowUp_FSWFK] ON [dbo].[FollowUp] ([FSWFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_FollowUp_HVCaseFK] ON [dbo].[FollowUp] ([HVCaseFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_FollowUp_PC1IssuesFK] ON [dbo].[FollowUp] ([PC1IssuesFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_FollowUp_ProgramFK] ON [dbo].[FollowUp] ([ProgramFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FollowUp] WITH NOCHECK ADD CONSTRAINT [FK_FollowUp_FSWFK] FOREIGN KEY ([FSWFK]) REFERENCES [dbo].[Worker] ([WorkerPK])
GO
ALTER TABLE [dbo].[FollowUp] WITH NOCHECK ADD CONSTRAINT [FK_FollowUp_HVCaseFK] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[FollowUp] WITH NOCHECK ADD CONSTRAINT [FK_FollowUp_PC1IssuesFK] FOREIGN KEY ([PC1IssuesFK]) REFERENCES [dbo].[PC1Issues] ([PC1IssuesPK])
GO
ALTER TABLE [dbo].[FollowUp] WITH NOCHECK ADD CONSTRAINT [FK_FollowUp_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Do not accept SVN changes', 'SCHEMA', N'dbo', 'TABLE', N'FollowUp', 'COLUMN', N'FollowUpPK'
GO
