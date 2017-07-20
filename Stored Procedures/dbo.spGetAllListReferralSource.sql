SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Ray Burkitt
-- Create date: July 20, 2010
-- Description:	Get all Referral Sources
-- mod jr (check the commit date yo) add IsMICHC
-- =============================================
CREATE procedure [dbo].[spGetAllListReferralSource]
(
    @ProgramFK int
)
-- Add the parameters for the stored procedure here
as
	select listReferralSourcePK
		  ,ProgramFK
		  ,ReferralSourceName
		  ,RSIsActive
		  ,listReferralSourcePK_old
		  ,IsMICHC
		from dbo.listReferralSource rs
		where programfk = isnull(@ProgramFK,ProgramFK)
		order by ReferralSourceName
GO
