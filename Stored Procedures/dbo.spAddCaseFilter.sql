SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddCaseFilter](@CaseFilterNameFK int=NULL,
@CaseFilterCreator varchar(10)=NULL,
@CaseFilterNameChoice bit=NULL,
@CaseFilterNameOptionFK int=NULL,
@CaseFilterValue varchar(50)=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL,
@CaseFilterNameDate date=NULL)
AS
INSERT INTO CaseFilter(
CaseFilterNameFK,
CaseFilterCreator,
CaseFilterNameChoice,
CaseFilterNameOptionFK,
CaseFilterValue,
HVCaseFK,
ProgramFK,
CaseFilterNameDate
)
VALUES(
@CaseFilterNameFK,
@CaseFilterCreator,
@CaseFilterNameChoice,
@CaseFilterNameOptionFK,
@CaseFilterValue,
@HVCaseFK,
@ProgramFK,
@CaseFilterNameDate
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
