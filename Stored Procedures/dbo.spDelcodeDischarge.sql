SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelcodeDischarge](@codeDischargePK int)

AS


DELETE 
FROM codeDischarge
WHERE codeDischargePK = @codeDischargePK
GO
