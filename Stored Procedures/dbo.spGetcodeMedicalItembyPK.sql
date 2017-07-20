SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetcodeMedicalItembyPK]

(@codeMedicalItemPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM codeMedicalItem
WHERE codeMedicalItemPK = @codeMedicalItemPK
GO
