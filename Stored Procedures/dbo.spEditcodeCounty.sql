SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditcodeCounty](@codeCountyPK int=NULL,
@CountyCode char(2)=NULL,
@CountyName char(15)=NULL)
AS
UPDATE codeCounty
SET 
CountyCode = @CountyCode, 
CountyName = @CountyName
WHERE codeCountyPK = @codeCountyPK
GO
