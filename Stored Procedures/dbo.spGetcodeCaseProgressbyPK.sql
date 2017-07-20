SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetcodeCaseProgressbyPK]

(@codeCaseProgressPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM codeCaseProgress
WHERE codeCaseProgressPK = @codeCaseProgressPK
GO
