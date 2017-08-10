SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jrobohn
-- Create date: <June 17, 2014>
-- Description:	<Aggregate Counts report aka Joy Count aka the OCFS Counts>
-- rspDataReport 22, '03/01/2013', '05/31/2013'		
-- exec [rspAggregateCounts] ',8,','10/01/2013' , '12/31/2013'
-- exec [rspAggregateCounts] ',16,','09/01/2013' , '5/31/2014'
-- exec [rspAggregateCounts] '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39','09/01/2013' , '5/31/2014'
-- =============================================
CREATE procedure [dbo].[rspAggregateCounts]
(
    @ProgramFKs				varchar(max)    = null,
    @StartDate				datetime,
    @EndDate				DATETIME 
)
as
begin

	/* 
		all screens used in this report
	*/  
	with cteAllScreens
	as
		(select HVScreenPK, ScreenDate, ScreenResult 
		  from HVScreen s
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where ScreenDate <= @EndDate 
		)
	,	  
	/*
		count of screens completed since beginning of program
	*/  
	cteScreensCompletedSinceBeginning
	as	
		(select count(HVScreenPK) as countOfScreensCompletedSinceBeginning
		  from cteAllScreens
		)
	,
	/* 
		count of screens completed in reporting period
	*/  
	cteScreensCompletedInPeriod
	as
		(select count(HVScreenPK) as countOfScreensCompletedInPeriod
		  from cteAllScreens
		  where ScreenDate between @StartDate and @EndDate 
		)
	,

	/* ---------------------------------------------- */

	/* 
		all preintake home visit counts in this report
	*/  
	cteAllPreintakeHomeVisit
	as
		(select a.PreintakePK, PIDate, ISNULL(PIVisitMade,0) VisitMode, 
		CASE WHEN (CaseStatus = '02' AND ISNULL(PIVisitMade, 0) > 0) THEN 1 ELSE 0 END Enrolled
		  from Preintake AS a
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where PIDate <= @EndDate 
		)
	,	  
	/*
		count of preintake home visit since beginning of program
	*/  
	ctePreintakeHomeVisitSinceBeginning
	as	
		(select (SUM(VisitMode) - SUM(Enrolled)) as countOfPreintakeHomeVisitSinceBeginning
		  from cteAllPreintakeHomeVisit
		)
	,
	/* 
		count of preintake home visit in reporting period
	*/  
	ctePreintakeHomeVisitInPeriod
	as
		(select (SUM(VisitMode) - SUM(Enrolled)) countOfPreintakeHomeVisitInPeriod
		  from cteAllPreintakeHomeVisit
		  where PIDate between @StartDate and @EndDate 
		)
	,

	/* ---------------------------------------------- */


	/* 
		count of positive screens since beginning of program
	*/  
	ctePositiveScreensSinceBeginning
	as
		(select count(HVScreenPK) as countOfPositiveScreensSinceBeginning
		  from cteAllScreens
		  where ScreenResult = '1'
		)
	,
	/* 
		count of negative screens since beginning of program
	*/  
	cteNegativeScreensSinceBeginning
	as
		(select count(HVScreenPK) as countOfNegativeScreensSinceBeginning
		  from cteAllScreens
		  where ScreenResult = '0'
		)
	,
	/* 
		count of positive screens completed in reporting period
	*/  
	ctePositiveScreensInPeriod
	as
		(select count(HVScreenPK) as countOfPositiveScreensInPeriod
		  from cteAllScreens
		  where ScreenDate between @StartDate and @EndDate and
				ScreenResult = '1'
		)
	,
	/* 
		count of negative screens completed in reporting period
	*/  
	cteNegativeScreensInPeriod
	as
		(select count(HVScreenPK) as countOfNegativeScreensInPeriod
	  		  from cteAllScreens
		  where ScreenDate between @StartDate and @EndDate and
				ScreenResult = '0'
		)
	,
	/* 
		count of Kempes completed since beginning of program
	*/  
	cteAllKempes
	as	
		(select KempePK, KempeDate, KempeResult, FOBPresent
		  from Kempe k
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where KempeDate <= @EndDate 
		)
	,
	/* 
		count of Kempes completed since beginning of program
	*/  
	cteKempesCompletedSinceBeginning
	as	
		(select count(KempePK) as countOfKempesCompletedSinceBeginning
		  from cteAllKempes
		)
	,
	/* 
		count of Kempes completed in reporting period
	*/  
	cteKempesCompletedInPeriod
	as
		(select count(KempePK) as countOfKempesCompletedInPeriod
		  from cteAllKempes
		  where KempeDate between @StartDate and @EndDate 
		)
	,
	/* 
		count of positive Kempes since beginning of program
	*/  
	ctePositiveKempesSinceBeginning
	as
		(select count(KempePK) as countOfPositiveKempesSinceBeginning
		  from cteAllKempes
		  where KempeResult = 1
		)
	,
	/* 
		count of negative Kempes since beginning of program
	*/  
	cteNegativeKempesSinceBeginning
	as
		(select count(KempePK) as countOfNegativeKempesSinceBeginning
		  from cteAllKempes
		  where KempeResult = 0
		)
	,

	/* 
		count of FOB present Kempes since beginning of program
	*/  
	cteFOBPresentKempesSinceBeginning
	as
		(select count(KempePK) as countOfFOBPresentKempesSinceBeginning
		  from cteAllKempes
		  where FOBPresent = 1
		)
	,


	/* 
		count of positive Kempes completed in reporting period
	*/  
	ctePositiveKempesInPeriod
	as
		(select count(KempePK) as countOfPositiveKempesInPeriod
		  from cteAllKempes
		  where KempeDate between @StartDate and @EndDate and
				KempeResult = 1
		)
	,
	/* 
		count of negative Kempes completed in reporting period
	*/  
	cteNegativeKempesInPeriod
	as
		(select count(KempePK) as countOfNegativeKempesInPeriod
		  from cteAllKempes
		  where KempeDate between @StartDate and @EndDate and
				KempeResult = 0
		)
	,

	/* 
		count of FOB present Kempes completed in reporting period
	*/  
	cteFOBPresentKempesInPeriod
	as
		(select count(KempePK) as countOfFOBPresentKempesInPeriod
		  from cteAllKempes
		  where KempeDate between @StartDate and @EndDate and
				FOBPresent = 1
		)
	,

	/* 
		count of familes enrolled since beginning of program
	*/  
	cteFamiliesEnrolledSinceBeginning
	as	
		(select count(HVCasePK) as countOfFamiliesEnrolledSinceBeginning
		  from HVCase c
		  inner join CaseProgram cp on cp.HVCaseFK = c.HVCasePK
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where IntakeDate <= @EndDate
		)
	,
	/* 
		count of familes enrolled prenatally since beginning of program
	*/  
	cteFamiliesEnrolledPrenatallySinceBeginning
	as	
		(select count(HVCasePK) as countOfFamiliesEnrolledPrenatallySinceBeginning
		  from HVCase c
		  inner join CaseProgram cp on cp.HVCaseFK = c.HVCasePK
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where IntakeDate <= @EndDate and
				isnull(TCDOB, EDC) > IntakeDate
		)
	,
	/* 
		count of familes enrolled postnatally since beginning of program
	*/  
	cteFamiliesEnrolledPostnatallySinceBeginning
	as	
		(select count(HVCasePK) as countOfFamiliesEnrolledPostnatallySinceBeginning
		  from HVCase c
		  inner join CaseProgram cp on cp.HVCaseFK = c.HVCasePK
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where IntakeDate <= @EndDate and
				isnull(TCDOB, EDC) <= IntakeDate
		)
	,
	/* 
		count of familes enrolled in reporting period
	*/  
	cteFamiliesEnrolledInPeriod
	as	
		(select count(HVCasePK) as countOfFamiliesEnrolledInPeriod
		  from HVCase c
		  inner join CaseProgram cp on cp.HVCaseFK = c.HVCasePK
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where IntakeDate between @StartDate and @EndDate
		)
	,
	/* 
		count of familes enrolled prenatally in reporting period
	*/  
	cteFamiliesEnrolledPrenatallyInPeriod
	as	
		(select count(HVCasePK) as countOfFamiliesEnrolledPrenatallyInPeriod
		  from HVCase c
		  inner join CaseProgram cp on cp.HVCaseFK = c.HVCasePK
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where IntakeDate between @StartDate and @EndDate and
				isnull(TCDOB, EDC) > IntakeDate
		)
	,
	/* 
		count of familes enrolled postnatally in reporting period
	*/  
	cteFamiliesEnrolledPostnatallyInPeriod
	as	
		(select count(HVCasePK) as countOfFamiliesEnrolledPostnatallyInPeriod
		  from HVCase c
		  inner join CaseProgram cp on cp.HVCaseFK = c.HVCasePK
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where IntakeDate between @StartDate and @EndDate and
				isnull(TCDOB, EDC) <= IntakeDate
		)
	,
	/* 
		count of familes served since beginning of program
	*/  
	cteFamiliesServedSinceBeginning
	as	
		(select count(HVCasePK) as countOfFamiliesServedSinceBeginning
		  from HVCase c
		  inner join CaseProgram cp on cp.HVCaseFK = c.HVCasePK
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where IntakeDate <= @EndDate 
		)
	,
	/* 
		count of familes served in reporting period
	*/  
	cteFamiliesServedInPeriod
	as	
		(select count(HVCasePK) as countOfFamiliesServedInPeriod
		  from HVCase c
		  inner join CaseProgram cp on cp.HVCaseFK = c.HVCasePK
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where IntakeDate <= @EndDate 
				and (DischargeDate is null or DischargeDate >= @StartDate)
		)
	,
	/* 
		count of familes enrolled at end of reporting period
	*/  
	cteFamiliesEnrolledAtEndOfPeriod
	as	
		(select count(HVCasePK) as countOfFamiliesEnrolledAtEndOfPeriod
		  from HVCase c
		  inner join CaseProgram cp on cp.HVCaseFK = c.HVCasePK
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where IntakeDate <= @EndDate and 
				(DischargeDate is null or DischargeDate > @EndDate)
		)
	,
	/* 
		count of target children born since beginning of program
	*/  
	cteTargetChildrenBornSinceBeginning
	as
		(select count(TCIDPK) as countOfTargetChildrenBornSinceBeginning 
		  from HVCase
		  inner join CaseProgram cp on cp.HVCaseFK = HVCase.HVCasePK
		  inner join TCID T on T.HVCaseFK = HVCase.HVCasePK
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
		  where IntakeDate <= @EndDate 
				and T.TCDOB <= @EndDate
		)
	,
	/* 
		count of target children born in reporting period
	*/  
	cteTargetChildrenBornInPeriod
	as
		(select count(TCIDPK) as countOfTargetChildrenBornInPeriod 
		  from HVCase
		  inner join CaseProgram cp on cp.HVCaseFK = HVCase.HVCasePK
		  inner join TCID T on T.HVCaseFK = HVCase.HVCasePK
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
		  where IntakeDate <= @EndDate 
				and T.TCDOB between @StartDate and @EndDate
		)
	--,
	--/* 
	--	count of other target children served since beginning of program
	--*/  
	--cteOtherTargetChildrenServedSinceBeginning
	--as
	--	(select count(TCIDPK) as countOfOtherTargetChildrenServedSinceBeginning
	--	  from HVCase
	--	  inner join CaseProgram cp on cp.HVCaseFK = HVCase.HVCasePK
	--	  inner join TCID T on T.HVCaseFK = HVCase.HVCasePK
	--	  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
	--	  where IntakeDate <= @EndDate 
	--			and T.TCDOB < @StartDate
	--	)
	,
	/* 
		count of other target children served since beginning of program
	*/  
	cteOtherTargetChildrenServedInPeriod
	as
		(select count(TCIDPK) as countOfOtherTargetChildrenServedInPeriod 
		  from HVCase
		  inner join CaseProgram cp on cp.HVCaseFK = HVCase.HVCasePK
		  inner join TCID T on T.HVCaseFK = HVCase.HVCasePK
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
		  where IntakeDate <= @EndDate 
				and (DischargeDate is null or DischargeDate >= @StartDate)
				and T.TCDOB < @StartDate
		)
	,
	/* 
		count of other children served since beginning of program
	*/  
	cteOtherChildrenServedSinceBeginning
	as
		(select count(OtherChildPK) as countOfOtherChildrenServedSinceBeginning
		  from HVCase
		  inner join CaseProgram cp on cp.HVCaseFK = HVCase.HVCasePK
		  --inner join TCID T on T.HVCaseFK = HVCase.HVCasePK
		  inner join OtherChild oc on oc.HVCaseFK = HVCase.HVCasePK
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
		  where IntakeDate <= @EndDate 
				-- and (DischargeDate is null or DischargeDate >= @StartDate)
		  --and T.TCDOB<='09/30/13'
		  and oc.LivingArrangement='01'
		)
	,
	/* 
		count of other children served in reporting period
	*/  
	cteOtherChildrenServedInPeriod
	as
		(select count(OtherChildPK) as countOfOtherChildrenServedInPeriod
		  from HVCase
		  inner join CaseProgram cp on cp.HVCaseFK = HVCase.HVCasePK
		  --inner join TCID T on T.HVCaseFK = HVCase.HVCasePK
		  inner join OtherChild oc on oc.HVCaseFK = HVCase.HVCasePK
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
		  where IntakeDate <= @EndDate 
				and (DischargeDate is null or DischargeDate >= @StartDate)
		  --and T.TCDOB<='09/30/13'
		  and oc.LivingArrangement='01'
		)
	,
	/* 
		count of home visit logs since beginning of program
	*/ 
	cteHomeVisitLogsSinceBeginning
	as
		(select count(HVLogPK) as countOfHomeVisitLogsSinceBeginning
		  from HVLog
		  inner join SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where convert(date, VisitStartTime) <= @EndDate
		)
	,
	/* 
		count of completed home visit logs since beginning of program
	*/ 
	cteCompletedHomeVisitLogsSinceBeginning
	as
		(select count(HVLogPK) as countOfCompletedHomeVisitLogsSinceBeginning
		  from HVLog
		  inner join SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where convert(date, VisitStartTime) <= @EndDate
				and VisitType <> '00010'
		)
	,
	/* 
		count of attempted home visit logs since beginning of program
	*/ 
	cteAttemptedHomeVisitLogsSinceBeginning
	as
		(select count(HVLogPK) as countOfAttemptedHomeVisitLogsSinceBeginning
		  from HVLog
		  inner join SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where convert(date, VisitStartTime) <= @EndDate
				and VisitType = '00010'
		)
	,
	/* 
		count of home visit logs in reporting period
	*/ 
	cteHomeVisitLogsInPeriod
	as
		(select count(HVLogPK) as countOfHomeVisitLogsInPeriod
		  from HVLog
		  inner join SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where convert(date, VisitStartTime) between @StartDate and @EndDate
		)
	,
	/* 
		count of completed home visit logs in reporting period
	*/ 
	cteCompletedHomeVisitLogsInPeriod
	as
		(select count(HVLogPK) as countOfCompletedHomeVisitLogsInPeriod
		  from HVLog
		  inner join SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where convert(date, VisitStartTime) between @StartDate and @EndDate
				and VisitType <> '00010'
		)
	,
	/* 
		count of attempted home visit logs in reporting period
	*/ 
	cteAttemptedHomeVisitLogsInPeriod
	as
		(select count(HVLogPK) as countOfAttemptedHomeVisitLogsInPeriod
		  from HVLog
		  inner join SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where convert(date, VisitStartTime) between @StartDate and @EndDate and 
				VisitType = '00010'
		)
	,
	/* 
		count of families with at least one home visit log since beginning of program
	*/ 
	cteFamiliesWithAtLeastOneHomeVisitSinceBeginning
	as
		(select count(distinct HVCaseFK) as countOfFamiliesWithAtLeastOneHomeVisitSinceBeginning
		  from HVLog
		  inner join SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where convert(date, VisitStartTime) <= @EndDate
		)
	,
	/* 
		count of families with at least one home visit log in reporting period
	*/ 
	cteFamiliesWithAtLeastOneHomeVisitInPeriod
	as
		(select count(distinct HVCaseFK) as countOfFamiliesWithAtLeastOneHomeVisitInPeriod
		  from HVLog
		  inner join SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where convert(date, VisitStartTime) between @StartDate and @EndDate
		)
	,
	/* 
		count of families with at least one home visit log since beginning of program
	*/ 
	cteFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherSinceBeginning
	as
		(select count(distinct HVCaseFK) as countOfFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherSinceBeginning
		  from HVLog
		  inner join SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where convert(date, VisitStartTime) <= @EndDate and
				(OBPParticipated = 1 or FatherFigureParticipated = 1)
		)
	,
	/* 
		count of families with at least one home visit log in reporting period
	*/ 
	cteFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherInPeriod
	as
		(select count(distinct HVCaseFK) as countOfFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherInPeriod
		  from HVLog
		  inner join SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where convert(date, VisitStartTime) between @StartDate and @EndDate and
				(OBPParticipated = 1 or FatherFigureParticipated = 1)
		)
	, 
	cteFinal 
	as
		(select /* Screens completed */
				countOfScreensCompletedSinceBeginning
				, 1 as pctOfScreensCompletedSinceBeginning
				, countOfScreensCompletedInPeriod
				, 1  as pctOfScreensCompletedInPeriod
				, countOfPositiveScreensSinceBeginning
				, case when countOfScreensCompletedSinceBeginning is null or countOfScreensCompletedSinceBeginning = 0 then 0 
						else round(countOfPositiveScreensSinceBeginning / (countOfScreensCompletedSinceBeginning * 1.0000), 2) 
					end as pctOfPositiveScreensSinceBeginning
				, countOfNegativeScreensSinceBeginning
				, case when countOfScreensCompletedSinceBeginning is null or countOfScreensCompletedSinceBeginning = 0 then 0
						else round(countOfNegativeScreensSinceBeginning / (countOfScreensCompletedSinceBeginning * 1.0000), 2) 
					end as pctOfNegativeScreensSinceBeginning
				
				/* Positive screens */
				, countOfPositiveScreensInPeriod
				, case when countOfScreensCompletedInPeriod is null or countOfScreensCompletedInPeriod = 0 then 0
						else round(countOfPositiveScreensInPeriod / (countOfScreensCompletedInPeriod * 1.0000), 2) 
					end as pctOfPositiveScreensInPeriod

				/* Negative screens */
				, countOfNegativeScreensInPeriod
				, case when countOfScreensCompletedInPeriod is null or countOfScreensCompletedInPeriod = 0 then 0
						else round(countOfNegativeScreensInPeriod / (countOfScreensCompletedInPeriod * 1.0000), 2) 
					end as pctOfNegativeScreensInPeriod
				
				/* Kempes completed */
				, countOfKempesCompletedSinceBeginning
				, 1 as pctOfKempesCompletedSinceBeginning
				, countOfKempesCompletedInPeriod
				, 1 as pctOfKempesCompletedInPeriod
				
				/* Positive Kempes */
				, countOfPositiveKempesSinceBeginning
				, case when countOfKempesCompletedSinceBeginning is null or countOfKempesCompletedSinceBeginning = 0 then 0
						else round(countOfPositiveKempesSinceBeginning / (countOfKempesCompletedSinceBeginning * 1.0000), 2) 
					end as pctOfPositiveKempesSinceBeginning
				, countOfPositiveKempesInPeriod
				, case when countOfKempesCompletedInPeriod is null or countOfKempesCompletedInPeriod = 0 then 0
						else round(countOfPositiveKempesInPeriod / (countOfKempesCompletedInPeriod * 1.0000), 2) 
					end as pctOfPositiveKempesInPeriod

				/* Negative Kempes */
				, countOfNegativeKempesSinceBeginning
				, case when countOfKempesCompletedSinceBeginning is null or countOfKempesCompletedSinceBeginning = 0 then 0
						else round(countOfNegativeKempesSinceBeginning / (countOfKempesCompletedSinceBeginning * 1.0000), 2) 
					end as pctOfNegativeKempesSinceBeginning
				, countOfNegativeKempesInPeriod
				, case when countOfKempesCompletedInPeriod is null or countOfKempesCompletedInPeriod = 0 then 0
						else round(countOfNegativeKempesInPeriod / (countOfKempesCompletedInPeriod * 1.0000), 2) 
					end as pctOfNegativeKempesInPeriod

				/* Father of Baby Present Kempes */
				, countOfFOBPresentKempesSinceBeginning
				, case when countOfKempesCompletedSinceBeginning is null or countOfKempesCompletedSinceBeginning = 0 then 0
						else round(countOfFOBPresentKempesSinceBeginning / (countOfKempesCompletedSinceBeginning * 1.0000), 2) 
					end as pctOfFOBPresentKempesSinceBeginning

				, countOfFOBPresentKempesInPeriod
				, case when countOfKempesCompletedInPeriod is null or countOfKempesCompletedInPeriod = 0 then 0
						else round(countOfFOBPresentKempesInPeriod / (countOfKempesCompletedInPeriod * 1.0000), 2) 
					end as pctOfFOBPresentKempesInPeriod

				, countOfPreintakeHomeVisitInPeriod
				, countOfPreintakeHomeVisitSinceBeginning

				/* Enrolled Families */
				/* Since Beginning */
				, countOfFamiliesEnrolledSinceBeginning
				, 1 as pctOfFamiliesEnrolledSinceBeginning
				/* Prenatally */
				, countOfFamiliesEnrolledPrenatallySinceBeginning
				, case when countOfFamiliesEnrolledSinceBeginning is null or countOfFamiliesEnrolledSinceBeginning = 0 then 0
						else round(countOfFamiliesEnrolledPrenatallySinceBeginning / (countOfFamiliesEnrolledSinceBeginning * 1.0000), 2) 
					end as pctOfFamiliesEnrolledPrenatallySinceBeginning
				/* Postnatally */
				, countOfFamiliesEnrolledPostnatallySinceBeginning
				, case when countOfFamiliesEnrolledSinceBeginning is null or countOfFamiliesEnrolledSinceBeginning = 0 then 0
						else round(countOfFamiliesEnrolledPostnatallySinceBeginning / (countOfFamiliesEnrolledSinceBeginning * 1.0000), 2) 
					end as pctOfFamiliesEnrolledPostnatallySinceBeginning
				/* In Period */
				, countOfFamiliesEnrolledInPeriod
				, 1 as pctOfFamiliesEnrolledInPeriod
				/* Prenatally */
				, countOfFamiliesEnrolledPrenatallyInPeriod
				, case when countOfFamiliesEnrolledInPeriod is null or countOfFamiliesEnrolledInPeriod = 0 then 0
						else round(countOfFamiliesEnrolledPrenatallyInPeriod / (countOfFamiliesEnrolledInPeriod * 1.0000), 2) 
					end as pctOfFamiliesEnrolledPrenatallyInPeriod
				/* Postnatally */
				, countOfFamiliesEnrolledPostnatallyInPeriod
				, case when countOfFamiliesEnrolledInPeriod is null or countOfFamiliesEnrolledInPeriod = 0 then 0
						else round(countOfFamiliesEnrolledPostnatallyInPeriod / (countOfFamiliesEnrolledInPeriod * 1.0000), 2) 
					end as pctOfFamiliesEnrolledPostnatallyInPeriod
			
				/* Families Served */
				, countOfFamiliesServedSinceBeginning
				, countOfFamiliesServedInPeriod
				, countOfFamiliesEnrolledAtEndOfPeriod
	
				/* Target Children born and served */
				, countOfTargetChildrenBornSinceBeginning
				, countOfTargetChildrenBornInPeriod
				, 0 as countOfOtherTargetChildrenServedSinceBeginning
				--, replace(convert(varchar(20), (cast(countOfOtherTargetChildrenServedSinceBeginning as money)), 1), '.00', '') as countOfOtherTargetChildrenServedSinceBeginning
				, countOfOtherTargetChildrenServedInPeriod
				, countOfOtherChildrenServedSinceBeginning
				, countOfOtherChildrenServedInPeriod

				/* Home Visit Logs*/
				/* Since Beginning */
				, countOfHomeVisitLogsSinceBeginning
				, 1 as pctOfHomeVisitLogsSinceBeginning
				/* Completed */
				, countOfCompletedHomeVisitLogsSinceBeginning
				, case when countOfHomeVisitLogsSinceBeginning is null or countOfHomeVisitLogsSinceBeginning = 0 then 0
						else round(countOfCompletedHomeVisitLogsSinceBeginning / (countOfHomeVisitLogsSinceBeginning * 1.0000), 2) 
					end as pctOfCompletedHomeVisitLogsSinceBeginning
				/* Attempted */
				, countOfAttemptedHomeVisitLogsSinceBeginning
				, case when countOfHomeVisitLogsSinceBeginning is null or countOfHomeVisitLogsSinceBeginning = 0 then 0
						else round(countOfAttemptedHomeVisitLogsSinceBeginning / (countOfHomeVisitLogsSinceBeginning * 1.0000), 2) 
					end as pctOfAttemptedHomeVisitLogsSinceBeginning
				/* In Period */
				, countOfHomeVisitLogsInPeriod
				, 1 as pctOfHomeVisitLogsInPeriod
				/* Completed */
				, countOfCompletedHomeVisitLogsInPeriod
				, case when countOfHomeVisitLogsInPeriod is null or countOfHomeVisitLogsInPeriod = 0 then 0
						else round(countOfCompletedHomeVisitLogsInPeriod / (countOfHomeVisitLogsInPeriod * 1.0000), 2) 
					end as pctOfCompletedHomeVisitLogsInPeriod
				/* Attempted */
				, countOfAttemptedHomeVisitLogsInPeriod
				, case when countOfHomeVisitLogsInPeriod is null or countOfHomeVisitLogsInPeriod = 0 then 0
						else round(countOfAttemptedHomeVisitLogsInPeriod / (countOfHomeVisitLogsInPeriod * 1.0000), 2) 
					end as pctOfAttemptedHomeVisitLogsInPeriod

				/* Families with at least one */
				, countOfFamiliesWithAtLeastOneHomeVisitSinceBeginning
				--, 0 as pctOfFamiliesWithAtLeastOneHomeVisitSinceBeginning
				, countOfFamiliesWithAtLeastOneHomeVisitInPeriod
				--, 0 as pctOfFamiliesWithAtLeastOneHomeVisitInPeriod
				
				/* At least one with OBP or father/father figure */
				, countOfFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherSinceBeginning
				--, 0 as pctOfFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherSinceBeginning
				/* ('+replace(convert(varchar(20), cast(round(countOfFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherSinceBeginning / 
																(countOfFamiliesWithAtLeastOneHomeVisitSinceBeginning * 1.0000) * 100, 0) 
														as money)), '.00', '') + '%)' as pctOfFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherSinceBeginning */
				, countOfFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherInPeriod
				--, 0 as pctOfFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherInPeriod
		from cteScreensCompletedSinceBeginning
		inner join cteScreensCompletedInPeriod on 1=1
		inner join ctePositiveScreensSinceBeginning on 1=1
		inner join cteNegativeScreensSinceBeginning on 1=1
		inner join ctePositiveScreensInPeriod on 1=1
		inner join cteNegativeScreensInPeriod on 1=1
		inner join cteKempesCompletedSinceBeginning on 1=1
		inner join cteKempesCompletedInPeriod on 1=1

		inner join ctePreintakeHomeVisitInPeriod on 1=1
		inner join ctePreintakeHomeVisitSinceBeginning on 1=1

		inner join ctePositiveKempesSinceBeginning on 1=1
		inner join cteNegativeKempesSinceBeginning on 1=1
		inner join cteFOBPresentKempesSinceBeginning on 1=1

		inner join ctePositiveKempesInPeriod on 1=1
		inner join cteNegativeKempesInPeriod on 1=1
		inner join cteFOBPresentKempesInPeriod on 1=1

		inner join cteFamiliesEnrolledSinceBeginning on 1=1
		inner join cteFamiliesEnrolledPrenatallySinceBeginning on 1=1
		inner join cteFamiliesEnrolledPostnatallySinceBeginning on 1=1
		inner join cteFamiliesEnrolledInPeriod on 1=1
		inner join cteFamiliesEnrolledPrenatallyInPeriod on 1=1
		inner join cteFamiliesEnrolledPostnatallyInPeriod on 1=1
		inner join cteFamiliesServedSinceBeginning on 1=1
		inner join cteFamiliesServedInPeriod on 1=1
		inner join cteFamiliesEnrolledAtEndOfPeriod on 1=1
		inner join cteTargetChildrenBornSinceBeginning on 1=1
		inner join cteTargetChildrenBornInPeriod on 1=1
		--inner join cteOtherTargetChildrenServedSinceBeginning on 1=1
		inner join cteOtherTargetChildrenServedInPeriod on 1=1
		inner join cteOtherChildrenServedSinceBeginning on 1=1
		inner join cteOtherChildrenServedInPeriod on 1=1
		inner join cteHomeVisitLogsSinceBeginning on 1=1
		inner join cteCompletedHomeVisitLogsSinceBeginning on 1=1
		inner join cteAttemptedHomeVisitLogsSinceBeginning on 1=1
		inner join cteHomeVisitLogsInPeriod on 1=1
		inner join cteCompletedHomeVisitLogsInPeriod on 1=1
		inner join cteAttemptedHomeVisitLogsInPeriod on 1=1
		inner join cteFamiliesWithAtLeastOneHomeVisitSinceBeginning on 1=1
		inner join cteFamiliesWithAtLeastOneHomeVisitInPeriod on 1=1
		inner join cteFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherSinceBeginning on 1=1
		inner join cteFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherInPeriod on 1=1
	)

	select countOfScreensCompletedSinceBeginning
		 , pctOfScreensCompletedSinceBeginning
		 , countOfScreensCompletedInPeriod
		 , pctOfScreensCompletedInPeriod
		 , countOfPositiveScreensSinceBeginning
		 , pctOfPositiveScreensSinceBeginning
		 , countOfNegativeScreensSinceBeginning
		 , pctOfNegativeScreensSinceBeginning
		 , countOfPositiveScreensInPeriod
		 , pctOfPositiveScreensInPeriod
		 , countOfNegativeScreensInPeriod
		 , pctOfNegativeScreensInPeriod
		 , countOfKempesCompletedSinceBeginning
		 , pctOfKempesCompletedSinceBeginning
		 , countOfKempesCompletedInPeriod
		 , pctOfKempesCompletedInPeriod
		 , countOfPositiveKempesSinceBeginning
		 , pctOfPositiveKempesSinceBeginning
		 , countOfPositiveKempesInPeriod
		 , pctOfPositiveKempesInPeriod
		 , countOfNegativeKempesSinceBeginning
		 , pctOfNegativeKempesSinceBeginning
		 , countOfNegativeKempesInPeriod
		 , pctOfNegativeKempesInPeriod
		 , countOfFOBPresentKempesSinceBeginning
		 , pctOfFOBPresentKempesSinceBeginning
		 , countOfFOBPresentKempesInPeriod
		 , pctOfFOBPresentKempesInPeriod
		 , countOfPreintakeHomeVisitInPeriod
		 , countOfPreintakeHomeVisitSinceBeginning
		 , countOfFamiliesEnrolledSinceBeginning
		 , pctOfFamiliesEnrolledSinceBeginning
		 , countOfFamiliesEnrolledPrenatallySinceBeginning
		 , pctOfFamiliesEnrolledPrenatallySinceBeginning
		 , countOfFamiliesEnrolledPostnatallySinceBeginning
		 , pctOfFamiliesEnrolledPostnatallySinceBeginning
		 , countOfFamiliesEnrolledInPeriod
		 , pctOfFamiliesEnrolledInPeriod
		 , countOfFamiliesEnrolledPrenatallyInPeriod
		 , pctOfFamiliesEnrolledPrenatallyInPeriod
		 , countOfFamiliesEnrolledPostnatallyInPeriod
		 , pctOfFamiliesEnrolledPostnatallyInPeriod
		 , countOfFamiliesServedSinceBeginning
		 , countOfFamiliesServedInPeriod
		 , countOfFamiliesEnrolledAtEndOfPeriod
		 , countOfTargetChildrenBornSinceBeginning
		 , countOfTargetChildrenBornInPeriod
		 , countOfOtherTargetChildrenServedSinceBeginning
		 , countOfOtherTargetChildrenServedInPeriod
		 , countOfOtherChildrenServedSinceBeginning
		 , countOfOtherChildrenServedInPeriod
		 , countOfHomeVisitLogsSinceBeginning
		 , pctOfHomeVisitLogsSinceBeginning
		 , countOfCompletedHomeVisitLogsSinceBeginning
		 , pctOfCompletedHomeVisitLogsSinceBeginning
		 , countOfAttemptedHomeVisitLogsSinceBeginning
		 , pctOfAttemptedHomeVisitLogsSinceBeginning
		 , countOfHomeVisitLogsInPeriod
		 , pctOfHomeVisitLogsInPeriod
		 , countOfCompletedHomeVisitLogsInPeriod
		 , pctOfCompletedHomeVisitLogsInPeriod
		 , countOfAttemptedHomeVisitLogsInPeriod
		 , pctOfAttemptedHomeVisitLogsInPeriod
		 , countOfFamiliesWithAtLeastOneHomeVisitSinceBeginning
		 --, pctOfFamiliesWithAtLeastOneHomeVisitSinceBeginning
		 , countOfFamiliesWithAtLeastOneHomeVisitInPeriod
		 --, pctOfFamiliesWithAtLeastOneHomeVisitInPeriod
		 , countOfFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherSinceBeginning
		 --, pctOfFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherSinceBeginning
		 , countOfFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherInPeriod
		 --, pctOfFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherInPeriod 
	from cteFinal

end

/*
	exec Data-Request-From-OCFS
*/
/*
FW: data request

At some point, could you check my numbers. Bernadette doesnt need this until the tenth.
Here are my numbers and my code:
Served:5600
Tcs:5009
Otherchild:2545

<snip>
------
For 10/1/2012-9/30/2013 can I have:
 
number of families served
number of target children
and number of other children in the household who received services.
I need this data by Friday  January 10th, 2014.
 
Thanks!
Bernadette
*/

/*
SELECT count(HVCasePK) 
		--,[HVCasePK]
		--,[CaseProgress]
		--,[Confidentiality]
		--,[CPFK]
		--,[DateOBPAdded]
		--,[EDC]
		--,[FFFK]
		--,[FirstChildDOB]
		--,[FirstPrenatalCareVisit]
		--,[FirstPrenatalCareVisitUnknown]
		--,[HVCaseCreateDate]
		--,[HVCaseCreator]
		--,[HVCaseEditDate]
		--,[HVCaseEditor]
		--,[InitialZip]
		--,[IntakeDate]
		--,[IntakeLevel]
		--,[IntakeWorkerFK]
		--,[KempeDate]
		--,[OBPInformationAvailable]
		--,[OBPFK]
		--,[OBPinHomeIntake]
		--,[OBPRelation2TC]
		--,[PC1FK]
		--,[PC1Relation2TC]
		--,[PC1Relation2TCSpecify]
		--,[PC2FK]
		--,[PC2inHomeIntake]
		--,[PC2Relation2TC]
		--,[PC2Relation2TCSpecify]
		--,[PrenatalCheckupsB4]
		--,[ScreenDate]
		--,t.TCDOB
		--,[TCNumber]
		--,oc.LivingArrangement
  FROM HVCase
  inner join CaseProgram cp on cp.HVCaseFK = HVCase.HVCasePK
  inner join TCID T on T.HVCaseFK = HVCase.HVCasePK
  --inner join OtherChild oc on oc.HVCaseFK = HVCase.HVCasePK
  where IntakeDate<='09/30/13' and (DischargeDate is null or DischargeDate>='10/01/12')
  --and T.TCDOB<='09/30/13'
  --and oc.LivingArrangement='01'
*/
--use HFNY
--go

--declare @StartDate datetime
--declare @EndDate datetime
--declare @ProgramFKs varchar(200)

--set @StartDate = '20130101'
--set @EndDate = '20131231'
--set @ProgramFKs = '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39';

--select convert(varchar(12), @StartDate, 101) as StartDate
--		, convert(varchar(12), @EndDate, 101) as EndDate;
GO
