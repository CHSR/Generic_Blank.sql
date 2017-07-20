SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetcodeLevelbyPK]

(@codeLevelPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM codeLevel
WHERE codeLevelPK = @codeLevelPK
GO
