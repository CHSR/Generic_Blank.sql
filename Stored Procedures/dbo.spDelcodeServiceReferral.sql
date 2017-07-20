SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelcodeServiceReferral](@codeServiceReferralPK int)

AS


DELETE 
FROM codeServiceReferral
WHERE codeServiceReferralPK = @codeServiceReferralPK
GO
