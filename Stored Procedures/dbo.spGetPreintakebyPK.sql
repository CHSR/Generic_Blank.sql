SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetPreintakebyPK]

(@PreintakePK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM Preintake
WHERE PreintakePK = @PreintakePK
GO
