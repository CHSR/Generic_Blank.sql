SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelPSI](@PSIPK int)

AS


DELETE 
FROM PSI
WHERE PSIPK = @PSIPK
GO
