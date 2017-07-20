SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 4, 2012>
-- Description:	<Report - Service Referrals Needing Followup>
-- =============================================

CREATE procedure [dbo].[rspServiceReferralsNeedFollowUp](@programfk    varchar(max)    = null,
                                                        @supervisorfk int             = null,
                                                        @workerfk     int             = null,
                                                        @pc1id        varchar(13)     = null,
                                                        @sitefk		  int			 = null,
                                                        @casefilterspositive varchar(200), 
                                                        @negclause	 varchar(200))
as

	if @programfk is null
	begin
		select @programfk =
			   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')
	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end
	set @casefilterspositive = case when @casefilterspositive = '' then null else @casefilterspositive end

	select PC1ID
		  ,pcfirstname+' '+pclastname as PC1
		  ,ServiceReferralCode + '-' + ServiceReferralType as Referral
		  ,AppCodeText as FamilyMemberReferred
		  ,ReferralDate
		  ,currentfswfk
		  ,rtrim(fsw.FirstName)+' '+rtrim(fsw.LastName) as fsw
		  ,supervisorfk
		  ,rtrim(supervisor.FirstName)+' '+rtrim(supervisor.LastName) as supervisor
		  ,cp.ProgramFK
		from dbo.ServiceReferral
			inner join dbo.codeServiceReferral on ServiceReferralCode = ServiceCode
			inner join dbo.codeApp on FamilyCode = codeApp.AppCode
					  and codeApp.AppCodeGroup = 'FamilyMemberReferred'
			inner join CaseProgram cp on ServiceReferral.HVCaseFK = cp.HVCaseFK
					  and ServiceReferral.ProgramFK = cp.ProgramFK
			inner join HVCase c on cp.HVCaseFK = HVCasePK
			inner join PC on c.PC1FK = PCPK
			inner join worker fsw on CurrentFSWFK = fsw.workerpk
			inner join workerprogram wp on wp.workerfk = fsw.workerpk and wp.ProgramFK = cp.ProgramFK
			inner join worker supervisor on supervisorfk = supervisor.workerpk
			inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
			inner join dbo.udfCaseFilters(@casefilterspositive, @negclause, @programfk) cf on cf.HVCaseFK = c.HVCasePK
		where (ServiceReceived is null
				 or ServiceReceived = 0
				 or ServiceReceived = RTRIM(''))
			 and (ReasonNoService = rtrim(''))
			 and DischargeDate is null
			 and currentFSWFK = isnull(@workerfk,currentFSWFK)
			 and supervisorfk = isnull(@supervisorfk,supervisorfk)
			 and PC1ID = isnull(@pc1id,PC1ID)
			 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
		order by PC1ID
				,ReferralDate
GO
