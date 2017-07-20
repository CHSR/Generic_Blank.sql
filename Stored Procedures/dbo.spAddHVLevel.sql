SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddHVLevel](@HVCaseFK int=NULL,
@HVLevelCreator char(10)=NULL,
@LevelAssignDate datetime=NULL,
@LevelFK int=NULL,
@ProgramFK int=NULL)
AS
INSERT INTO HVLevel(
HVCaseFK,
HVLevelCreator,
LevelAssignDate,
LevelFK,
ProgramFK
)
VALUES(
@HVCaseFK,
@HVLevelCreator,
@LevelAssignDate,
@LevelFK,
@ProgramFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
