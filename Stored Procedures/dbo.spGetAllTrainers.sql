SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Dar Chen
-- Create date: 4/21/2014
-- Description:	Get all Trainer by Program 
-- =============================================
CREATE procedure [dbo].[spGetAllTrainers] (@programfk int)

AS

	SELECT *
	FROM dbo.Trainer
	WHERE ProgramFK = ISNULL(@ProgramFK,ProgramFK)
	ORDER BY TrainerLastName, TrainerFirstName

GO
