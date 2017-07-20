SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetOutstandingApprovalsByCase]
	(
	@ProgramFK int,
	@HVCaseFK int = NULL
	)
AS
	SET NOCOUNT ON
	
	SELECT	FormReview.FormReviewPK, FormReview.FormType, FormReview.FormFK, FormReview.FormDate, FormReview.HVCaseFK, FormReview.ProgramFK, 
			FormReview.ReviewDateTime, FormReview.ReviewedBy, FormReview.FormReviewCreator, FormReview.FormReviewCreateDate, 
			FormReview.FormReviewEditor, FormReview.FormReviewEditDate, codeFormname
	FROM FormReview
	INNER JOIN CaseProgram
	ON FormReview.HVCaseFK = CaseProgram.HVCaseFK
	AND FormReview.ProgramFK = CaseProgram.ProgramFK
	INNER JOIN FormReviewOptions
	ON FormReviewOptions.programfk = FormReview.ProgramFK
	AND FormReviewOptions.FormType = FormReview.FormType
	INNER JOIN codeForm 
	ON FormReview.FormType=codeForm.codeFormAbbreviation
	WHERE FormReview.ProgramFK = @ProgramFK
	AND FormReview.HVCaseFK = ISNULL(@HVCaseFK, FormReview.HVCaseFK)
	AND FormDate BETWEEN FormReviewStartDate AND ISNULL(FormReviewEndDate,FormDate)
	AND ReviewedBy IS NULL 
	
GO
