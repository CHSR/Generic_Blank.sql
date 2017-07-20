SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE  [dbo].[spGetCaseProgrambyPC1ID](@PC1ID VARCHAR(23))

AS
BEGIN
	SET NOCOUNT ON;

    SELECT TOP 1 *
	FROM CaseProgram	
	WHERE PC1ID = @PC1ID
	ORDER BY CaseStartDate DESC
	 
END
GO