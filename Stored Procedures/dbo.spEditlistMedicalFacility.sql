SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditlistMedicalFacility](@listMedicalFacilityPK int=NULL,
@MFAddress char(40)=NULL,
@MFCity char(20)=NULL,
@MFEditor char(10)=NULL,
@MFIsActive bit=NULL,
@MFName char(50)=NULL,
@MFPhone char(12)=NULL,
@MFState char(2)=NULL,
@MFZip char(10)=NULL,
@ProgramFK int=NULL)
AS
UPDATE listMedicalFacility
SET 
MFAddress = @MFAddress, 
MFCity = @MFCity, 
MFEditor = @MFEditor, 
MFIsActive = @MFIsActive, 
MFName = @MFName, 
MFPhone = @MFPhone, 
MFState = @MFState, 
MFZip = @MFZip, 
ProgramFK = @ProgramFK
WHERE listMedicalFacilityPK = @listMedicalFacilityPK
GO
