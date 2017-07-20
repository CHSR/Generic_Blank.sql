SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[spGetAllcodeServiceReferrals]
as
select *
from dbo.codeServiceReferral
order by ServiceReferralCode
GO
