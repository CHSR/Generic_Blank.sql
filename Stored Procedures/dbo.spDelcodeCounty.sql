SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelcodeCounty](@codeCountyPK int)

AS


DELETE 
FROM codeCounty
WHERE codeCountyPK = @codeCountyPK
GO
