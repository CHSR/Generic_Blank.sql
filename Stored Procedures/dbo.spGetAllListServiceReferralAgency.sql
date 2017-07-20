SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Ray Burkitt
-- Create date: July 20, 2010
-- Description:	Get all Sites
-- =============================================
CREATE PROCEDURE [dbo].[spGetAllListServiceReferralAgency] (@programfk int)
	-- Add the parameters for the stored procedure here
AS
	SELECT * FROM  dbo.listServiceReferralAgency
	WHERE programfk = ISNULL(@ProgramFK,ProgramFK)
	ORDER BY AgencyName


GO
