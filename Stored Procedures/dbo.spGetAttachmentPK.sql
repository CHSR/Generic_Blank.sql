SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[spGetAttachmentPK]
	(
	@FormType varchar(2),
	@FormFK int,
	@HVCaseFK int,
	@ProgramFK int,
	@AttachmentPK int OUTPUT
	)

AS
	SET NOCOUNT ON
	BEGIN 
	
		BEGIN TRANSACTION
		SET TRANSACTION ISOLATION LEVEL Read uncommitted;
		
		SELECT @AttachmentPK = AttachmentPK
		FROM dbo.Attachment
		WHERE FormType = @FormType
		AND FormFK = @FormFK
		--AND HVCaseFK = @HVCaseFK
		--AND FormReview.ProgramFK = @ProgramFK

		SET @AttachmentPK = ISNULL(@AttachmentPK, 0)
		
		COMMIT TRANSACTION
	
	 END 
	
	RETURN


GO
