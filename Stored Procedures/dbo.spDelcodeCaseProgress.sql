SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelcodeCaseProgress](@codeCaseProgressPK int)

AS


DELETE 
FROM codeCaseProgress
WHERE codeCaseProgressPK = @codeCaseProgressPK
GO
