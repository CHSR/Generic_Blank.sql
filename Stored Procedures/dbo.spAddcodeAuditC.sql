SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeAuditC](@codeGroup char(20)=NULL,
@codeScore int=NULL,
@codeText char(25)=NULL,
@codeValue char(2)=NULL)
AS
INSERT INTO codeAuditC(
codeGroup,
codeScore,
codeText,
codeValue
)
VALUES(
@codeGroup,
@codeScore,
@codeText,
@codeValue
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
