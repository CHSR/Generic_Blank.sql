SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeServiceReferral](@ServiceReferralCategory char(3)=NULL,
@ServiceReferralCode char(2)=NULL,
@ServiceReferralType char(45)=NULL)
AS
INSERT INTO codeServiceReferral(
ServiceReferralCategory,
ServiceReferralCode,
ServiceReferralType
)
VALUES(
@ServiceReferralCategory,
@ServiceReferralCode,
@ServiceReferralType
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
