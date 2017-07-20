SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDellistServiceReferralAgency](@listServiceReferralAgencyPK int)

AS


DELETE 
FROM listServiceReferralAgency
WHERE listServiceReferralAgencyPK = @listServiceReferralAgencyPK
GO
