SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddPC1Medical](@HospitalNights int=NULL,
@HVCaseFK int=NULL,
@MedicalIssue varchar(500)=NULL,
@PC1ItemDate datetime=NULL,
@PC1MedicalCreator char(10)=NULL,
@PC1MedicalItem char(2)=NULL,
@ProgramFK int=NULL)
AS
INSERT INTO PC1Medical(
HospitalNights,
HVCaseFK,
MedicalIssue,
PC1ItemDate,
PC1MedicalCreator,
PC1MedicalItem,
ProgramFK
)
VALUES(
@HospitalNights,
@HVCaseFK,
@MedicalIssue,
@PC1ItemDate,
@PC1MedicalCreator,
@PC1MedicalItem,
@ProgramFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
