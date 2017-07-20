SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <June 28, 2012>
-- Description:	<gets you data for quarterly service referrals>
-- exec [rspQSRReasonsServiceNotReceived] 19,'07/01/2012','09/30/2012','01',null,null
-- =============================================
CREATE procedure [dbo].[rspQSRReasonsServiceNotReceived]
(
    @programfk           varchar(max)    = null,
    @sdate               datetime,
    @edate               datetime,
    @NatureOfReferral    char(2),
    @sitefk              int             = null,
    @casefilterspositive varchar(200)
)

as
begin

	-- Insert statements for procedure here
	if @ProgramFK is null
	begin
		select @ProgramFK =
			   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	end

	set @ProgramFK = REPLACE(@ProgramFK,'"','')
	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end
	set @casefilterspositive = case when @casefilterspositive = '' then null else @casefilterspositive end

	declare @countServiceNotReceived int

	declare @tblResults table(
		AppCodeText varchar(500) null
		,ServiceReferralPK INT 
	);

	with cteServicesNotReceived
	as
	(
		select count(reasonnoservice) as counter
			  ,AppCodeText
			  ,sum(count(reasonnoservice)) over () as 'Total'
			from servicereferral
				left join codeApp on codeApp.appcode = servicereferral.reasonnoservice
				left join codeServiceReferral on codeServiceReferral.ServiceReferralCode = ServiceReferral.ServiceCode
				inner join dbo.SplitString(@programfk,',') on servicereferral.programfk = listitem
			where ReferralDate between @sdate and @edate
				 and natureofreferral = @NatureOfReferral
				 and reasonnoservice is not null
				 and reasonnoservice <> ''
				 and appcodegroup = 'ReasonCode'
				 and appcodeusedwhere = 'SR'
			group by appcodetext	
	
	
	
	)


	insert into @tblResults
		select a.AppCodeText
		  , isnull(COUNTER, 0) AS ServiceReferralPK
		from codeApp a
			left join cteServicesNotReceived st on a.AppCodeText = st.AppCodeText
		where AppCodeGroup = 'ReasonCode'
			 and AppCodeUsedWhere like '%SR%'	
	
		
	--calculate the totals that will we use to calculate percentages
	set @countServiceNotReceived = (select sum(ServiceReferralPK) from @tblResults)

	select AppCodeText
		  ,CONVERT(varchar,sum(ServiceReferralPK))+' ('+CONVERT(varchar,round(COALESCE(cast(sum(ServiceReferralPK) as float)*
			  100/NULLIF(@countServiceNotReceived,0),0),0))+'%)' as TotalServiceNotReceived
		from @tblResults nrc
		group by nrc.AppCodeText

	union

	select ' Total Service not received' as AppCodeText
		  ,CONVERT(varchar,round(COALESCE(NULLIF(@countServiceNotReceived,0),0),0))+' (100%))' as TotalServiceNotReceived


end
GO
