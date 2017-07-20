SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[spGetOtherChildByFormFK]
	@FormType AS CHAR(2),
	@FormFK INT

AS

SELECT *
FROM OtherChild
WHERE formfk = @FormFK
AND FormType = @FormType













GO
