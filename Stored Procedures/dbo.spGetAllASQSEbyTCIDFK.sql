SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Dorothy Baum
-- Create date: June 28, 2009
-- Description:	ASQSE data by TCIDFK
-- =============================================
CREATE procedure [dbo].[spGetAllASQSEbyTCIDFK]
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
		  ,appCode as ASQSETCAge
		  ,DateCompleted as ASQSEDateCompleted
		  ,ASQSEPK
		  ,HVCaseFK
		  ,ProgramFK
		  ,TCIDFK
		from (select appCodeText
					,appCode
				  from codeApp
				  where appCodeGroup = 'TCAge'
					   and appCodeUsedWhere like '%AS%') a
			left outer join (select convert(varchar(20),ASQSEDateCompleted,101) as DateCompleted
								   ,ASQSETCAge as TCAge
								   ,ASQSEPK
								   ,HVCaseFK
								   ,ProgramFK
								   ,TCIDFK
								 from ASQSE
								 where TCIDFK = @TCIDFK) b on a.appCode = b.TCAge
		order by cast(appCode as int)


end
GO
