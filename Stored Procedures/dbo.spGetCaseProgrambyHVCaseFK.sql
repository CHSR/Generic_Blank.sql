SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Dorothy Baum
-- Create date: Mar 28, 2009>
-- Description:	Select CaseProgram data by ProgramCode and HVCasePK
-- =============================================
CREATE PROCEDURE [dbo].[spGetCaseProgrambyHVCaseFK](@HVCaseFK int,@ProgramFK int)  
	-- Add the parameters for the stored procedure here
--	<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
--	<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT top 1 *
  FROM [dbo].[CaseProgram]
  WHERE [HVCaseFK]=@HVCaseFK and [ProgramFK]=@ProgramFK
  order by CaseProgramCreateDate desc
END



GO
