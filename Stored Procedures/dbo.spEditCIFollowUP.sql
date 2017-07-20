SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditCIFollowUP](@CIFollowUpPK int=NULL,
@ActionTaken varchar(1000)=NULL,
@CIFollowUpEditor char(10)=NULL,
@CriticalIncidentFK int=NULL,
@FollowUpDue datetime=NULL,
@HVCaseFK int=NULL,
@IncidentFollowUpDate datetime=NULL,
@IncidentResolved bit=NULL,
@MoreFollowUpNeeded bit=NULL,
@NewCriticalIncidentInfo varchar(1000)=NULL,
@NewDFYSReportMade bit=NULL,
@OriginalIncidentDate datetime=NULL,
@ProgramFK int=NULL,
@ReportByStaff char(1)=NULL,
@ReportSubstantiated char(1)=NULL)
AS
UPDATE CIFollowUP
SET 
ActionTaken = @ActionTaken, 
CIFollowUpEditor = @CIFollowUpEditor, 
CriticalIncidentFK = @CriticalIncidentFK, 
FollowUpDue = @FollowUpDue, 
HVCaseFK = @HVCaseFK, 
IncidentFollowUpDate = @IncidentFollowUpDate, 
IncidentResolved = @IncidentResolved, 
MoreFollowUpNeeded = @MoreFollowUpNeeded, 
NewCriticalIncidentInfo = @NewCriticalIncidentInfo, 
NewDFYSReportMade = @NewDFYSReportMade, 
OriginalIncidentDate = @OriginalIncidentDate, 
ProgramFK = @ProgramFK, 
ReportByStaff = @ReportByStaff, 
ReportSubstantiated = @ReportSubstantiated
WHERE CIFollowUPPK = @CIFollowUPPK
GO
