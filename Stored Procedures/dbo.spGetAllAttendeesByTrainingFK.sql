SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 7/18/2012
-- Edit date: 12/15/2012
-- Edited by: Chris Papas
-- Edit Reason: Added distinct because some converted data was bringing in multiple workers for same training
-- Description:	Get all workers who participated in a specific training
-- =============================================
CREATE PROCEDURE [dbo].[spGetAllAttendeesByTrainingFK]
	-- Add the parameters for the stored procedure here
	@TrainingFK AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @listStr VARCHAR(MAX)
	SELECT @listStr = COALESCE(@listStr+',' ,'') + CAST([WorkerFK] AS VARCHAR(MAX))
	FROM (
		SELECT DISTINCT workerfk FROM [dbo].[TrainingAttendee] WHERE TrainingFK=@TrainingFK) a
	SELECT @listStr

END
GO
