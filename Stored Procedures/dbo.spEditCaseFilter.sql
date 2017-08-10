SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditCaseFilter](@CaseFilterPK int=NULL,
@CaseFilterNameFK int=NULL,
@CaseFilterEditor varchar(10)=NULL,
@CaseFilterNameChoice bit=NULL,
@CaseFilterNameOptionFK int=NULL,
@CaseFilterValue varchar(50)=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL,
@CaseFilterNameDate date=NULL)
AS
UPDATE CaseFilter
SET 
CaseFilterNameFK = @CaseFilterNameFK, 
CaseFilterEditor = @CaseFilterEditor, 
CaseFilterNameChoice = @CaseFilterNameChoice, 
CaseFilterNameOptionFK = @CaseFilterNameOptionFK, 
CaseFilterValue = @CaseFilterValue, 
HVCaseFK = @HVCaseFK, 
ProgramFK = @ProgramFK, 
CaseFilterNameDate = @CaseFilterNameDate
WHERE CaseFilterPK = @CaseFilterPK
GO
