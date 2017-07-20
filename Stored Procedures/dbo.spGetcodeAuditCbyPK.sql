SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetcodeAuditCbyPK]

(@codeAuditCPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM codeAuditC
WHERE codeAuditCPK = @codeAuditCPK
GO
