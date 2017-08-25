CREATE TABLE [dbo].[Supervision]
(
[SupervisionPK] [int] NOT NULL IDENTITY(1, 1),
[ActivitiesOther] [bit] NULL,
[ActivitiesOtherSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AreasGrowth] [bit] NULL,
[AssessmentIssues] [bit] NULL,
[AssessmentRate] [bit] NULL,
[Boundaries] [bit] NULL,
[Caseload] [bit] NULL,
[Coaching] [bit] NULL,
[CommunityResources] [bit] NULL,
[CulturalSensitivity] [bit] NULL,
[Curriculum] [bit] NULL,
[FamilyProgress] [bit] NULL,
[HomeVisitLogActivities] [bit] NULL,
[HomeVisitRate] [bit] NULL,
[IFSP] [bit] NULL,
[ImplementTraining] [bit] NULL,
[LevelChange] [bit] NULL,
[Outreach] [bit] NULL,
[ParticipantEmergency] [bit] NULL,
[PersonalGrowth] [bit] NULL,
[ProfessionalGrowth] [bit] NULL,
[ProgramFK] [int] NULL,
[ReasonOther] [bit] NULL,
[ReasonOtherSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordDocumentation] [bit] NULL,
[Referrals] [bit] NULL,
[Retention] [bit] NULL,
[RolePlaying] [bit] NULL,
[Safety] [bit] NULL,
[ShortWeek] [bit] NULL,
[StaffCourt] [bit] NULL,
[StaffFamilyEmergency] [bit] NULL,
[StaffForgot] [bit] NULL,
[StaffIll] [bit] NULL,
[StaffTraining] [bit] NULL,
[StaffVacation] [bit] NULL,
[StaffOutAllWeek] [bit] NULL,
[StrengthBasedApproach] [bit] NULL,
[Strengths] [bit] NULL,
[SupervisionCreateDate] [datetime] NOT NULL CONSTRAINT [DF_Supervision_SupervisionCreateDate] DEFAULT (getdate()),
[SupervisionCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupervisionDate] [datetime] NOT NULL,
[SupervisionEditDate] [datetime] NULL,
[SupervisionEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupervisionEndTime] [datetime] NOT NULL,
[SupervisionHours] [int] NULL,
[SupervisionMinutes] [int] NULL,
[SupervisionNotes] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupervisionStartTime] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupervisorFamilyEmergency] [bit] NULL,
[SupervisorFK] [int] NOT NULL,
[SupervisorForgot] [bit] NULL,
[SupervisorHoliday] [bit] NULL,
[SupervisorIll] [bit] NULL,
[SupervisorObservationAssessment] [bit] NULL,
[SupervisorObservationHomeVisit] [bit] NULL,
[SupervisorTraining] [bit] NULL,
[SupervisorVacation] [bit] NULL,
[TakePlace] [bit] NULL,
[TechniquesApproaches] [bit] NULL,
[Tools] [bit] NULL,
[TrainingNeeds] [bit] NULL,
[Weather] [bit] NULL,
[WorkerFK] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		jrobohn
-- Create date: 2014Feb24
-- Description:	Delete FormReview row when  
--				the Supervision row deleted
-- =============================================
CREATE TRIGGER [dbo].[fr_delete_Supervision]
on [dbo].[Supervision]
After DELETE
AS
Declare @PK int

set @PK = (SELECT SupervisionPK from deleted)

BEGIN
	EXEC spDeleteFormReview_Trigger @FormFK=@PK, @FormTypeValue='SU'
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		jrobohn
-- Create date: 2014Feb24
-- Description:	Add FormReview row when 
--				inserting Supervision row
-- =============================================
CREATE TRIGGER [dbo].[fr_Supervision]
on [dbo].[Supervision]
After insert

AS

Declare @PK int

set @PK = (SELECT SupervisionPK from inserted)

BEGIN
	EXEC spAddFormReview_userTriggernoHVCaseFK @FormFK=@PK, @FormTypeValue='SU'
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		jrobohn
-- Create date: 2014Feb24
-- Description:	Change FormReview's formdate if 
--				the Supervision date changed
-- =============================================
CREATE trigger [dbo].[fr_Supervision_Edit]
on [dbo].[Supervision]
after update

AS

declare @PK int
declare @UpdatedFormDate datetime 
declare @FormTypeValue varchar(2)

select @PK = SupervisionPK FROM inserted
select @UpdatedFormDate = SupervisionDate FROM inserted
set @FormTypeValue = 'SU'

begin
	update FormReview
	set FormDate=@UpdatedFormDate
	where FormFK=@PK 
			and FormType=@FormTypeValue

END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_SupervisionEditDate ON Supervision
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- =============================================
-- Author:		jrobohn
-- Create date: 2014Feb24
-- Description:	Change FormReview's editdate if 
--				Supervision row has been edited
-- =============================================
CREATE trigger [dbo].[TR_SupervisionEditDate] ON [dbo].[Supervision]
For Update 
AS
Update Supervision Set Supervision.SupervisionEditDate= getdate()
From [Supervision] INNER JOIN Inserted ON [Supervision].[SupervisionPK]= Inserted.[SupervisionPK]
GO
ALTER TABLE [dbo].[Supervision] ADD CONSTRAINT [PK__Supervis__3AC5E6F97D0E9093] PRIMARY KEY CLUSTERED  ([SupervisionPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_Supervision_SupervisorFK] ON [dbo].[Supervision] ([SupervisorFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_Supervision_WorkerFK] ON [dbo].[Supervision] ([WorkerFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Supervision] WITH NOCHECK ADD CONSTRAINT [FK_Supervision_HVProgram] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
ALTER TABLE [dbo].[Supervision] WITH NOCHECK ADD CONSTRAINT [FK_Supervision_SupervisorFK] FOREIGN KEY ([SupervisorFK]) REFERENCES [dbo].[Worker] ([WorkerPK])
GO
ALTER TABLE [dbo].[Supervision] WITH NOCHECK ADD CONSTRAINT [FK_Supervision_WorkerFK] FOREIGN KEY ([WorkerFK]) REFERENCES [dbo].[Worker] ([WorkerPK])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Do not accept SVN changes', 'SCHEMA', N'dbo', 'TABLE', N'Supervision', 'COLUMN', N'SupervisionPK'
GO
