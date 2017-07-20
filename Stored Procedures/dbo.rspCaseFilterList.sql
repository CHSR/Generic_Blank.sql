SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <June 26th, 2014>
-- Description:	<gets you Case Filter List for all cases (pc1id's) in a given program>

-- [rspCaseFilterList] 1
-- exec dbo.rspCaseFilterList @programfks='1',@casefilterspositive=NULL
-- =============================================
CREATE procedure [dbo].[rspCaseFilterList] (@ProgramFKs varchar(max) = null
											, @StartDate datetime
											, @EndDate datetime
											, @SiteFK int = null
											, @CaseFiltersPositive varchar(200) = null
										  )
as
	begin

		set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0
							else @SiteFK
						end
		set @CaseFiltersPositive = case	when @CaseFiltersPositive = '' then null
										else @CaseFiltersPositive
								   end;
		with cteMain
				  as (select	HVCasePK
							  , rtrim(P.PCFirstName) + ' ' + rtrim(P.PCLastName) as PC1FullName
							  , PC1ID
							  , PCDOB
							  , ScreenDate
							  , KempeDate
							  , IntakeDate
							  , DischargeDate
							  , DischargeReason
							  , DischargeReasonSpecify
							  , CurrentFAWFK
							  , CurrentFSWFK
							  , CurrentLevelFK
							  , rtrim(lcf.FieldTitle) as FieldTitle
							  , case -- handling different types of filter types
									 when lcf.FilterType = 1 then case when cf2.CaseFilterNameChoice = 1 then 'Yes'
																	   else 'No'
																  end
									 when lcf.FilterType = 2
									 then (select	cfno.FilterOption
										   from		listCaseFilterNameOption cfno
										   where	listCaseFilterNameOptionPK = cf2.CaseFilterNameOptionFK
										  )
									 when lcf.FilterType = 3 then CaseFilterValue
								end as FilterOption
					  from		HVCase h
					  inner join CaseProgram cp on cp.HVCaseFK = h.HVCasePK
					  inner join dbo.SplitString(@ProgramFKs, ',') ss on ss.ListItem = cp.ProgramFK
					  inner join PC P on P.PCPK = h.PC1FK
					  inner join dbo.udfCaseFilters(@CaseFiltersPositive, '', @ProgramFKs) cf on cf.HVCaseFK = cp.HVCaseFK
					  inner join CaseFilter cf2 on cf2.HVCaseFK = cp.HVCaseFK
					  inner join listCaseFilterName lcf on lcf.listCaseFilterNamePK = cf2.CaseFilterNameFK
					  left outer join Worker w on w.WorkerPK = cp.CurrentFSWFK
					  left outer join WorkerProgram wp on wp.WorkerFK = w.WorkerPK and wp.ProgramFK = cp.ProgramFK
					  where case when @SiteFK = 0 then 1
										 when wp.SiteFK = @SiteFK then 1
										 else 0
									end = 1
							and h.ScreenDate between @StartDate and @EndDate
					 ) ,
			cteFilterOptions
				  as -- merge rows i.e. put all filters in one row given an hvcasepk / pc1id
					(select	HVCasePK
						  , FilterOption = replace((select	cast(FieldTitle + ':' + FilterOption as varchar(50)) as [data()]
													from	cteMain m1
													where	m1.HVCasePK = m2.HVCasePK
													order by HVCasePK
												   for
													xml	path('')
												   ), ' ', ',')
							  
							  --,FilterOption 
					 from	cteMain m2
					 group by HVCasePK
					) ,				
			cteFAWFSWNames
				  as (select distinct
								HVCasePK
							  , case when m3.CurrentFAWFK is null then 'NO FAW Assigned'
									 else rtrim(w.FirstName) + ' ' + rtrim(w.LastName)
								end as FAWName
							  , rtrim(fsw.FirstName) + ' ' + rtrim(fsw.LastName) fswname
							  , CurrentFAWFK
							  , CurrentFSWFK
					  from		cteMain m3
					  inner join Worker w on w.WorkerPK = m3.CurrentFAWFK
					  inner join Worker fsw on fsw.WorkerPK = m3.CurrentFSWFK
					 ) ,
			cteUniqueFilterCases
				  as (select distinct
								HVCasePK
							  , PC1FullName
							  , PC1ID
							  , PCDOB
							  , ScreenDate
							  , KempeDate
							  , IntakeDate
							  , DischargeDate
							  , DischargeReason
							  , DischargeReasonSpecify
							  , CurrentFAWFK
							  , CurrentFSWFK
							  , CurrentLevelFK
					  from		cteMain
					 ) ,
				cteFilterCaseList
				  as (select 
		  -- ufc.HVCasePK
								PC1FullName
							  , PC1ID
							  , convert(varchar(12), PCDOB, 101) PCDOB
							  , convert(varchar(12), ScreenDate, 101) ScreenDate
							  , convert(varchar(12), KempeDate, 101) KempeDate
							  , convert(varchar(12), IntakeDate, 101) IntakeDate
							  , convert(varchar(12), DischargeDate, 101) DischargeDate
		  --,ufc.DischargeReason
							  , ds.DischargeReason
							  , DischargeReasonSpecify
		  --,ufc.CurrentFAWFK
		  --,ufc.CurrentFSWFK
							  , FAWName
							  , fswname		  
		  --,CurrentLevelFK
							  , LevelName
							  , FilterOption
					  from		cteUniqueFilterCases ufc
					  inner join cteFilterOptions fo on fo.HVCasePK = ufc.HVCasePK
					  inner join cteFAWFSWNames FAWFSW on FAWFSW.HVCasePK = ufc.HVCasePK
					  left join codeDischarge ds on ds.DischargeCode = ufc.DischargeReason
					  left join codeLevel on codeLevel.codeLevelPK = ufc.CurrentLevelFK
					 )
			--SELECT * FROM cteFilterOptions
--SELECT * FROM cteUniqueFilterCases
select	*
from	cteFilterCaseList
order by PC1ID
-- [rspCaseFilterList] 1


	end
GO
