SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetServiceReferralbyPK]

(@ServiceReferralPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM ServiceReferral
WHERE ServiceReferralPK = @ServiceReferralPK
GO
