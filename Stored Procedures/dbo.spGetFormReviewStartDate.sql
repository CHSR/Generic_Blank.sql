SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[spGetFormReviewStartDate]
	(
	@ProgramFK int,
	@FormType varchar(2),
	@FormReviewStartDate datetime OUTPUT
	)
AS
	SET NOCOUNT ON
	
	SELECT TOP 1 @FormReviewStartDate = FormReviewStartDate
	FROM FormReviewOptions
	WHERE FormType = @FormType
	AND ProgramFK = @ProgramFK
	RETURN

GO
