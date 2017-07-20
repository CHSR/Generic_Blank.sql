SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelcodeMedicalItem](@codeMedicalItemPK int)

AS


DELETE 
FROM codeMedicalItem
WHERE codeMedicalItemPK = @codeMedicalItemPK
GO
