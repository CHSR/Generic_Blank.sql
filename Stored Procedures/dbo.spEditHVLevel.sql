SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditHVLevel](@HVLevelPK int=NULL,
@HVCaseFK int=NULL,
@HVLevelEditor char(10)=NULL,
@LevelAssignDate datetime=NULL,
@LevelFK int=NULL,
@ProgramFK int=NULL)
AS
UPDATE HVLevel
SET 
HVCaseFK = @HVCaseFK, 
HVLevelEditor = @HVLevelEditor, 
LevelAssignDate = @LevelAssignDate, 
LevelFK = @LevelFK, 
ProgramFK = @ProgramFK
WHERE HVLevelPK = @HVLevelPK
GO
