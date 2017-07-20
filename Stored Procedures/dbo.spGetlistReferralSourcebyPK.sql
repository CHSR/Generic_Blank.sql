SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetlistReferralSourcebyPK]

(@listReferralSourcePK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM listReferralSource
WHERE listReferralSourcePK = @listReferralSourcePK
GO
