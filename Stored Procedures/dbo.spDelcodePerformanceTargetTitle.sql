SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelcodePerformanceTargetTitle](@codePerformanceTargetTitlePK int)

AS


DELETE 
FROM codePerformanceTargetTitle
WHERE codePerformanceTargetTitlePK = @codePerformanceTargetTitlePK
GO
