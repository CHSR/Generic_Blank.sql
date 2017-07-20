SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spGetMethodsbyProgFK]
	-- Add the parameters for the stored procedure here
	@ProgFK AS INT,
	@TrainingCode AS VARCHAR(2)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT [TrainingMethodPK]
      ,[TrainingCode]
      ,[MethodName]
      ,[ProgramFK]
    FROM	[TrainingMethod] t WHERE ProgramFK=@ProgFK AND TrainingCode=@TrainingCode
    
END
GO
