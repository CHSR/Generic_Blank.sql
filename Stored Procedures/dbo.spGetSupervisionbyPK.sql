SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetSupervisionbyPK]

(@SupervisionPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM Supervision
WHERE SupervisionPK = @SupervisionPK
GO
