SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditlistMedicalProvider](@listMedicalProviderPK int=NULL,
@MedicalProviderEditor char(10)=NULL,
@MPAddress char(40)=NULL,
@MPCity char(20)=NULL,
@MPFirstName varchar(200)=NULL,
@MPIsActive bit=NULL,
@MPLastName varchar(200)=NULL,
@MPPhone char(12)=NULL,
@MPState char(2)=NULL,
@MPZip char(10)=NULL,
@ProgramFK int=NULL)
AS
UPDATE listMedicalProvider
SET 
MedicalProviderEditor = @MedicalProviderEditor, 
MPAddress = @MPAddress, 
MPCity = @MPCity, 
MPFirstName = @MPFirstName, 
MPIsActive = @MPIsActive, 
MPLastName = @MPLastName, 
MPPhone = @MPPhone, 
MPState = @MPState, 
MPZip = @MPZip, 
ProgramFK = @ProgramFK
WHERE listMedicalProviderPK = @listMedicalProviderPK
GO
