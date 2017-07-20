SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 07/30/2010
-- Description:	Merges the ReferralSourceFK's from the Duplicate form
-- =============================================
CREATE PROCEDURE [dbo].[spEditScreenReferralSourceFK]
	-- Add the parameters for the stored procedure here
	@oldReferralFK as integer,
	@newReferralFK as integer
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Update HVScreen 
	SET ReferralSourceFK=@newReferralFK 
	WHERE ReferralSourceFK=@oldReferralFK

END
GO
