SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelTrainer](@TrainerPK int)

AS


DELETE 
FROM Trainer
WHERE TrainerPK = @TrainerPK
GO
