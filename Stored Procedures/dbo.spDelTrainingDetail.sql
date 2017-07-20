SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelTrainingDetail](@TrainingDetailPK int)

AS


DELETE 
FROM TrainingDetail
WHERE TrainingDetailPK = @TrainingDetailPK
GO
