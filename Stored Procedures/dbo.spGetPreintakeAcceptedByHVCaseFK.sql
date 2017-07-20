SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetPreintakeAcceptedByHVCaseFK]
	@HVCaseFK INT,
	@ProgramFK INT

AS

SELECT TOP 1 *
FROM preintake
WHERE hvcasefk = @HVCaseFK
AND programfk = @ProgramFK
AND casestatus = 2
ORDER BY pidate DESC
GO
