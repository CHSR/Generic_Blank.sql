SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- For testing:
--declare @p5 bit  set @p5=0  exec spGetApprovalStatus @FormType=N'SR',@FormFK=235143,@HVCaseFK=203568,@Programfk=22,@isApproved=@p5 output  select @p5

CREATE PROCEDURE [dbo].[spGetApprovalStatus]
	(
	@FormType varchar(2),
	@FormFK int,
	@HVCaseFK int,
	@ProgramFK int,
	@isApproved bit OUTPUT
	)

AS
	SET NOCOUNT ON
	-- Escape route at the top. Don't go in if not needed  ... Khalsa
	IF (@FormType IS NULL OR @FormType = '' OR @FormType NOT IN (SELECT FormType FROM FormReviewOptions WHERE ProgramFK = @ProgramFK AND FormType = @FormType ) ) 
	BEGIN
		SET @isApproved = 0 		
	END 	
	ELSE
	BEGIN 
	
		BEGIN TRANSACTION
		SET TRANSACTION ISOLATION LEVEL Read uncommitted;
		
		SELECT @isApproved = CASE WHEN ReviewedBy IS NOT NULL THEN 1 ELSE 0 END
		FROM FormReview
		INNER JOIN FormReviewOptions
		ON FormReviewOptions.programfk = FormReview.ProgramFK
		AND FormReviewOptions.FormType = FormReview.FormType 
		WHERE FormReview.FormType = @FormType
		AND FormFK = @FormFK
		AND HVCaseFK = @HVCaseFK
		AND FormReview.ProgramFK = @ProgramFK

		SET @isApproved = ISNULL(@isApproved, 0)
		
		COMMIT TRANSACTION
	
	 END 
	
	RETURN

GO
