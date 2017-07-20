SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetcodeServiceReferralbyPK]

(@codeServiceReferralPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM codeServiceReferral
WHERE codeServiceReferralPK = @codeServiceReferralPK
GO
