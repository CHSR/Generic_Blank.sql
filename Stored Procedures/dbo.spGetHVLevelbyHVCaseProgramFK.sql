SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Chris Papas>
-- Create date: <Oct 24, 2013>
-- Description:	<Retrieves level rows for a given case, by programFK only>
-- =============================================
CREATE PROCEDURE [dbo].[spGetHVLevelbyHVCaseProgramFK]
	-- Add the parameters for the stored procedure here
	@HVCaseFK as Integer
	, @ProgramFK AS Integer
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
	WHERE HVLevel.HVCaseFK = @HVCaseFK AND hvlevel.ProgramFK = @ProgramFK
	ORDER BY CONVERT(varchar, LevelAssignDate, 121) DESC
	
END

GO
