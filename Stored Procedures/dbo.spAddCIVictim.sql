SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddCIVictim](@CIVictimCreator char(10)=NULL,
@CriticalIncidentFK int=NULL,
@IncidentType char(2)=NULL,
@VictimCategory char(2)=NULL,
@VictimDOB datetime=NULL,
@VictimGender char(2)=NULL,
@VictimName varchar(200)=NULL)
AS
INSERT INTO CIVictim(
CIVictimCreator,
CriticalIncidentFK,
IncidentType,
VictimCategory,
VictimDOB,
VictimGender,
VictimName
)
VALUES(
@CIVictimCreator,
@CriticalIncidentFK,
@IncidentType,
@VictimCategory,
@VictimDOB,
@VictimGender,
@VictimName
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
