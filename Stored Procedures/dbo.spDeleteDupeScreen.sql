SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Chris Papas
-- Create date: 10/15/2010
-- Description:	DELETES a Duplicate Screen
-- =============================================
create PROCEDURE [dbo].[spDeleteDupeScreen]
	-- Add the parameters for the stored procedure here
	@HVCase as int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE FROM HVScreen WHERE HVCaseFK=@HVCase 
    DELETE FROM CaseProgram WHERE HVCaseFK=@HVCase
	DELETE FROM CommonAttributes WHERE HVCaseFK=@HVCase
	DELETE FROM HVCase WHERE HVCasePK=@HVCase

	
END

GO
