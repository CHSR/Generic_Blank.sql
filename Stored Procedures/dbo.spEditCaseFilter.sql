SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditCaseFilter](@CaseFilterPK int=NULL,
@CaseFilterNameFK int=NULL,
@CaseFilterEditor varchar(10)=NULL,
@CaseFilterNameChoice bit=NULL,
@CaseFilterNameDate date=NULL,
@CaseFilterNameOptionFK int=NULL,
@CaseFilterValue varchar(50)=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL)
AS
UPDATE CaseFilter
SET 
CaseFilterNameFK = @CaseFilterNameFK, 
CaseFilterEditor = @CaseFilterEditor, 
CaseFilterNameChoice = @CaseFilterNameChoice, 
CaseFilterNameDate = @CaseFilterNameDate, 
CaseFilterNameOptionFK = @CaseFilterNameOptionFK, 
CaseFilterValue = @CaseFilterValue, 
HVCaseFK = @HVCaseFK, 
ProgramFK = @ProgramFK
WHERE CaseFilterPK = @CaseFilterPK
GO
