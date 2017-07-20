SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelOtherChild](@OtherChildPK int)

AS


DELETE 
FROM OtherChild
WHERE OtherChildPK = @OtherChildPK
GO
