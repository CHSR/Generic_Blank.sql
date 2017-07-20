SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeApp](@AppCode char(2)=NULL,
@AppCodeGroup char(32)=NULL,
@AppCodeText char(100)=NULL,
@AppCodeUsedWhere varchar(50)=NULL)
AS
INSERT INTO codeApp(
AppCode,
AppCodeGroup,
AppCodeText,
AppCodeUsedWhere
)
VALUES(
@AppCode,
@AppCodeGroup,
@AppCodeText,
@AppCodeUsedWhere
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
