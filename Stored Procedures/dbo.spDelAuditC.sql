SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelAuditC](@AuditCPK int)

AS


DELETE 
FROM AuditC
WHERE AuditCPK = @AuditCPK
GO
