SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetcodeIntervalbyPK]

(@codeIntervalPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM codeInterval
WHERE codeIntervalPK = @codeIntervalPK
GO
