SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelServiceReferral](@ServiceReferralPK int)

AS


DELETE 
FROM ServiceReferral
WHERE ServiceReferralPK = @ServiceReferralPK
GO
