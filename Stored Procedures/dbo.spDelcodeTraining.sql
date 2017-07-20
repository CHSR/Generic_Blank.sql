SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelcodeTraining](@codeTrainingPK int)

AS


DELETE 
FROM codeTraining
WHERE codeTrainingPK = @codeTrainingPK
GO
