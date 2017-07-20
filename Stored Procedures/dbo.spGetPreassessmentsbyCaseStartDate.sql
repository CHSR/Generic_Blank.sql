SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE  [dbo].[spGetPreassessmentsbyCaseStartDate](
	@HVCaseFK INT,
	@CaseStartDate DATETIME
)

AS
BEGIN
	SET NOCOUNT ON;

    SELECT DISTINCT pa.*
	FROM Preassessment pa
	INNER JOIN caseprogram cp
	ON pa.hvcasefk = cp.hvcasefk
	AND pa.programfk = cp.programfk
	WHERE pa.HVCaseFK = @HVCaseFK
	AND casestartdate <= @CaseStartDate
	AND padate <= ISNULL(dischargedate,padate)
	ORDER BY PADate DESC, CaseStatus DESC
	 
END



GO
