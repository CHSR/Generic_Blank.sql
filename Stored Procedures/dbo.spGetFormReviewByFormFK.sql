SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetFormReviewByFormFK]
	(
	@FormType varchar(2),
	@FormFK int,	
	@ProgramFK int
	)
AS
	SET NOCOUNT ON
	
	SELECT *
	FROM FormReview
	WHERE FormType = @FormType
	AND FormFK = @FormFK
	AND ProgramFK =  @ProgramFK
	
	RETURN
GO
