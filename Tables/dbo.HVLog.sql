CREATE TABLE [dbo].[HVLog]
(
[HVLogPK] [int] NOT NULL IDENTITY(1, 1),
[AdditionalComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CAChildSupport] [bit] NULL,
[CAAdvocacy] [bit] NULL,
[CAComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CAGoods] [bit] NULL,
[CAHousing] [bit] NULL,
[CALaborSupport] [bit] NULL,
[CALegal] [bit] NULL,
[CAOther] [bit] NULL,
[CAParentRights] [bit] NULL,
[CASpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CATranslation] [bit] NULL,
[CATransportation] [bit] NULL,
[CAVisitation] [bit] NULL,
[CDChildDevelopment] [bit] NULL,
[CDComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CDFollowUpEIServices] [bit] NULL,
[CDOther] [bit] NULL,
[CDParentConcerned] [bit] NULL,
[CDSocialEmotionalDevelopment] [bit] NULL,
[CDSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CDToys] [bit] NULL,
[CHEERSCues] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CHEERSHolding] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CHEERSExpression] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CHEERSEmpathy] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CHEERSRhythmReciprocity] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CHEERSSmiles] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CHEERSOverallStrengths] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CHEERSAreasToFocus] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CIComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CIProblems] [bit] NULL,
[CIOther] [bit] NULL,
[CIOtherSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Curriculum247Dads] [bit] NULL,
[CurriculumBoyz2Dads] [bit] NULL,
[CurriculumComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurriculumGreatBeginnings] [bit] NULL,
[CurriculumGrowingGreatKids] [bit] NULL,
[CurriculumHelpingBabiesLearn] [bit] NULL,
[CurriculumInsideOutDads] [bit] NULL,
[CurriculumMomGateway] [bit] NULL,
[CurriculumOtherSupplementalInformation] [bit] NULL,
[CurriculumOtherSupplementalInformationComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurriculumOther] [bit] NULL,
[CurriculumOtherSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurriculumParentsForLearning] [bit] NULL,
[CurriculumPartnersHealthyBaby] [bit] NULL,
[CurriculumPAT] [bit] NULL,
[CurriculumPATFocusFathers] [bit] NULL,
[CurriculumSanAngelo] [bit] NULL,
[FamilyMemberReads] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FatherAdvocateFK] [int] NULL,
[FatherAdvocateParticipated] [bit] NULL,
[FatherFigureParticipated] [bit] NULL,
[FFChildProtectiveIssues] [bit] NULL,
[FFComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FFCommunication] [bit] NULL,
[FFDevelopmentalDisabilities] [bit] NULL,
[FFDomesticViolence] [bit] NULL,
[FFFamilyRelations] [bit] NULL,
[FFImmigration] [bit] NULL,
[FFMentalHealth] [bit] NULL,
[FFOther] [bit] NULL,
[FFSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FFSubstanceAbuse] [bit] NULL,
[FGPComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FGPDevelopActivities] [bit] NULL,
[FGPDiscuss] [bit] NULL,
[FGPGoalsCompleted] [bit] NULL,
[FGPNewGoal] [bit] NULL,
[FGPNoDiscussion] [bit] NULL,
[FGPProgress] [bit] NULL,
[FGPRevisions] [bit] NULL,
[FSWFK] [int] NULL,
[GrandParentParticipated] [bit] NULL,
[HCBreastFeeding] [bit] NULL,
[HCChild] [bit] NULL,
[HCComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCDental] [bit] NULL,
[HCFamilyPlanning] [bit] NULL,
[HCFASD] [bit] NULL,
[HCFeeding] [bit] NULL,
[HCGeneral] [bit] NULL,
[HCLaborDelivery] [bit] NULL,
[HCMedicalAdvocacy] [bit] NULL,
[HCNutrition] [bit] NULL,
[HCOther] [bit] NULL,
[HCPrenatalCare] [bit] NULL,
[HCProviders] [bit] NULL,
[HCSafety] [bit] NULL,
[HCSexEducation] [bit] NULL,
[HCSIDS] [bit] NULL,
[HCSmoking] [bit] NULL,
[HCSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HealthPC1AppearsHealthy] [bit] NULL,
[HealthPC1Asleep] [bit] NULL,
[HealthPC1CommentsGeneral] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HealthPC1CommentsMedical] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HealthPC1ERVisits] [bit] NULL,
[HealthPC1HealthConcern] [bit] NULL,
[HealthPC1MedicalPrenatalAppointments] [bit] NULL,
[HealthPC1PhysicalNeedsAppearUnmet] [bit] NULL,
[HealthPC1TiredIrritable] [bit] NULL,
[HealthPC1WithdrawnUnresponsive] [bit] NULL,
[HealthTCAppearsHealthy] [bit] NULL,
[HealthTCAsleep] [bit] NULL,
[HealthTCCommentsGeneral] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HealthTCCommentsMedical] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HealthTCERVisits] [bit] NULL,
[HealthTCHealthConcern] [bit] NULL,
[HealthTCImmunizations] [bit] NULL,
[HealthTCMedicalWellBabyAppointments] [bit] NULL,
[HealthTCPhysicalNeedsAppearUnmet] [bit] NULL,
[HealthTCTiredIrritable] [bit] NULL,
[HealthTCWithdrawnUnresponsive] [bit] NULL,
[HouseholdChangesComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HouseholdChangesLeft] [bit] NULL,
[HouseholdChangesNew] [bit] NULL,
[HVCaseFK] [int] NOT NULL,
[HVLogCreateDate] [datetime] NOT NULL CONSTRAINT [DF_HVLog_HVLogCreateDate] DEFAULT (getdate()),
[HVLogCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HVLogEditDate] [datetime] NULL,
[HVLogEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HVSupervisorParticipated] [bit] NULL,
[NextScheduledVisit] [datetime] NULL,
[NonPrimaryFSWParticipated] [bit] NULL,
[NonPrimaryFSWFK] [int] NULL,
[OBPParticipated] [bit] NULL,
[OtherLocationSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OtherParticipated] [bit] NULL,
[PAAssessmentIssues] [bit] NULL,
[PAComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PAForms] [bit] NULL,
[PAGroups] [bit] NULL,
[PAIFSP] [bit] NULL,
[PAIntroduceProgram] [bit] NULL,
[PALevelChange] [bit] NULL,
[PAOther] [bit] NULL,
[PARecreation] [bit] NULL,
[PASpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PAVideo] [bit] NULL,
[ParentCompletedActivity] [bit] NULL,
[ParentObservationsDiscussed] [bit] NULL,
[ParticipatedSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1Participated] [bit] NULL,
[PC2Participated] [bit] NULL,
[PCBasicNeeds] [bit] NULL,
[PCChildInteraction] [bit] NULL,
[PCChildManagement] [bit] NULL,
[PCComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCFeelings] [bit] NULL,
[PCOther] [bit] NULL,
[PCShakenBaby] [bit] NULL,
[PCShakenBabyVideo] [bit] NULL,
[PCSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCStress] [bit] NULL,
[PCTechnologyEffects] [bit] NULL,
[POCRAskedQuestions] [bit] NULL,
[POCRComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POCRContributed] [bit] NULL,
[POCRInterested] [bit] NULL,
[POCRNotInterested] [bit] NULL,
[POCRWantedInformation] [bit] NULL,
[ProgramFK] [int] NULL,
[PSCComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSCEmergingIssues] [bit] NULL,
[PSCInitialDiscussion] [bit] NULL,
[PSCImplement] [bit] NULL,
[PSCOngoingDiscussion] [bit] NULL,
[ReferralsComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferralsFollowUp] [bit] NULL,
[ReferralsMade] [bit] NULL,
[ReviewAssessmentIssues] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RSATP] [bit] NULL,
[RSATPComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RSSATP] [bit] NULL,
[RSSATPComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RSFFF] [bit] NULL,
[RSFFFComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RSEW] [bit] NULL,
[RSEWComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RSNormalizing] [bit] NULL,
[RSNormalizingComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RSSFT] [bit] NULL,
[RSSFTComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SiblingParticipated] [bit] NULL,
[SSCalendar] [bit] NULL,
[SSChildCare] [bit] NULL,
[SSChildWelfareServices] [bit] NULL,
[SSComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSEducation] [bit] NULL,
[SSEmployment] [bit] NULL,
[SSHousekeeping] [bit] NULL,
[SSJob] [bit] NULL,
[SSMoneyManagement] [bit] NULL,
[SSOther] [bit] NULL,
[SSProblemSolving] [bit] NULL,
[SSSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSTransportation] [bit] NULL,
[STASQ] [bit] NULL,
[STASQSE] [bit] NULL,
[STComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STPHQ9] [bit] NULL,
[STPSI] [bit] NULL,
[STOther] [bit] NULL,
[SupervisorObservation] [bit] NULL,
[TCAlwaysOnBack] [bit] NULL,
[TCAlwaysWithoutSharing] [bit] NULL,
[TCParticipated] [bit] NULL,
[TotalPercentageSpent] [int] NULL,
[TPComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TPDateInitiated] [date] NULL,
[TPInitiated] [bit] NULL,
[TPNotApplicable] [int] NULL,
[TPOngoingDiscussion] [bit] NULL,
[TPParentDeclined] [bit] NULL,
[TPPlanFinalized] [bit] NULL,
[TPTransitionCompleted] [bit] NULL,
[UpcomingProgramEvents] [bit] NULL,
[VisitLengthHour] [int] NOT NULL,
[VisitLengthMinute] [int] NOT NULL,
[VisitLocation] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VisitStartTime] [datetime] NOT NULL,
[VisitType] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VisitTypeComments] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormComplete] [bit] NULL,
[SiblingsObservation] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NextVisitNotes] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSHomeEnvironment] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create TRIGGER [dbo].[fr_delete_hvlog]
on [dbo].[HVLog]
After DELETE

AS

Declare @PK int

set @PK = (SELECT HVLOGPK from deleted)

BEGIN
	EXEC spDeleteFormReview_Trigger @FormFK=@PK, @FormTypeValue='VL'
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[fr_hvlog]
on [dbo].[HVLog]
After insert

AS

Declare @PK int

set @PK = (SELECT HVLogPK from inserted)

BEGIN
	EXEC spAddFormReview_userTrigger @FormFK=@PK, @FormTypeValue='VL'
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
CREATE TRIGGER [dbo].[fr_HVLog_Edit]
on [dbo].[HVLog]
AFTER UPDATE

AS

Declare @PK int
Declare @UpdatedFormDate datetime 
Declare @FormTypeValue varchar(2)

select @PK = HVLogPK  FROM inserted
select @UpdatedFormDate = VisitStartTime FROM inserted
set @FormTypeValue = 'VL'

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
CREATE TRIGGER [dbo].[TR_HVLogEditDate] ON [dbo].[HVLog]
For Update 
AS
Update HVLog Set HVLog.HVLogEditDate= getdate()
From [HVLog] INNER JOIN Inserted ON [HVLog].[HVLogPK]= Inserted.[HVLogPK]
GO
ALTER TABLE [dbo].[HVLog] ADD CONSTRAINT [PK__HVLog__ED876F581332DBDC] PRIMARY KEY CLUSTERED  ([HVLogPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_HVLog_FormComplete] ON [dbo].[HVLog] ([FormComplete]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_HVLog_FSWFK] ON [dbo].[HVLog] ([FSWFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_HVLog_HVCaseFK] ON [dbo].[HVLog] ([HVCaseFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [HVCase_ProgramFK] ON [dbo].[HVLog] ([HVCaseFK], [ProgramFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_HVLog_ProgramFK] ON [dbo].[HVLog] ([ProgramFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_HVLog_VisitStartTime] ON [dbo].[HVLog] ([VisitStartTime]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_HVLog_VisitType] ON [dbo].[HVLog] ([VisitType]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HVLog] WITH NOCHECK ADD CONSTRAINT [FK_HVLog_FSWFK] FOREIGN KEY ([FSWFK]) REFERENCES [dbo].[Worker] ([WorkerPK])
GO
ALTER TABLE [dbo].[HVLog] WITH NOCHECK ADD CONSTRAINT [FK_HVLog_HVCaseFK] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[HVLog] WITH NOCHECK ADD CONSTRAINT [FK_HVLog_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Do not accept SVN changes', 'SCHEMA', N'dbo', 'TABLE', N'HVLog', 'COLUMN', N'HVLogPK'
GO
