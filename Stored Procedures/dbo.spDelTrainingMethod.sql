SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelTrainingMethod](@TrainingMethodPK int)

AS


DELETE 
FROM TrainingMethod
WHERE TrainingMethodPK = @TrainingMethodPK
GO
