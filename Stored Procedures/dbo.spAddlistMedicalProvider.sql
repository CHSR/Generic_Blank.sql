SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddlistMedicalProvider](@MedicalProviderCreator char(10)=NULL,
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
INSERT INTO listMedicalProvider(
MedicalProviderCreator,
MPAddress,
MPCity,
MPFirstName,
MPIsActive,
MPLastName,
MPPhone,
MPState,
MPZip,
ProgramFK
)
VALUES(
@MedicalProviderCreator,
@MPAddress,
@MPCity,
@MPFirstName,
@MPIsActive,
@MPLastName,
@MPPhone,
@MPState,
@MPZip,
@ProgramFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
