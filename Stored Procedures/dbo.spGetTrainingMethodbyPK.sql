SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetTrainingMethodbyPK]

(@TrainingMethodPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM TrainingMethod
WHERE TrainingMethodPK = @TrainingMethodPK
GO
