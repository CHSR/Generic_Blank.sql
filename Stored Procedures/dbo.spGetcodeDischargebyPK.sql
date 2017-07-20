SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetcodeDischargebyPK]

(@codeDischargePK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM codeDischarge
WHERE codeDischargePK = @codeDischargePK
GO
