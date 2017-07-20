SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetCommonAttributesbyPK]

(@CommonAttributesPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM CommonAttributes
WHERE CommonAttributesPK = @CommonAttributesPK
GO
