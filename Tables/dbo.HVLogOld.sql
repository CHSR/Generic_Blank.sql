CREATE TABLE [dbo].[HVLogOld]
(
[HVLogOldPK] [int] NOT NULL IDENTITY(1, 1),
[CAChildSupport] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CAAdvocacy] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CAGoods] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CAHousing] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CALaborSupport] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CALegal] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CAOther] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CAParentRights] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CASpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CATranslation] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CATransportation] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CAVisitation] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CDChildDevelopment] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CDOther] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CDParentConcerned] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CDSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CDToys] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CIProblems] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CIOther] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CIOtherSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Curriculum247Dads] [bit] NULL,
[CurriculumBoyz2Dads] [bit] NULL,
[CurriculumGrowingGreatKids] [bit] NULL,
[CurriculumHelpingBabiesLearn] [bit] NULL,
[CurriculumInsideOutDads] [bit] NULL,
[CurriculumMomGateway] [bit] NULL,
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
[FFCommunication] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FFDomesticViolence] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FFFamilyRelations] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FFMentalHealth] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FFOther] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FFSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FFSubstanceAbuse] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FSWFK] [int] NULL,
[GrandParentParticipated] [bit] NULL,
[HCBreastFeeding] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCChild] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCDental] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCFamilyPlanning] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCFASD] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCFeeding] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCGeneral] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCMedicalAdvocacy] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCNutrition] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCOther] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCPrenatalCare] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCProviders] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCSafety] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCSexEducation] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCSIDS] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCSmoking] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HVCaseFK] [int] NOT NULL,
[HVLogCreateDate] [datetime] NOT NULL CONSTRAINT [DF_HVLogOld_HVLogCreateDate] DEFAULT (getdate()),
[HVLogCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HVLogEditDate] [datetime] NULL,
[HVLogEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HVSupervisorParticipated] [bit] NULL,
[NonPrimaryFSWParticipated] [bit] NULL,
[NonPrimaryFSWFK] [int] NULL,
[OBPParticipated] [bit] NULL,
[OtherLocationSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OtherParticipated] [bit] NULL,
[PAAssessmentIssues] [bit] NULL,
[PAForms] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PAGroups] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PAIFSP] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PAOther] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PARecreation] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PASpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PAVideo] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParentCompletedActivity] [bit] NULL,
[ParentObservationsDiscussed] [bit] NULL,
[ParticipatedSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1Participated] [bit] NULL,
[PC2Participated] [bit] NULL,
[PCBasicNeeds] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCChildInteraction] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCChildManagement] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCFeelings] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCOther] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCShakenBaby] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCShakenBabyVideo] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCStress] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramFK] [int] NULL,
[ReviewAssessmentIssues] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SiblingParticipated] [bit] NULL,
[SSCalendar] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSChildCare] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSEducation] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSEmployment] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSHousekeeping] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSJob] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSMoneyManagement] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSOther] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSProblemSolving] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSTransportation] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupervisorObservation] [bit] NULL,
[TCAlwaysOnBack] [bit] NULL,
[TCAlwaysWithoutSharing] [bit] NULL,
[TCParticipated] [bit] NULL,
[TotalPercentageSpent] [int] NULL,
[UpcomingProgramEvents] [bit] NULL,
[VisitLengthHour] [int] NOT NULL,
[VisitLengthMinute] [int] NOT NULL,
[VisitLocation] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VisitStartTime] [datetime] NOT NULL,
[VisitType] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HVLogOld] ADD CONSTRAINT [PK__HVLogOld__ED876F581332DBDC] PRIMARY KEY CLUSTERED  ([HVLogOldPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HVLogOld] WITH NOCHECK ADD CONSTRAINT [FK_HVLogOld_FSWFK] FOREIGN KEY ([FSWFK]) REFERENCES [dbo].[Worker] ([WorkerPK])
GO
ALTER TABLE [dbo].[HVLogOld] WITH NOCHECK ADD CONSTRAINT [FK_HVLogOld_HVCaseFK] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[HVLogOld] WITH NOCHECK ADD CONSTRAINT [FK_HVLogOld_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Do not accept SVN changes', 'SCHEMA', N'dbo', 'TABLE', N'HVLogOld', 'COLUMN', N'HVLogOldPK'
GO
