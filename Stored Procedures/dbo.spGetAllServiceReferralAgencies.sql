SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[spGetAllServiceReferralAgencies]
as
select *
from dbo.listServiceReferralAgency
order by AgencyName
GO
