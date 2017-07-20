SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelcodeRegion](@codeRegionPK int)

AS


DELETE 
FROM codeRegion
WHERE codeRegionPK = @codeRegionPK
GO
