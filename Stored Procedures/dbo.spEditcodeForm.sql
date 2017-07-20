SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditcodeForm](@codeFormPK int=NULL,
@FormPKName varchar(20)=NULL,
@canBeReviewed bit=NULL,
@codeFormAbbreviation char(2)=NULL,
@codeFormName varchar(50)=NULL,
@FormDateName varchar(20)=NULL,
@MainTableName varchar(20)=NULL)
AS
UPDATE codeForm
SET 
FormPKName = @FormPKName, 
canBeReviewed = @canBeReviewed, 
codeFormAbbreviation = @codeFormAbbreviation, 
codeFormName = @codeFormName, 
FormDateName = @FormDateName, 
MainTableName = @MainTableName
WHERE codeFormPK = @codeFormPK
GO
