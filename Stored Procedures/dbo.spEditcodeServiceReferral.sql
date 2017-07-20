SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditcodeServiceReferral](@codeServiceReferralPK int=NULL,
@ServiceReferralCategory char(3)=NULL,
@ServiceReferralCode char(2)=NULL,
@ServiceReferralType char(45)=NULL)
AS
UPDATE codeServiceReferral
SET 
ServiceReferralCategory = @ServiceReferralCategory, 
ServiceReferralCode = @ServiceReferralCode, 
ServiceReferralType = @ServiceReferralType
WHERE codeServiceReferralPK = @codeServiceReferralPK
GO
