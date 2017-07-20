SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelTraining](@TrainingPK int)

AS


DELETE 
FROM Training
WHERE TrainingPK = @TrainingPK
GO
