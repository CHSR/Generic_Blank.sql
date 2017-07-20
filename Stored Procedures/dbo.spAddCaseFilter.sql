SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddCaseFilter](@CaseFilterNameFK int=NULL,
@CaseFilterCreator varchar(10)=NULL,
@CaseFilterNameChoice bit=NULL,
@CaseFilterNameDate date=NULL,
@CaseFilterNameOptionFK int=NULL,
@CaseFilterValue varchar(50)=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL)
AS
INSERT INTO CaseFilter(
CaseFilterNameFK,
CaseFilterCreator,
CaseFilterNameChoice,
CaseFilterNameDate,
CaseFilterNameOptionFK,
CaseFilterValue,
HVCaseFK,
ProgramFK
)
VALUES(
@CaseFilterNameFK,
@CaseFilterCreator,
@CaseFilterNameChoice,
@CaseFilterNameDate,
@CaseFilterNameOptionFK,
@CaseFilterValue,
@HVCaseFK,
@ProgramFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
