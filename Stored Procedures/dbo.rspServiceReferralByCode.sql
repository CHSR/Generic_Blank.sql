SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 05/22/2010
-- Description:	Service Referrals by Code
-- =============================================
CREATE procedure [dbo].[rspServiceReferralByCode] 
	-- Add the parameters for the stored procedure here
	@programfk varchar(max) = null
  , @workerfk int = null
  , @StartDt datetime
  , @EndDt datetime
  , @pc1id as varchar(13) = null
  , @doWorker as int = 0
  , @doPC1ID as int = 0
  , @SiteFK int = null
  , @CaseFiltersPositive varchar(100) = ''
as
	if @programfk is null
		begin
			select	@programfk = substring((select	',' + ltrim(rtrim(str(HVProgramPK)))
											from	HVProgram
										   for
											xml	path('')
										   ), 2, 8000)
		end
	set @programfk = replace(@programfk, '"', '')
	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0
					   else @SiteFK
				  end
	set @CaseFiltersPositive = case	when @CaseFiltersPositive = '' then null
									else @CaseFiltersPositive
							   end
	
--DECLARE @programfk INT = 5
--DECLARE @workerfk INT = NULL
--DECLARE @StartDt DATETIME = '04/01/2012'
--DECLARE @EndDt DATETIME = '06/30/2012'
--DECLARE @pc1id AS VARCHAR(13)
--DECLARE @doWorker AS INT = 0
--DECLARE @doPC1ID AS INT = 0

;
	with	HVCaseInRange
			  as (select	b.PC1ID
						  , b.HVCaseFK
--, CASE WHEN a.IntakeDate < @StartDt THEN @StartDt ELSE a.IntakeDate END [Start_Period]
--, CASE WHEN b.DischargeDate IS NULL THEN @EndDt
--  WHEN b.DischargeDate > @EndDt THEN @EndDt ELSE b.DischargeDate END [End_Period]
						  , @StartDt [Start_Period]
						  , @EndDt [End_Period]
				  from		HVCase as a
					join		CaseProgram as b on a.HVCasePK = b.HVCaseFK
					left outer join Worker w on w.WorkerPK = b.CurrentFSWFK
					join Workerprogram as wp on wp.WorkerFK = w.WorkerPK AND wp.programfk = b.ProgramFK
					inner join dbo.udfCaseFilters(@casefilterspositive, '', @programfk) cf on cf.HVCaseFK = a.HVCasePK
				  where		a.IntakeDate <= @EndDt
							and a.IntakeDate is not null
							and (b.DischargeDate is null
								 or b.DischargeDate > @StartDt
								)
							and b.PC1ID = isnull(@pc1id, b.PC1ID)
				 )
		select	case when @doWorker = 1 then ltrim(rtrim(fsw.FirstName)) + ' ' + ltrim(rtrim(fsw.LastName))
					 else 'All Workers'
				end [worker]
			  , case when @doPC1ID = 1 then PC1ID
					 else ''
				end [PC1ID]
			  , ServiceReferralCategory = case b.ServiceReferralCategory
											when 'HC' then 'Health Care'
											when 'NUT' then 'Nutrition'
											when 'DSS' then 'Public Benefits'
											when 'FSS' then 'Family & Social Support Services'
											when 'ETE' then 'Employment, Training & Education'
											when 'CSS' then 'Counseling & Intensive Support Services'
											when 'CON' then 'Concrete Services'
											when 'OTH' then 'Other Services'
											else 'No Match'
										  end + ' (' + ltrim(rtrim(b.ServiceReferralCategory)) + ')'
			  , b.ServiceReferralCode + '-' + ltrim(rtrim(b.ServiceReferralType)) [ServiceReferralCode]
			  , ltrim(rtrim(b.ServiceReferralCategory)) [CategoryCode]
			  , x.n
		from	(select	case when @doWorker = 1 then isnull(b.CurrentFSWFK, b.CurrentFAWFK)
							 else ''
						end [FSWFK]
					  , case when @doPC1ID = 1 then b.PC1ID
							 else ''
						end [PC1ID]
					  , a.ServiceCode
					  , count(*) [n]
				 from	ServiceReferral a
				 join	CaseProgram as b on a.HVCaseFK = b.HVCaseFK
				 inner join dbo.SplitString(@programfk, ',') on b.ProgramFK = ListItem
				 join	HVCaseInRange as b1 on b1.HVCaseFK = a.HVCaseFK
				 where	--a.ProgramFK = @programfk AND 
						a.ReferralDate between @StartDt and @EndDt
--AND a.ServiceReceived = 1
--AND a.FSWFK = ISNULL(@workerfk, a.FSWFK)
						and isnull(b.CurrentFSWFK, b.CurrentFAWFK) = isnull(@workerfk,
																			isnull(b.CurrentFSWFK, b.CurrentFAWFK))
				 group by case when @doWorker = 1 then isnull(b.CurrentFSWFK, b.CurrentFAWFK)
							   else ''
						  end
					  , case when @doPC1ID = 1 then b.PC1ID
							 else ''
						end
					  , a.ServiceCode
				) x
		left outer join Worker fsw on x.FSWFK = fsw.WorkerPK
--INNER JOIN workerprogram wp
--ON wp.workerfk = fsw.workerpk
		inner join codeServiceReferral b on x.ServiceCode = b.ServiceReferralCode
		order by worker
			  , PC1ID
			  , ServiceReferralCategory
			  , ServiceReferralCode





GO
