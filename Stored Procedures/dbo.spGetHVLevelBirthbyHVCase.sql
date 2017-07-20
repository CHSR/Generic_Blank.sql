SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 11, 2012>
-- Description:	<Copied originally from FamSys - see prior header below>
-- =============================================
-- =============================================
-- Author:    <Dorothy Baum>
-- Create date: <Aug 30, 2010>
-- Description: <Used to get the matching record written in the HVLevel table to the TCDOB only
-- written in if case is prenatal at intake. >
-- =============================================
CREATE PROCEDURE [dbo].[spGetHVLevelBirthbyHVCase]
  -- Add the parameters for the stored procedure here
  @HVCaseFK as Integer, @TCDOB as DateTime

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
  WHERE HVLevel.HVCaseFK = @HVCaseFK and HVLevel.LevelAssignDate=@TCDOB
  ORDER BY CONVERT(varchar, LevelAssignDate, 121) ASC
  
END


GO
