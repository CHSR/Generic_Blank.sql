SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetTrainingbyPK]

(@TrainingPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM Training
WHERE TrainingPK = @TrainingPK
GO
