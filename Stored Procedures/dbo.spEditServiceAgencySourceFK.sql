SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 08/19/2010
-- Description:	Change ProvidingAgencyFK when using Duplicate Remover page
-- =============================================
CREATE PROCEDURE [dbo].[spEditServiceAgencySourceFK]
	-- Add the parameters for the stored procedure here
	@oldReferralFK as integer,
	@newReferralFK as integer
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Update ServiceReferral 
	SET ProvidingAgencyFK=@newReferralFK 
	WHERE ProvidingAgencyFK=@oldReferralFK

END
GO
