SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Dorothy Baum
-- Create date: June 9, 2009
-- Modified: Aug 27, 2009 (added HVCaseFK to data)
-- Description:	ASQ data by TCIDFK
-- =============================================
CREATE procedure [dbo].[spGetAllASQbyTCIDFK]
(
    @TCIDFK int
)
-- Add the parameters for the stored procedure here
--	<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
--	<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>
as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

	-- Insert statements for procedure here
	select appCodeText as TCAgeText
		  ,appCode as TCAge
		  ,DateCompleted
		  ,ASQPK
		  ,HVCaseFK
		  ,ProgramFK
		  ,TCIDFK
		from (select appCodeText
					,appCode
				  from codeApp
				  where appCodeGroup = 'TCAge'
					   and appCodeUsedWhere like '%AQ%') a
			left outer join (select convert(varchar(20),DateCompleted,101) as DateCompleted
								   ,TCAge
								   ,ASQPK
								   ,HVCaseFK
								   ,ProgramFK
								   ,TCIDFK
								 from ASQ
								 where TCIDFK = @TCIDFK) b on a.appCode = b.TCAge
		order by cast(appCode as int)

end
GO
