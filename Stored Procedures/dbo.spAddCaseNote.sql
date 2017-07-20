SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddCaseNote](@CaseNote varchar(max)=NULL,
@CaseNoteCreator char(10)=NULL,
@CaseNoteDate date=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL)
AS
INSERT INTO CaseNote(
CaseNote,
CaseNoteCreator,
CaseNoteDate,
HVCaseFK,
ProgramFK
)
VALUES(
@CaseNote,
@CaseNoteCreator,
@CaseNoteDate,
@HVCaseFK,
@ProgramFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
