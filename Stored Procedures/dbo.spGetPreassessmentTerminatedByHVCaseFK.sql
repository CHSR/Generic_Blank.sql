SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetPreassessmentTerminatedByHVCaseFK]
	@HVCaseFK INT,
	@ProgramFK INT

AS

SELECT TOP 1 *
FROM preassessment
WHERE hvcasefk = @HVCaseFK
AND programfk = @ProgramFK
AND casestatus = 3
ORDER BY padate DESC
GO
