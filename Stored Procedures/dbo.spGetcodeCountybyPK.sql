SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetcodeCountybyPK]

(@codeCountyPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM codeCounty
WHERE codeCountyPK = @codeCountyPK
GO
