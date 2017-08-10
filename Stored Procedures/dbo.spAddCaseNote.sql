SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddCaseNote](@CaseNoteContents varchar(max)=NULL,
@CaseNoteCreator char(10)=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL,
@CaseNoteDate date=NULL)
AS
INSERT INTO CaseNote(
CaseNoteContents,
CaseNoteCreator,
HVCaseFK,
ProgramFK,
CaseNoteDate
)
VALUES(
@CaseNoteContents,
@CaseNoteCreator,
@HVCaseFK,
@ProgramFK,
@CaseNoteDate
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
