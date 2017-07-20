SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddTCMedical](@ChildType char(2)=NULL,
@HospitalNights int=NULL,
@HVCaseFK int=NULL,
@IsDelayed bit=NULL,
@LeadLevelCode char(2)=NULL,
@MedicalReason1 char(2)=NULL,
@MedicalReason2 char(2)=NULL,
@MedicalReason3 char(2)=NULL,
@MedicalReason4 char(2)=NULL,
@MedicalReason5 char(2)=NULL,
@ProgramFK int=NULL,
@TCIDFK int=NULL,
@TCItemDate datetime=NULL,
@TCMedicalCreator char(10)=NULL,
@TCMedicalItem char(2)=NULL)
AS
INSERT INTO TCMedical(
ChildType,
HospitalNights,
HVCaseFK,
IsDelayed,
LeadLevelCode,
MedicalReason1,
MedicalReason2,
MedicalReason3,
MedicalReason4,
MedicalReason5,
ProgramFK,
TCIDFK,
TCItemDate,
TCMedicalCreator,
TCMedicalItem
)
VALUES(
@ChildType,
@HospitalNights,
@HVCaseFK,
@IsDelayed,
@LeadLevelCode,
@MedicalReason1,
@MedicalReason2,
@MedicalReason3,
@MedicalReason4,
@MedicalReason5,
@ProgramFK,
@TCIDFK,
@TCItemDate,
@TCMedicalCreator,
@TCMedicalItem
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
