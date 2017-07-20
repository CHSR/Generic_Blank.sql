SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 4/21/2014
-- Description:	Merges the TrainerFK's from the Duplicate form
-- =============================================
CREATE PROCEDURE [dbo].[spEditTrainingTrainerFK]
	-- Add the parameters for the stored procedure here
	@oldTrainerFK as integer,
	@newTrainerFK as integer
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Update Training 
	SET TrainerFK=@newTrainerFK 
	WHERE TrainerFK=@oldTrainerFK

END

GO
