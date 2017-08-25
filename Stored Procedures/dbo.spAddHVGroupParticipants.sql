SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddHVGroupParticipants](@HVGroupFK int=NULL,
@GroupFatherFigureFK int=NULL,
@HVCaseFK int=NULL,
@HVGroupParticipantsCreator char(10)=NULL,
@ProgramFK int=NULL,
@PCFK int=NULL,
@RoleType char(3)=NULL)
AS
INSERT INTO HVGroupParticipants(
HVGroupFK,
GroupFatherFigureFK,
HVCaseFK,
HVGroupParticipantsCreator,
ProgramFK,
PCFK,
RoleType
)
VALUES(
@HVGroupFK,
@GroupFatherFigureFK,
@HVCaseFK,
@HVGroupParticipantsCreator,
@ProgramFK,
@PCFK,
@RoleType
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
