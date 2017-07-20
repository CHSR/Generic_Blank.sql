SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jay Robohn
-- Create date: Nov 12, 2011
-- Description:	all Follow Ups by HVCaseFK; Used for the navagation page
-- =============================================
CREATE PROCEDURE [dbo].[spGetAllFUPbyHVCaseFK]  (@HVCaseFK int)
	-- Add the parameters for the stored procedure here
--	<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
--	<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select appCodeText AS FupIntervalText
			,appCode as FupInterval
			,FollowUpDate
			,FollowUpPK
			,PC1InHome
			,PC2InHome
			,OBPInHome
			,FUPInWindow
			,ProgramFK
			,HVCaseFK
	from (select appCodeText,appCode 
		from codeApp 
		where appCodeGroup='TCAge' and appCodeUsedWhere like '%FU') a
	Left outer join (select CONVERT(VARCHAR(20),FollowUpDate,101) AS FollowUpDate
							,FollowUpInterval as TCAge
							,FollowUpPK
							,PC1InHome
							,isnull(cafuobp.OBPInHome, '') as OBPInHome
							,PC2InHome
							,FUPInWindow
							,fu.ProgramFK
							,fu.HVCaseFK
					from FollowUp fu
					inner join CommonAttributes ca on ca.FormFK=fu.FollowUpPK and ca.FormInterval=fu.FollowUpInterval AND ca.FormType = 'FU'
					left outer join CommonAttributes cafuobp on cafuobp.FormFK=fu.FollowUpPK and cafuobp.FormInterval=fu.FollowUpInterval AND cafuobp.FormType = 'FU-OBP'
					where fu.HVCaseFK =@HVCaseFK		
					) b 
	on a.appCode=b.TCAge
	ORDER BY FupInterval

END











GO
