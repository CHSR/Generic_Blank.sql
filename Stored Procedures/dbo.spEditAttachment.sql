SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditAttachment](@AttachmentPK int=NULL,
@FormDate datetime=NULL,
@FormFK int=NULL,
@FormType char(2)=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL,
@Attachment varbinary(max)=null,
@AttachmentCreateDate datetime=null,
@AttachmentCreator char(10)=null)
AS
UPDATE Attachment
SET 
FormDate = @FormDate, 
FormFK = @FormFK, 
FormType = @FormType, 
HVCaseFK = @HVCaseFK, 
ProgramFK = @ProgramFK, 
Attachment = @Attachment,
AttachmentCreateDate = @AttachmentCreateDate,
AttachmentCreator = @AttachmentCreator
WHERE AttachmentPK = @AttachmentPK
GO
