SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Nov. 12, 2011>
-- Description:	<Retrieves level rows for a given case>
-- =============================================
CREATE PROCEDURE [dbo].[spGetHVLevelbyHVCase]
	-- Add the parameters for the stored procedure here
	@HVCaseFK as Integer

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	SELECT HVLevelPK, HVCaseFK, LevelFK, CONVERT(varchar, LevelAssignDate, 101) as LevelAssignDate, 
	HVLevelCreateDate, HVLevelCreator, HVLevelEditDate, HVLevelEditor, ProgramFK, LevelName, PC1FK, 
	TCDOB, EDC, codeLevelPK, TCNumber, IntakeDate
	FROM HVLevel 
	LEFT JOIN HVCase ON HVCase.HVCasePK = HVLevel.HVCaseFK 
	LEFT JOIN codelevel ON codelevel.codelevelPK = HVLevel.LevelFK
	WHERE HVLevel.HVCaseFK = @HVCaseFK
	ORDER BY CONVERT(varchar, LevelAssignDate, 121) DESC
	
END

GO
