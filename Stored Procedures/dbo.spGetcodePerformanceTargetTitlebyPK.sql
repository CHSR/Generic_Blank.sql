SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetcodePerformanceTargetTitlebyPK]

(@codePerformanceTargetTitlePK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM codePerformanceTargetTitle
WHERE codePerformanceTargetTitlePK = @codePerformanceTargetTitlePK
GO
