SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetTrainingDetailbyPK]

(@TrainingDetailPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM TrainingDetail
WHERE TrainingDetailPK = @TrainingDetailPK
GO
