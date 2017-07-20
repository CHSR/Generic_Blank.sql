SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetCommonAttributesbyPCFK]
	@PCFK [int],
	@FormFK [int],
	@FormType [char](8)
AS

SET NOCOUNT ON;

SELECT * 
FROM CommonAttributes
WHERE FormFK = @FormFK
AND FormType = @FormType
AND PCFK = @PCFK
GO
