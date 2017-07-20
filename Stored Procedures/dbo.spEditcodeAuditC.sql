SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditcodeAuditC](@codeAuditCPK int=NULL,
@codeGroup char(20)=NULL,
@codeScore int=NULL,
@codeText char(25)=NULL,
@codeValue char(2)=NULL)
AS
UPDATE codeAuditC
SET 
codeGroup = @codeGroup, 
codeScore = @codeScore, 
codeText = @codeText, 
codeValue = @codeValue
WHERE codeAuditCPK = @codeAuditCPK
GO
