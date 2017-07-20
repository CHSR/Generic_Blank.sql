SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE  [dbo].[spGetPreintakesbyCaseStartDate](
	@HVCaseFK INT,
	@CaseStartDate DATETIME
)

AS
BEGIN
	SET NOCOUNT ON;

    SELECT DISTINCT Preintake.*
	FROM Preintake
	INNER JOIN caseprogram cp
	ON Preintake.hvcasefk = cp.hvcasefk
	WHERE Preintake.HVCaseFK = @HVCaseFK
	AND casestartdate <= @CaseStartDate
	AND pidate <= ISNULL(dischargedate,GETDATE())
	ORDER BY PIDate DESC, CaseStatus DESC
	 
END
GO
