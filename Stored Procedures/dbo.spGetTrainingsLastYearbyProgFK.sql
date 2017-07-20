SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 7/11/2012
-- Description:	Gets Training List by program for the TrainingHome.aspx page
-- =============================================
CREATE PROCEDURE [dbo].[spGetTrainingsLastYearbyProgFK]
	-- Add the parameters for the stored procedure here
	@ProgFK AS int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT DISTINCT 
		  IsApproved
		  ,tr.[TrainingPK]
		  ,tr.[ProgramFK]
		  ,tr.[TrainerFK]
		  ,tr.[TrainingMethodFK]
		  ,tr.[TrainingCreateDate]
		  ,tr.[TrainingCreator]
		  ,tr.[TrainingDate]
		  ,tr.[TrainingDays]
		  ,tr.[TrainingDescription]
		  ,tr.[TrainingDuration]
		  ,tr.[TrainingEditDate]
		  ,tr.[TrainingEditor]
		  ,tr.[TrainingHours]
		  ,tr.[TrainingMinutes]
		  ,tr.[TrainingTitle]
	  FROM [dbo].[Training] tr
		INNER JOIN FormReviewedTableList('TR', @ProgFK)
		ON formfk = tr.TrainingPK
	  WHERE tr.ProgramFK = @ProgFK
	  AND tr.TrainingDate > dateadd(year,-1,getdate())
	 AND (tr.IsExempt IS Null OR tr.IsExempt = 0)
	  ORDER BY TrainingDate DESC
END
GO
