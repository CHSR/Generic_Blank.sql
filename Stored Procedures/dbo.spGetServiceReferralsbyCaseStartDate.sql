SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE  [dbo].[spGetServiceReferralsbyCaseStartDate](
	@HVCaseFK INT,
	@CaseStartDate DATETIME
)

AS
BEGIN
	SET NOCOUNT ON;

    SELECT DISTINCT sr.*
	FROM ServiceReferral sr
	INNER JOIN caseprogram cp
	ON sr.hvcasefk = cp.hvcasefk
	AND sr.programfk = cp.programfk
	WHERE sr.HVCaseFK = @HVCaseFK
	AND casestartdate <= @CaseStartDate
	AND referraldate <= ISNULL(dischargedate,GETDATE())
	ORDER BY referraldate
	 
END






GO
