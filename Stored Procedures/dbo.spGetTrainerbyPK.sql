SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetTrainerbyPK]

(@TrainerPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM Trainer
WHERE TrainerPK = @TrainerPK
GO
