SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetFatherFigurebyPK]

(@FatherFigurePK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM FatherFigure
WHERE FatherFigurePK = @FatherFigurePK
GO
