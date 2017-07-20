SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetEducationbyPK]

(@EducationPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM Education
WHERE EducationPK = @EducationPK
GO
