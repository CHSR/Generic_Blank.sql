SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetPreassessmentbyPK]

(@PreassessmentPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM Preassessment
WHERE PreassessmentPK = @PreassessmentPK
GO
