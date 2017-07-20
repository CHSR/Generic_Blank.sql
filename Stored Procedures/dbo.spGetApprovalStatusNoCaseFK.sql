SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[spGetApprovalStatusNoCaseFK]
	(
	@FormType varchar(2),
	@FormFK int,
	@ProgramFK int,
	@isApproved bit OUTPUT
	)

AS
	SET NOCOUNT ON
	
	SELECT @isApproved = CASE WHEN ReviewedBy IS NOT NULL THEN 1 ELSE 0 END
	FROM FormReview
	INNER JOIN FormReviewOptions
	ON FormReviewOptions.programfk = FormReview.ProgramFK
	AND FormReviewOptions.FormType = FormReview.FormType 
	WHERE FormReview.FormType = @FormType
	AND FormFK = @FormFK
	AND FormReview.ProgramFK = @ProgramFK

	SET @isApproved = ISNULL(@isApproved, 0)
		
	RETURN


GO
