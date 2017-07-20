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
-- Description: <copied from FamSys Feb 20, 20112 - see header below>
-- =============================================
create procedure [dbo].[rspServiceReferrals2]
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

	select ServiceCode = case servicereferralcategory
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
						 end
		  ,sum(count(referraldate)) over () as 'GrandTotal1'
		  ,count(referraldate) as Totals
		  ,count(case
					 when servicereceived = 1 then
						 servicereceived
				 end) as 'Started Service'
		  ,count(case
					 when servicereceived is null then
						 1
				 end) as 'Pending Service'
		  ,count(case
					 when servicereceived = 0 then
						 servicereceived
				 end) as 'Did Not Receive'
		from servicereferral
			left join codeServiceReferral on codeServiceReferral.ServiceReferralCode = ServiceReferral.ServiceCode
			inner join dbo.SplitString(@programfk,',') on servicereferral.programfk = listitem
		where ReferralDate between @StartDt and @EndDt
			 and natureofreferral = '02'
		group by servicereferralcategory
				,natureofreferral
		order by servicereferralcategory

end
GO
