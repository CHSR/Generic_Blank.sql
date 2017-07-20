SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelcodeLevel](@codeLevelPK int)

AS


DELETE 
FROM codeLevel
WHERE codeLevelPK = @codeLevelPK
GO
