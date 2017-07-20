SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelSupervision](@SupervisionPK int)

AS


DELETE 
FROM Supervision
WHERE SupervisionPK = @SupervisionPK
GO
