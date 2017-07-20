SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetOtherChildbyPK]

(@OtherChildPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM OtherChild
WHERE OtherChildPK = @OtherChildPK
GO
