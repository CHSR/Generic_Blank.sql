SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Nov. 12, 2011>
-- Description:	<Used to get the initial record written into the HVLevel table from the ID Contact form>
-- =============================================
CREATE PROCEDURE [dbo].[spGetHVLevelFirstbyHVCase]
	-- Add the parameters for the stored procedure here
	@HVCaseFK as Integer

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	SELECT top 1 HVLevelPK, HVCaseFK, LevelFK, CONVERT(varchar, LevelAssignDate, 101) as LevelAssignDate, 
	HVLevelCreateDate, HVLevelCreator, HVLevelEditDate, HVLevelEditor, ProgramFK, LevelName, PC1FK, 
	TCDOB, EDC, codeLevelPK, TCNumber, IntakeDate
	FROM HVLevel 
	LEFT JOIN HVCase ON HVCase.HVCasePK = HVLevel.HVCaseFK 
	LEFT JOIN codelevel ON codelevel.codelevelPK = HVLevel.LevelFK
	WHERE HVLevel.HVCaseFK = @HVCaseFK
	ORDER BY CONVERT(varchar, LevelAssignDate, 121) ASC
	
END

GO
