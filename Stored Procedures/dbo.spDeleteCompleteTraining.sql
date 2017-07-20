SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spDeleteCompleteTraining]
	-- Add the parameters for the stored procedure here
	@tpk AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  BEGIN TRY
		
		BEGIN TRANSACTION;

		DELETE FROM TrainingAttendee WHERE TrainingFK=@tpk
		
		DELETE FROM TrainingDetail WHERE TrainingFK=@tpk
		
		DELETE FROM Training WHERE TrainingPK=@tpk
		
		COMMIT TRANSACTION;
		
  END TRY
  
  BEGIN CATCH
   
    ROLLBACK TRANSACTION;
  
  END CATCH
  
 
END
GO
