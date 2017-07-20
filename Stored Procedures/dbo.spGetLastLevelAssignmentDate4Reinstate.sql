SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <March. 17, 2014>
-- Description:	<Retrieves Last LevelAssignmentDate for a given case and programfk>

-- spGetLastLevelAssignmentDate4Reinstate 9, 55169
-- =============================================
CREATE PROCEDURE [dbo].[spGetLastLevelAssignmentDate4Reinstate]
	@ProgramFK as integer,
	@HVCaseFK as Integer

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  	;
  	with cteMain as
  	(
			SELECT max([LevelAssignDate]) as LastLevelAssignDate
				  ,[HVCaseFK]
				  ,[ProgramFK]
			  FROM [HVLevel] 
			where HVCaseFK = @HVCaseFK and ProgramFK = @ProgramFK
			group by [HVCaseFK],[ProgramFK]
	)
	
	SELECT 
		CONVERT(varchar, LastLevelAssignDate, 101) as LastLevelAssignDate 
	FROM cteMain
	
END


GO
