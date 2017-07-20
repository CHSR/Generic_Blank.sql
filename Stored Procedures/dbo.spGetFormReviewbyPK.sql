SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetFormReviewbyPK]

(@FormReviewPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM FormReview
WHERE FormReviewPK = @FormReviewPK
GO
