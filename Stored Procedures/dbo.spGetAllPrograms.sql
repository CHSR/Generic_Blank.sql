SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jay Robohn
-- Create date: Jan. 06, 2011
-- Modified: 
-- Description:	Get all programs for reports
-- =============================================
CREATE PROCEDURE [dbo].[spGetAllPrograms]

AS
  SELECT * FROM dbo.HVProgram 
  ORDER BY HVProgramPK  -- programname
GO
