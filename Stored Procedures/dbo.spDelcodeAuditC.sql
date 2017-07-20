SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelcodeAuditC](@codeAuditCPK int)

AS


DELETE 
FROM codeAuditC
WHERE codeAuditCPK = @codeAuditCPK
GO
