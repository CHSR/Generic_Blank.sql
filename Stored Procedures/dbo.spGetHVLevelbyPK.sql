SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetHVLevelbyPK]

(@HVLevelPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM HVLevel
WHERE HVLevelPK = @HVLevelPK
GO