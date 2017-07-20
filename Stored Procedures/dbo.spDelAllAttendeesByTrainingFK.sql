SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 7/18/2012
-- Description:	Delete
-- =============================================
CREATE PROCEDURE [dbo].[spDelAllAttendeesByTrainingFK]
	-- Add the parameters for the stored procedure here
	@TrainingFK AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DELETE FROM TrainingAttendee WHERE TrainingFK=@TrainingFK
END
GO
