SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: June 5, 2012
-- Description:	Get all the trainers by Program
-- =============================================
CREATE PROCEDURE [dbo].[spGetTrainerbyProgFK]
	-- Add the parameters for the stored procedure here
	@ProgFK AS INT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT [TrainerPK]
      ,[ProgramFK]
      ,[TrainerCreateDate]
      ,[TrainerCreator]
      ,[TrainerEditDate]
      ,[TrainerEditor]
      ,[TrainerFirstName]
      ,[TrainerLastName]
      ,[TrainerOrganization]
      ,[TrainerPK_old]
    FROM	Trainer t WHERE ProgramFK=@ProgFK
    ORDER BY TrainerFirstName
    
END
GO
