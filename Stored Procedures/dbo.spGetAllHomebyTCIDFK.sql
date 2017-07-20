SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[spGetAllHomebyTCIDFK]  
	-- Add the parameters for the stored procedure here
	@TCIDFK int	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select appCodeText as TCAgeText,appCode as TCAge,CompleteDate,HomePK,HVCaseFK, ProgramFK, TCIDFK
      from (select appCodeText,appCode 
			  from codeApp 
			 where appCodeGroup='TCAge' and appCodeUsedWhere like '%HO%')a   
	  Left outer join (select CONVERT(VARCHAR(20),CompleteDate,101) AS CompleteDate,TCAge,HomePK,HVCaseFK, ProgramFK, TCIDFK 
						 from Home
						where TCIDFK =@TCIDFK)b 
		   on a.appCode=b.TCAge 
	 order by cast(appCode as int)

END

GO
