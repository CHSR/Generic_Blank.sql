SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[spGetCaseProgramfksByPC1ID](@PC1ID VARCHAR(23))

AS

SET NOCOUNT ON;

WITH results(caseprogrampk,programfk)
AS
(
	SELECT caseprogrampk, programfk
	FROM caseprogram
	WHERE pc1id = @pc1id
)
SELECT SUBSTRING((SELECT ', ' + LTRIM(RTRIM(STR(programfk))) FROM results FOR XML PATH ( '' ) ), 3, 1000)



GO
