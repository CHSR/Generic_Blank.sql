SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[spGetLastPreassessmentByHVCaseFK]
	@HVCaseFK INT,
	@ProgramFK INT = NULL

AS

SELECT TOP 1 *
FROM preassessment
WHERE hvcasefk = @HVCaseFK
AND programfk = ISNULL(@ProgramFK, programfk)
ORDER BY padate DESC



GO
