SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddProgressNotes](@HVCaseFK int=NULL,
@ProgramFK int=NULL,
@ProgressNotes varchar(max)=NULL,
@ProgressNotesCreator char(10)=NULL)
AS
INSERT INTO ProgressNotes(
HVCaseFK,
ProgramFK,
ProgressNotes,
ProgressNotesCreator
)
VALUES(
@HVCaseFK,
@ProgramFK,
@ProgressNotes,
@ProgressNotesCreator
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
