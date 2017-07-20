SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 09/09/2010
-- Description:	Service Referrals
-- =============================================
-- Author:    <Jay Robohn>
-- Description: <copied from FamSys Feb 20, 2012 - see header below>
-- =============================================
create procedure [dbo].[rspServiceReferrals_detail_2]
(
    @programfk varchar(max)    = null,
    @StartDt   datetime,
    @EndDt     datetime
)
as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

	-- Insert statements for procedure here
	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

	select count(reasonnoservice) as counter
		  ,appcodetext
		  ,sum(count(reasonnoservice)) over () as 'Total'
		from servicereferral
			left join codeApp on codeApp.appcode = servicereferral.reasonnoservice
			left join codeServiceReferral on codeServiceReferral.ServiceReferralCode = ServiceReferral.ServiceCode
			inner join dbo.SplitString(@programfk,',') on servicereferral.programfk = listitem
		where ReferralDate between @StartDt and @EndDt
			 and natureofreferral = '02'
			 and servicereceived = '0'
			 and appcodegroup = 'ReasonCode'
			 and appcodeusedwhere = 'SR'
		group by appcodetext

end
GO
