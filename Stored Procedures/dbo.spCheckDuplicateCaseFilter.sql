SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spCheckDuplicateCaseFilter]

(@HVCaseFK INT, @ProgramFK INT, @CaseFilterNameFK INT)
AS
SET NOCOUNT ON;

SELECT count(*) AS n
FROM CaseFilter 
WHERE HVCaseFK = @HVCaseFK AND ProgramFK = @ProgramFK 
AND CaseFilterNameFK = @CaseFilterNameFK
GO
