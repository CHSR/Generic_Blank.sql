SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[spGetPreassessmentAssessmentCompletedByHVCaseFK]
	@HVCaseFK INT,
	@ProgramFK INT

AS

SELECT TOP 1 *
FROM preassessment
WHERE hvcasefk = @HVCaseFK
AND ProgramFK = isnull(@ProgramFK, ProgramFK)
AND (casestatus = 2 OR casestatus = 4)
ORDER BY padate DESC
GO
