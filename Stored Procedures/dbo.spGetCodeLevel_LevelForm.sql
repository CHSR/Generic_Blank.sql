SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 11, 2012>
-- Description:	<Get codeLevel values for Level Form from Case Home page>
--				<Copied originally from FamSys - see prior header below>
-- =============================================
-- =============================================
-- Author:    Chris Papas
-- Create date: <Create Date,,>
-- Description: <Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spGetCodeLevel_LevelForm] 
  -- Getting them all, don't need a parameter
AS
BEGIN
  -- SET NOCOUNT ON added to prevent extra result sets from
  -- interfering with SELECT statements.
  SET NOCOUNT ON;

    -- Insert statements for procedure here
  SELECT * FROM codelevel
  WHERE enrolled=1
  AND RIGHT(LTRIM(RTRIM(LevelName)), 4) <> 'term'
END
GO
