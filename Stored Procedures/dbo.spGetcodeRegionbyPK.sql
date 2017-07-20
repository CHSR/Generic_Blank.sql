SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetcodeRegionbyPK]

(@codeRegionPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM codeRegion
WHERE codeRegionPK = @codeRegionPK
GO
