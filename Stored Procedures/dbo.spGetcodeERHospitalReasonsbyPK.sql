SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetcodeERHospitalReasonsbyPK]

(@codeERHospitalReasonsPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM codeERHospitalReasons
WHERE codeERHospitalReasonsPK = @codeERHospitalReasonsPK
GO
