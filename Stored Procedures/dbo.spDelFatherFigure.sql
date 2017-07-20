SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelFatherFigure](@FatherFigurePK int)

AS


DELETE 
FROM FatherFigure
WHERE FatherFigurePK = @FatherFigurePK
GO
