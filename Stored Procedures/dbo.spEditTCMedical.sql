SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditTCMedical](@TCMedicalPK int=NULL,
@ChildType char(2)=NULL,
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
@TCMedicalEditor char(10)=NULL,
@TCMedicalItem char(2)=NULL)
AS
UPDATE TCMedical
SET 
ChildType = @ChildType, 
HospitalNights = @HospitalNights, 
HVCaseFK = @HVCaseFK, 
IsDelayed = @IsDelayed, 
LeadLevelCode = @LeadLevelCode, 
MedicalReason1 = @MedicalReason1, 
MedicalReason2 = @MedicalReason2, 
MedicalReason3 = @MedicalReason3, 
MedicalReason4 = @MedicalReason4, 
MedicalReason5 = @MedicalReason5, 
ProgramFK = @ProgramFK, 
TCIDFK = @TCIDFK, 
TCItemDate = @TCItemDate, 
TCMedicalEditor = @TCMedicalEditor, 
TCMedicalItem = @TCMedicalItem
WHERE TCMedicalPK = @TCMedicalPK
GO
