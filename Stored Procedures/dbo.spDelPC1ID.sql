SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelPC1ID](@PC1IDPK int)

AS


DELETE 
FROM PC1ID
WHERE PC1IDPK = @PC1IDPK
GO