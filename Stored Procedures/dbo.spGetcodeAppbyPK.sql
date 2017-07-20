SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetcodeAppbyPK]

(@codeAppPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM codeApp
WHERE codeAppPK = @codeAppPK
GO
