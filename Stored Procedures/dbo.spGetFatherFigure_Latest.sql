SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 01/12/2012
-- Description:	Gets the most recent Father Figure accept date that is not inactive for case 
-- =============================================
CREATE PROCEDURE [dbo].[spGetFatherFigure_Latest]
	-- Add the parameters for the stored procedure here
	@HVCaseFK AS INT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT max(DateAcceptService) FROM FatherFigure ff
	WHERE HVCaseFK=@HVCaseFK
	AND DateInactive IS NULL
END
GO
