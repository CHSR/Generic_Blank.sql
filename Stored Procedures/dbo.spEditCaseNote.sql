SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditCaseNote](@CaseNotePK int=NULL,
@CaseNoteContents varchar(max)=NULL,
@CaseNoteEditor char(10)=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL,
@CaseNoteDate date=NULL)
AS
UPDATE CaseNote
SET 
CaseNoteContents = @CaseNoteContents, 
CaseNoteEditor = @CaseNoteEditor, 
HVCaseFK = @HVCaseFK, 
ProgramFK = @ProgramFK, 
CaseNoteDate = @CaseNoteDate
WHERE CaseNotePK = @CaseNotePK
GO
