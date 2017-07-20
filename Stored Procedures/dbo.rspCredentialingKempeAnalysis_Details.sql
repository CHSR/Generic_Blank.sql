SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <04/15/2013>
-- Description:	<This Credentialing report gets you 'Details for 1-2.A Acceptance Rates and 1-2.B Refusal Rates Analysis'>
-- rspCredentialingKempeAnalysis_Details 2, '01/01/2011', '12/31/2011'
-- rspCredentialingKempeAnalysis_Details 4, '04/01/2012', '03/31/2013'

-- =============================================


CREATE procedure [dbo].[rspCredentialingKempeAnalysis_Details](
	@programfk    varchar(max)    = NULL,	
	@StartDate DATETIME,
	@EndDate DATETIME

)WITH RECOMPILE
AS
	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

;
with 	ctePIVisits 
			as (select	KempeFK
						, sum(case when PIVisitMade > 0 then 1
									else 0
							end) PIVisitMade
				from		Preintake pi
				inner join dbo.SplitString(@programfk, ',') on pi.ProgramFK = ListItem
				group by	KempeFK
				) 
		, cteCohort

		as (SELECT HVCasePK
		 , 	case
			   when h.tcdob is not null then
				   h.tcdob
			   else
				   h.edc
			end as tcdob
		 , DischargeDate
		 , IntakeDate
		 , k.KempeDate
		 , PC1FK
		 , cp.DischargeReason
		 , ISNULL(cp.DischargeReasonSpecify, '') DischargeReasonSpecify
		 , OldID
		 , PC1ID		 
		 , KempeResult
		 , cp.CurrentFSWFK
		 , cp.CurrentFAWFK	
		 ,	case
			   when h.tcdob is not null then
				   h.tcdob
			   else
				   h.edc
			end as babydate	
		 ,	case
			   when h.IntakeDate is not null then
				   h.IntakeDate
			   else
				   cp.DischargeDate 
			end as testdate	
		  , P.PCDOB 
		  , P.Race 
		  ,ca.MaritalStatus
		  ,ca.HighestGrade 
		  ,ca.IsCurrentlyEmployed
		  ,ca.OBPInHome  		
		  ,case when MomScore = 'U' then 0 else cast(MomScore as int) end as MomScore
		  ,case when DadScore = 'U' then 0 else cast(DadScore as int) end as DadScore 
		  ,FOBPresent
		  ,MOBPresent 
		  ,MOBPartnerPresent
		  ,OtherPresent 
		  ,MOBPartnerPresent as MOBPartner 
		  ,FOBPartnerPresent as FOBPartner
		  ,GrandParentPresent as MOBGrandmother
	,PIVisitMade

	 FROM HVCase h
	INNER JOIN CaseProgram cp ON cp.HVCaseFK = h.HVCasePK
	inner join dbo.SplitString(@ProgramFK,',') on cp.programfk = listitem
	INNER JOIN Kempe k ON k.HVCaseFK = h.HVCasePK
	INNER JOIN PC P ON P.PCPK = h.PC1FK
	left outer join ctePIVisits piv on piv.KempeFK = k.KempePK
	LEFT JOIN CommonAttributes ca ON ca.hvcasefk = h.hvcasepk AND ca.formtype = 'KE'

	WHERE (h.IntakeDate IS NOT NULL OR cp.DischargeDate IS NOT NULL) -- only include kempes that are positive and where there is a clos_date or an intake date.
	AND k.KempeResult = 1
	AND k.KempeDate BETWEEN @StartDate AND @EndDate
	
)	
	
	 SELECT  
	 (CASE WHEN IntakeDate IS NOT NULL THEN  '' --'AcceptedFirstVisitEnrolled' 
	WHEN KempeResult = 1 AND IntakeDate IS NULL AND DischargeDate IS NOT NULL 
	AND (PIVisitMade > 0 AND PIVisitMade IS NOT NULL) THEN '*' -- 'AcceptedFirstVisitNotEnrolled'
	ELSE '' -- 'Refused' 
	END) + PC1ID AS PC1ID
			, LTRIM(RTRIM(faw.firstname))+' '+LTRIM(RTRIM(faw.lastname)) as FAW			
			,convert(varchar(10),KempeDate,101)  as KempeDate
			,LTRIM(RTRIM(fsw.firstname))+' '+LTRIM(RTRIM(fsw.lastname)) as FSW
			,convert(varchar(10),h.DischargeDate,101)  as DischargeDate
			--,cd.ReportDischargeText
			, CASE WHEN h.DischargeReason = '99' THEN h.DischargeReasonSpecify ELSE cd.ReportDischargeText END ReportDischargeText
			, CASE WHEN h.DischargeReason = '36' THEN 1
			WHEN h.DischargeReason = '12' THEN 2
			WHEN h.DischargeReason = '19' THEN 3
			WHEN h.DischargeReason = '07' THEN 4
			WHEN h.DischargeReason = '25' THEN 5
			ELSE 6 END AS DischargeSortCode
            , (CASE WHEN IntakeDate IS NOT NULL THEN  '1' --'AcceptedFirstVisitEnrolled' 
	WHEN KempeResult = 1 AND IntakeDate IS NULL AND DischargeDate IS NOT NULL 
	AND (PIVisitMade > 0 AND PIVisitMade IS NOT NULL) THEN '2' -- 'AcceptedFirstVisitNotEnrolled'
	ELSE '3' -- 'Refused' 
	END) mainsortkey
	 FROM cteCohort h
	left  join worker faw on CurrentFAWFK = faw.workerpk  -- faw
	left  join worker fsw on CurrentFSWFK = fsw.workerpk   -- fsw	 
	left join codeDischarge cd on h.DischargeReason = cd.DischargeCode

	 
	 WHERE --DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  

	 (CASE WHEN IntakeDate IS NOT NULL THEN  '1' --'AcceptedFirstVisitEnrolled' 
	WHEN KempeResult = 1 AND IntakeDate IS NULL AND DischargeDate IS NOT NULL 
	AND (PIVisitMade > 0 AND PIVisitMade IS NOT NULL) THEN '2' -- 'AcceptedFirstVisitNotEnrolled'
	ELSE '3' -- 'Refused' 
	END) IN ('2', '3')


	 ORDER BY mainsortkey, DischargeSortCode, PC1ID -- ReportDischargeText, PC1ID

-- rspCredentialingKempeAnalysis_Details 2, '01/01/2011', '12/31/2011'



GO
