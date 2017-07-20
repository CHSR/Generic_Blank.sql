SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelAttachment](@AttachmentPK int)

AS


DELETE 
FROM Attachment
WHERE AttachmentPK = @AttachmentPK

GO
