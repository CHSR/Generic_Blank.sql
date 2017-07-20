SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditCriticalIncident](@CriticalIncidentPK int=NULL,
@ActionTaken varchar(1000)=NULL,
@AssignedWorkerFK int=NULL,
@CriticalIncidentDate datetime=NULL,
@CriticalIncidentEditor char(10)=NULL,
@DYFSReportMade char(1)=NULL,
@DYFSReportSubstantiated char(1)=NULL,
@FollowUpDue datetime=NULL,
@FollowUpRequired char(1)=NULL,
@HVCaseFK int=NULL,
@IncidentDescription varchar(1000)=NULL,
@IncidentReportedBy varchar(30)=NULL,
@IncidentReportedTo varchar(30)=NULL,
@IncidentResolved bit=NULL,
@IncidentTime char(5)=NULL,
@PCANJNotifiedDate datetime=NULL,
@PCNJIncidentReportedTo char(2)=NULL,
@PCNJNotificationReceived datetime=NULL,
@PCNJReportedVia char(2)=NULL,
@ProgramFK int=NULL,
@ServiceLevelFK int=NULL,
@SiteInformedDate datetime=NULL,
@StaffReport char(1)=NULL,
@SupervisorFK int=NULL)
AS
UPDATE CriticalIncident
SET 
ActionTaken = @ActionTaken, 
AssignedWorkerFK = @AssignedWorkerFK, 
CriticalIncidentDate = @CriticalIncidentDate, 
CriticalIncidentEditor = @CriticalIncidentEditor, 
DYFSReportMade = @DYFSReportMade, 
DYFSReportSubstantiated = @DYFSReportSubstantiated, 
FollowUpDue = @FollowUpDue, 
FollowUpRequired = @FollowUpRequired, 
HVCaseFK = @HVCaseFK, 
IncidentDescription = @IncidentDescription, 
IncidentReportedBy = @IncidentReportedBy, 
IncidentReportedTo = @IncidentReportedTo, 
IncidentResolved = @IncidentResolved, 
IncidentTime = @IncidentTime, 
PCANJNotifiedDate = @PCANJNotifiedDate, 
PCNJIncidentReportedTo = @PCNJIncidentReportedTo, 
PCNJNotificationReceived = @PCNJNotificationReceived, 
PCNJReportedVia = @PCNJReportedVia, 
ProgramFK = @ProgramFK, 
ServiceLevelFK = @ServiceLevelFK, 
SiteInformedDate = @SiteInformedDate, 
StaffReport = @StaffReport, 
SupervisorFK = @SupervisorFK
WHERE CriticalIncidentPK = @CriticalIncidentPK
GO
