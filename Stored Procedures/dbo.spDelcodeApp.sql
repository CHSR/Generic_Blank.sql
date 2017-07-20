SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelcodeApp](@codeAppPK int)

AS


DELETE 
FROM codeApp
WHERE codeAppPK = @codeAppPK
GO
