SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditPC1Medical](@PC1MedicalPK int=NULL,
@HospitalNights int=NULL,
@HVCaseFK int=NULL,
@MedicalIssue varchar(500)=NULL,
@PC1ItemDate datetime=NULL,
@PC1MedicalEditor char(10)=NULL,
@PC1MedicalItem char(2)=NULL,
@ProgramFK int=NULL)
AS
UPDATE PC1Medical
SET 
HospitalNights = @HospitalNights, 
HVCaseFK = @HVCaseFK, 
MedicalIssue = @MedicalIssue, 
PC1ItemDate = @PC1ItemDate, 
PC1MedicalEditor = @PC1MedicalEditor, 
PC1MedicalItem = @PC1MedicalItem, 
ProgramFK = @ProgramFK
WHERE PC1MedicalPK = @PC1MedicalPK
GO
