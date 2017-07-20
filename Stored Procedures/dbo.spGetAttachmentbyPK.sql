SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetAttachmentbyPK]

(@AttachmentPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM Attachment
WHERE AttachmentPK = @AttachmentPK

GO
