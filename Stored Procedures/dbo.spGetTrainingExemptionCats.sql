SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 09/21/2012
-- Description:	Get the Training Exemption codes
-- =============================================
CREATE PROCEDURE [dbo].[spGetTrainingExemptionCats]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT DISTINCT rtrim([TrainingCode]) AS 'TrainingCode'
      ,[TrainingCodeDescription]
      ,[TrainingCodeGroup]
      ,[TrainingCodeUsedWhere]
  FROM [dbo].[codeTraining]
  WHERE TrainingCodeGroup='Exemption'
END
GO
