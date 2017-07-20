SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelFormReviewOptions](@FormReviewOptionsPK int)

AS


DELETE 
FROM FormReviewOptions
WHERE FormReviewOptionsPK = @FormReviewOptionsPK
GO
