SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditHVGroupParticipants](@HVGroupParticipantsPK int=NULL,
@HVGroupFK int=NULL,
@GroupFatherFigureFK int=NULL,
@HVCaseFK int=NULL,
@HVGroupParticipantsEditor char(10)=NULL,
@ProgramFK int=NULL,
@PCFK int=NULL,
@RoleType char(3)=NULL)
AS
UPDATE HVGroupParticipants
SET 
HVGroupFK = @HVGroupFK, 
GroupFatherFigureFK = @GroupFatherFigureFK, 
HVCaseFK = @HVCaseFK, 
HVGroupParticipantsEditor = @HVGroupParticipantsEditor, 
ProgramFK = @ProgramFK, 
PCFK = @PCFK, 
RoleType = @RoleType
WHERE HVGroupParticipantsPK = @HVGroupParticipantsPK
GO
