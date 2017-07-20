SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Modified: Dorothy : included discharged cases to compare with new start dates as overlapping (timewise)
-- cases are not allowed
-- 05/07/2012 - Modified: Chris and Devinder - DB's previous modification was for Famsys (NJ), HFNY does allow overlapping cases
-- as long as there is no open case.

-- =============================================
CREATE PROCEDURE [dbo].[spGetOpenCase]
	-- Add the parameters for the stored procedure here
	@PersonPK as Int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT CaseProgramPK, CaseStartDate, DischargeDate, EDC, TCDOB 
	FROM CaseProgram 
	INNER JOIN HVCASE ON HVCase.HVCasePK = CaseProgram.HVCaseFK
	WHERE PC1FK = @PersonPK AND DischargeDate IS NULL

END

GO
