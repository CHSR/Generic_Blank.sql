SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelPreassessment](@PreassessmentPK int)

AS


DELETE 
FROM Preassessment
WHERE PreassessmentPK = @PreassessmentPK
GO
