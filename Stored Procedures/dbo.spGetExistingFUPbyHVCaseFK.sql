SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jay Robohn
-- Create date: Jul 22, 2010
-- Description:	all Existing Follow Ups by HVCaseFK; Used to find specific FUPs that have
--              been entered, eg, for Discharge to make sure there are no 
--              98s or 99s (pre and post-natal discharge FUPs) for the case
-- =============================================
CREATE procedure [dbo].[spGetExistingFUPbyHVCaseFK]
(
    @HVCaseFK    INT,
    @FUPInterval VARCHAR(2)
)

-- Add the parameters for the stored procedure here
--	<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
--	<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here

	SELECT FollowUpDate
		 , FollowUpPK
		 , PC1InHome
		 , PC2InHome
--		 , OBPInHome
		 , FUPInWindow
		 , ProgramFK
		 , HVCaseFK
		 , appCodeText AS FupIntervalText
		 , appCode AS FupInterval
	FROM
		FollowUp f
		INNER JOIN codeApp c
			ON c.appCode = f.FollowUpInterval
	WHERE
		HVCaseFK = @HVCaseFK
		AND FollowUpInterval = @FUPInterval
		AND appCodeGroup = 'TCAge'
		AND appCodeUsedWhere LIKE '%FU'

END
GO
