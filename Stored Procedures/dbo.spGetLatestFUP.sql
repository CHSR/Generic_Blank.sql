SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Chris Papas
-- Create date: 11/29/2012
-- Description:	Get Most recent followup by hvcasefk
-- =============================================
Create PROCEDURE [dbo].[spGetLatestFUP]
(
    @HVCaseFK    INT
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

	SELECT max(FollowUpDate) AS FollowUpDate
		 , ProgramFK
		 , HVCaseFK
	FROM
		FollowUp 
	GROUP BY 
		  ProgramFK
		 , HVCaseFK
	HAVING
		HVCaseFK = @HVCaseFK

END
GO
