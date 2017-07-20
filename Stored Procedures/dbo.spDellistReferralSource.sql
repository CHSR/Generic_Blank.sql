SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDellistReferralSource](@listReferralSourcePK int)

AS


DELETE 
FROM listReferralSource
WHERE listReferralSourcePK = @listReferralSourcePK
GO
