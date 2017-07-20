SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[spGetFormReviewEndDate]
	(
	@ProgramFK int,
	@FormType varchar(2),
	@FormReviewEndDate datetime OUTPUT
	)
AS
	SET NOCOUNT ON
	
	SELECT TOP 1 @FormReviewEndDate = ISNULL(FormReviewEndDate, GETDATE())
	FROM FormReviewOptions
	WHERE FormType = @FormType
	AND ProgramFK = @ProgramFK
	RETURN

GO
