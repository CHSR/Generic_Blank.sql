SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelFollowUp](@FollowUpPK int)

AS


DELETE 
FROM FollowUp
WHERE FollowUpPK = @FollowUpPK
GO
