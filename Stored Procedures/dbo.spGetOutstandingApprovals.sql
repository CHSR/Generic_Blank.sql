SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetOutstandingApprovals]
	(
	@ProgramFK int,
	@FSWFK int = NULL
	)
AS
	SET NOCOUNT ON
	
	SELECT	FormReview.FormReviewPK, FormReview.FormType, FormReview.FormFK, FormReview.FormDate, FormReview.HVCaseFK, FormReview.ProgramFK, 
			FormReview.ReviewDateTime, FormReview.ReviewedBy, FormReview.FormReviewCreator, FormReview.FormReviewCreateDate, 
			FormReview.FormReviewEditor, FormReview.FormReviewEditDate
	FROM FormReview
	INNER JOIN CaseProgram
	ON FormReview.HVCaseFK = CaseProgram.HVCaseFK
	AND FormReview.ProgramFK = CaseProgram.ProgramFK
	INNER JOIN FormReviewOptions
	ON FormReviewOptions.programfk = FormReview.ProgramFK
	AND FormReviewOptions.FormType = FormReview.FormType
	WHERE FormReview.ProgramFK = @ProgramFK
	AND CurrentFSWFK = ISNULL(@FSWFK, CurrentFSWFK)
	AND CaseStartDate BETWEEN FormReviewStartDate AND FormReviewEndDate
	AND DischargeDate = NULL
	AND ReviewedBy = NULL 
	
GO
