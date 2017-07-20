SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetlistServiceReferralAgencybyPK]

(@listServiceReferralAgencyPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM listServiceReferralAgency
WHERE listServiceReferralAgencyPK = @listServiceReferralAgencyPK
GO
