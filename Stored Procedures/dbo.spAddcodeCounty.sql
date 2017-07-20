SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeCounty](@CountyCode char(2)=NULL,
@CountyName char(15)=NULL)
AS
INSERT INTO codeCounty(
CountyCode,
CountyName
)
VALUES(
@CountyCode,
@CountyName
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
