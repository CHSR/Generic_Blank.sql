SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelPreintake](@PreintakePK int)

AS


DELETE 
FROM Preintake
WHERE PreintakePK = @PreintakePK
GO
