SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetcodeFormbyPK]

(@codeFormPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM codeForm
WHERE codeFormPK = @codeFormPK
GO
