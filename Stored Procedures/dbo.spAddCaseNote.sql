SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddCaseNote](@CaseNoteContents varchar(max)=NULL,
@CaseNoteCreator char(10)=NULL,
@CaseNoteDate date=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL)
AS
INSERT INTO CaseNote(
CaseNoteContents,
CaseNoteCreator,
CaseNoteDate,
HVCaseFK,
ProgramFK
)
VALUES(
@CaseNoteContents,
@CaseNoteCreator,
@CaseNoteDate,
@HVCaseFK,
@ProgramFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
