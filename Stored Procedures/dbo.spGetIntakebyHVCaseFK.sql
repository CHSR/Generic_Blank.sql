SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 11, 2012>
-- Description:	<Get intake for Case Home page, removed programfk criteria - Copied originally from FamSys> 
-- =============================================
CREATE PROCEDURE  [dbo].[spGetIntakebyHVCaseFK](
  @HVCaseFK INT,
  @ProgramFK INT = NULL
)

AS
BEGIN
  SET NOCOUNT ON;

  SELECT *
  FROM Intake 
  WHERE HVCaseFK = @HVCaseFK
		-- AND ProgramFK = ISNULL(@ProgramFK, ProgramFK)
   
END
GO
