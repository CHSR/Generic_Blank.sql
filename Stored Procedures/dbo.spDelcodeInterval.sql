SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelcodeInterval](@codeIntervalPK int)

AS


DELETE 
FROM codeInterval
WHERE codeIntervalPK = @codeIntervalPK
GO
