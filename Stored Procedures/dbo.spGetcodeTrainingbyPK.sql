SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetcodeTrainingbyPK]

(@codeTrainingPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM codeTraining
WHERE codeTrainingPK = @codeTrainingPK
GO
