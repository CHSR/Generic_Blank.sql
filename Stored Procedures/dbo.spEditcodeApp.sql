SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditcodeApp](@codeAppPK int=NULL,
@AppCode char(2)=NULL,
@AppCodeGroup char(32)=NULL,
@AppCodeText char(100)=NULL,
@AppCodeUsedWhere varchar(50)=NULL)
AS
UPDATE codeApp
SET 
AppCode = @AppCode, 
AppCodeGroup = @AppCodeGroup, 
AppCodeText = @AppCodeText, 
AppCodeUsedWhere = @AppCodeUsedWhere
WHERE codeAppPK = @codeAppPK
GO
