SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddAttachment](@FormDate datetime=NULL,
@FormFK int=NULL,
@FormType char(2)=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL,
@Attachment varbinary(max)=NULL,
@AttachmentCreateDate datetime=null,
@AttachmentCreator char(10)=NULL)
AS
INSERT INTO Attachment(
FormDate,
FormFK,
FormType,
HVCaseFK,
ProgramFK,
Attachment,
AttachmentCreateDate,
AttachmentCreator
)
VALUES(
@FormDate,
@FormFK,
@FormType,
@HVCaseFK,
@ProgramFK,
@Attachment,
@AttachmentCreateDate,
@AttachmentCreator
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
