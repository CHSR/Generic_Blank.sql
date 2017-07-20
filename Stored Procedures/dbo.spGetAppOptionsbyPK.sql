SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetAppOptionsbyPK]

(@AppOptionsPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM AppOptions
WHERE AppOptionsPK = @AppOptionsPK
GO
