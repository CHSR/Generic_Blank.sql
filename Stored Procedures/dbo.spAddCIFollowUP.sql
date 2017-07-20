SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddCIFollowUP](@ActionTaken varchar(1000)=NULL,
@CIFollowUpCreator char(10)=NULL,
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
INSERT INTO CIFollowUP(
ActionTaken,
CIFollowUpCreator,
CriticalIncidentFK,
FollowUpDue,
HVCaseFK,
IncidentFollowUpDate,
IncidentResolved,
MoreFollowUpNeeded,
NewCriticalIncidentInfo,
NewDFYSReportMade,
OriginalIncidentDate,
ProgramFK,
ReportByStaff,
ReportSubstantiated
)
VALUES(
@ActionTaken,
@CIFollowUpCreator,
@CriticalIncidentFK,
@FollowUpDue,
@HVCaseFK,
@IncidentFollowUpDate,
@IncidentResolved,
@MoreFollowUpNeeded,
@NewCriticalIncidentInfo,
@NewDFYSReportMade,
@OriginalIncidentDate,
@ProgramFK,
@ReportByStaff,
@ReportSubstantiated
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
