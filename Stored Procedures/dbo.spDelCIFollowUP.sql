SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelCIFollowUP](@CIFollowUPPK int)

AS


DELETE 
FROM CIFollowUP
WHERE CIFollowUPPK = @CIFollowUPPK
GO
