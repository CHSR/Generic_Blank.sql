SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditCIVictim](@CIVictimPK int=NULL,
@CIVictimEditor char(10)=NULL,
@CriticalIncidentFK int=NULL,
@IncidentType char(2)=NULL,
@VictimCategory char(2)=NULL,
@VictimDOB datetime=NULL,
@VictimGender char(2)=NULL,
@VictimName varchar(200)=NULL)
AS
UPDATE CIVictim
SET 
CIVictimEditor = @CIVictimEditor, 
CriticalIncidentFK = @CriticalIncidentFK, 
IncidentType = @IncidentType, 
VictimCategory = @VictimCategory, 
VictimDOB = @VictimDOB, 
VictimGender = @VictimGender, 
VictimName = @VictimName
WHERE CIVictimPK = @CIVictimPK
GO
