SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelCommonAttributes](@CommonAttributesPK int)

AS


DELETE 
FROM CommonAttributes
WHERE CommonAttributesPK = @CommonAttributesPK
GO
