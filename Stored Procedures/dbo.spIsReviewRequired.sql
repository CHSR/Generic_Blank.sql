SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[spIsReviewRequired]
	(
	@ProgramFK int,
	@FormType varchar(2),
	@CaseStartDate datetime,
	@isReviewRequired bit OUTPUT
	)
AS
	SET NOCOUNT ON
	
	SELECT @isReviewRequired = CASE WHEN FormReviewOptionsPk > 0 THEN 1 ELSE 0 END
	FROM FormReviewOptions
	WHERE FormType = @FormType
	AND ProgramFK = @ProgramFK
	AND @CaseStartDate BETWEEN FormReviewStartDate AND ISNULL(FormReviewEndDate,@CaseStartDate)
	
	SET @isReviewRequired = ISNULL(@isReviewRequired, 0)

	RETURN

GO
