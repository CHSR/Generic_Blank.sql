SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddlistMedicalFacility](@MFAddress char(40)=NULL,
@MFCity char(20)=NULL,
@MFCreator char(10)=NULL,
@MFIsActive bit=NULL,
@MFName char(50)=NULL,
@MFPhone char(12)=NULL,
@MFState char(2)=NULL,
@MFZip char(10)=NULL,
@ProgramFK int=NULL)
AS
INSERT INTO listMedicalFacility(
MFAddress,
MFCity,
MFCreator,
MFIsActive,
MFName,
MFPhone,
MFState,
MFZip,
ProgramFK
)
VALUES(
@MFAddress,
@MFCity,
@MFCreator,
@MFIsActive,
@MFName,
@MFPhone,
@MFState,
@MFZip,
@ProgramFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
