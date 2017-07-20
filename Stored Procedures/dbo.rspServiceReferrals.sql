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
-- Description: <copied from FamSys Feb 20,2012 - see header below>
-- =============================================
create procedure [dbo].[rspServiceReferrals]
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

	select distinct ServiceCode = case codeServiceReferral.servicereferralcategory
									  when 'HC' then
										  'Health Care'
									  when 'NUT' then
										  'Nutrition'
									  when 'DSS' then
										  'Public Benefits'
									  when 'FSS' then
										  'Family & Social Support Services'
									  when 'ETE' then
										  'Employment, Training & Education'
									  when 'CSS' then
										  'Counseling & Intensive Support Services'
									  when 'CON' then
										  'Concrete Services'
									  when 'OTH' then
										  'Other Services'
									  else
										  'no match'
								  end
				   ,isnull(GrandTotal1,0) as GrandTotal1
				   ,isnull(Totals,0) as Totals
				   ,isnull(StartedService,0) as 'Started Service'
				   ,isnull(PendingService,0) as 'Pending Service'
				   ,isnull(DidNotReceive,0) as 'Did Not Receive'
		from codeServiceReferral
			left join (select servicereferralcategory
							 ,sum(count(referraldate)) over () as 'GrandTotal1'
							 ,count(referraldate) as Totals
							 ,count(case
										when servicereceived = 1 then
											servicereceived
									end) as StartedService
							 ,count(case
										when servicereceived is null or servicereceived = '' then
											1
									end) as PendingService
							 ,count(case
										when servicereceived = 0 and not servicereceived = '' then
											servicereceived
									end) as DidNotReceive
						   from servicereferral
							   left join codeServiceReferral on codeServiceReferral.ServiceReferralCode = ServiceReferral.ServiceCode
							   inner join dbo.SplitString(@programfk,',') on servicereferral.programfk = listitem
						   where ReferralDate between @StartDt and @EndDt
								and natureofreferral = '01'
						   group by servicereferralcategory) a on a.servicereferralcategory = codeServiceReferral.servicereferralcategory

end
GO
