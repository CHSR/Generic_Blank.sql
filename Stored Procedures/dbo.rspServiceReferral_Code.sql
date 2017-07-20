SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 09/09/2010
-- Description:	Service Referrals
-- =============================================
create procedure [dbo].[rspServiceReferral_Code]
(
    @programfk varchar(max)    = null,
    @StartDt   datetime,
    @EndDt     datetime,
    @FSW       int             = null,
    @Super     int,
    @PC1ID     varchar(15)
)
as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

	select distinct ServiceReferralCategory = case codeServiceReferral.servicereferralcategory
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
				   ,a.servicereferraltype
				   ,servicecode
				   ,isnull(GrandTotal1,0) as GrandTotal1
				   ,isnull(Totals,0) as Totals
		from codeServiceReferral
			inner join (select rtrim(servicereferralcategory) as servicereferralcategory
							  ,servicecode
							  ,sum(count(referraldate)) over () as 'GrandTotal1'
							  ,count(referraldate) as Totals
							  ,servicereferraltype
							from servicereferral
								left join codeServiceReferral on codeServiceReferral.ServiceReferralCode = ServiceReferral.ServiceCode
								inner join dbo.SplitString(@programfk,',') on servicereferral.programfk = listitem
							where ReferralDate between @StartDt and @EndDt
								 and servicereceived = '1'
								 and FSWFK = case
												 when @FSW > 0 then
													 @FSW
												 when @SUPER > 0 then
													 @SUPER
												 else
													 FSWFK
											 end
								 and HVCASEFK = case
													when @PC1ID > 0 then
														@PC1ID
													else
														HVCASEFK
												end
							group by servicereferralcategory
									,servicecode
									,servicereferraltype) a on a.servicereferralcategory = codeServiceReferral.servicereferralcategory

end
GO
