SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: Jul/23/2012
-- Description:	Home Visit Log Summary Quarterly
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
-- =============================================
CREATE PROCEDURE [dbo].[rspHomeVisitLogSummaryQuarterly]
    @programfk VARCHAR(MAX) = NULL,
    @StartDt   DATETIME,
    @EndDt     DATETIME,
    @StartDtX    DATETIME,
    @EndDtX     DATETIME,
    @SiteFK	   INT = NULL,
    @casefilterspositive varchar(200)
as

--DECLARE	@programfk int = 4
--DECLARE @StartDt   DATETIME = '09/01/2012'
--DECLARE @EndDt     DATETIME = '11/30/2012'
--DECLARE @SiteFK	   int = null
--DECLARE @casefilterspositive varchar(200) = null
--DECLARE @StartDtX   DATETIME = '09/01/2012'
--DECLARE @EndDtX     DATETIME = '11/30/2012'

if @programfk is null
  begin
	select @programfk = substring((select ','+ltrim(rtrim(str(HVProgramPK)))
									   from HVProgram
									   for xml path ('')),2,8000)
  end
set @programfk = replace(@programfk,'"','')

	--declare @xDate datetime = '07/01/'+str(year(@StartDt))
	--declare @StartDtX datetime = case when @xDate > @StartDt then '07/01/'+str(year(@StartDt)-1) else @xDate end
	--declare @EndDtX datetime = @EndDt

	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end
	set @casefilterspositive = case when @casefilterspositive = '' then null else @casefilterspositive end

	declare @x int = 0
	declare @y int = 0
	declare @OutOfHome int = 0
	select
		  @y = count(*)
		 ,@x = sum(case when substring(a.VisitType,4,1) = '1' then 0 else 1 end)
		 ,@OutOfHome = sum(case when substring(a.VisitType,4,1) != '1' and substring(a.VisitType,5,1) = '1' then 1 else 0 end)
		from HVLog as a
			join CaseProgram as b on b.HVCaseFK = a.HVCaseFK
			INNER JOIN dbo.SplitString(@programfk,',') on b.programfk = listitem
			inner join WorkerProgram wp on WorkerFK = FSWFK AND wp.programfk = listitem
			inner join dbo.udfCaseFilters(@casefilterspositive,'', @programfk) cf on cf.HVCaseFK = b.HVCaseFK
		where 
		--b.ProgramFK = @programfk and 
		cast(a.VisitStartTime as date)  between @StartDt and @EndDt --jh fix
		--and (b.DischargeDate is null
		--or b.DischargeDate > @EndDt)
		and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
	if @x = 0
	begin
		set @x = 1
	end
	if @y = 0
	begin
		set @y = 1
	end
	if @OutOfHome = 0
	begin
		set @OutOfHome = 1
	end

	--SELECT @StartDt, @StartDtX
--cast(VisitStartTime as date) 
	declare @xX int = 0
	declare @yX int = 0
	declare @OutOfHomeX int = 0
	select
		  @yX = count(*)
		 ,@xX = sum(case when substring(a.VisitType,4,1) = '1' then 0 else 1 end)
		 ,@OutOfHomeX = sum(case when substring(a.VisitType,4,1) != '1' and substring(a.VisitType,5,1) = '1' then 1 else 0 end)
		from HVLog as a
			join CaseProgram as b on b.HVCaseFK = a.HVCaseFK
			INNER JOIN dbo.SplitString(@programfk,',') on b.programfk = listitem
			inner join WorkerProgram wp on WorkerFK = FSWFK AND wp.programfk = listitem
			inner join dbo.udfCaseFilters(@casefilterspositive,'', @programfk) cf on cf.HVCaseFK = b.HVCaseFK
		where 
		--b.ProgramFK = @programfk and 
		cast(a.VisitStartTime as date)  between @StartDtX and @EndDtX
		--and (b.DischargeDate is null
		--or b.DischargeDate > @EndDtX)
		and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
	if @xX = 0
	begin
		set @xX = 1
	end
	if @yX = 0
	begin
		set @yX = 1
	end
	if @OutOfHomeX = 0
	begin
		set @OutOfHomeX = 1
	end

	;
	with q1
	as
	(
	select
		  sum(case when substring(c.VisitType,4,1) <> '1' then 1 else 0 end) as [n]
		 ,sum(case when substring(c.VisitType,4,1) = '1' then 1 else 0 end) [Attemped]
		 ,avg(case when substring(c.VisitType,4,1) != '1' 
		 then (c.VisitLengthHour * 60 + c.VisitLengthMinute) else null end) [AverageLength]
		 ,str(sum(case when isnull(a.TCDOB,a.EDC) >= cast(c.VisitStartTime as date)  then 1 else 0 end)*100.0/@y,10,0)+'%' [Prenatal]
		 ,str(sum(case when isnull(a.TCDOB,a.EDC) < cast(c.VisitStartTime as date) then 1 else 0 end)*100.0/@y,10,0)+'%' [Postnatal]
		 
		 -- type of visit
		 ,str(sum(case when c.VisitType = '100000' then 1 else 0 end)*100.0/@x,10,0)+'%' [InPC1HomeOnly]
		 ,str(sum(case when c.VisitType = '010000' then 1 else 0 end)*100.0/@x,10,0)+'%' [InFatherFigureOBPHomeOnly]
		 ,str(sum(case when c.VisitType = '100010' then 1 else 0 end)*100.0/@x,10,0)+'%' [InOutOfPC1Home]
		 ,str(sum(case when c.VisitType = '010010' then 1 else 0 end)*100.0/@x,10,0)+'%' [InOutOfFatherFigureOBPHome]
		 ,str(sum(case when SUBSTRING(c.VisitType,1,2) = '11' then 1 else 0 end)*100.0/@x,10,0)+'%' [InBothPC1FatherFigureOBPHome]
		 ,str(sum(case when c.VisitType = '000010' then 1 else 0 end)*100.0/@x,10,0)+'%' [OutOfBothPC1FatherFigureOBPHome]
		 ,str(sum(case when SUBSTRING(c.VisitType,1,2) = '11' and substring(c.VisitType,5,1) = '1' then 1 else 0 end)*100.0/@x,10,0)+'%' [InBothPC1FatherFigureOBPHomeAndOutBoth]
		 -- new type of visit
		 
		 
		 ,str(sum(case when substring(c.VisitType,1,1) = '1' or substring(c.VisitType,2,1) = '1' then 1 else 0 end)
		  *100.0/@x,10,0)+'%' [InParticipantHome]
		 ,str(sum(case when substring(c.VisitType,5,1) = '1' and substring(c.VisitType,1,1) != '1'
				  and substring(c.VisitType,2,1) != '1' then 1 else 0 end)*100.0/@x,10,0)+'%' [OutParticipantHome]
		 ,str(sum(case when (substring(c.VisitType,1,1) = '1' or substring(c.VisitType,2,1) = '1')
				  and substring(c.VisitType,5,1) = '1'
				  then 1 else 0 end)*100.0/@x,10,0)+'%' [InOutParticipantHome]

		 ,sum(case when substring(c.VisitType,4,1) != '1' and substring(c.VisitType,5,1) = '1' then 1 else 0 end) [OutOfHome]
		 ,str(sum(case when substring(c.VisitType,5,1) = '1' and substring(c.VisitLocation,1,1) = '1' then 1 else 0 end)*100.0/
			 @OutOfHome,10,0)+'%' [MedicalProviderOffice]
		 ,str(sum(case when substring(c.VisitType,5,1) = '1' and substring(c.VisitLocation,2,1) = '1' then 1 else 0 end)*100.0/
			 @OutOfHome,10,0)+'%' [OtherProviderOffice]
		 ,str(sum(case when substring(c.VisitType,5,1) = '1' and substring(c.VisitLocation,3,1) = '1' then 1 else 0 end)*100.0/
			 @OutOfHome,10,0)+'%' [HomeVisitOffice]
		 ,str(sum(case when substring(c.VisitType,5,1) = '1' and substring(c.VisitLocation,4,1) = '1' then 1 else 0 end)*100.0/
			 @OutOfHome,10,0)+'%' [Hospital]
		 ,str(sum(case when substring(c.VisitType,5,1) = '1' and substring(c.VisitLocation,5,1) = '1' then 1 else 0 end)*100.0/
			 @OutOfHome,10,0)+'%' [OtherLocation]

		 ,str(sum(case when c.PC1Participated = 1 then 1 else 0 end)*100.0/@x,10,0)+'%' [PC1Participated]
		 ,str(sum(case when c.PC2Participated = 1 then 1 else 0 end)*100.0/@x,10,0)+'%' [PC2Participated]
		 ,str(sum(case when c.OBPParticipated = 1 then 1 else 0 end)*100.0/@x,10,0)+'%' [OBPParticipated]
		 ,str(sum(case when c.FatherFigureParticipated = 1 then 1 else 0 end)*100.0/@x,10,0)+'%' [FatherFigureParticipated]
		 ,str(sum(case when c.TCParticipated = 1 then 1 else 0 end)*100.0/@x,10,0)+'%' [TCParticipated]
		 ,str(sum(case when c.GrandParentParticipated = 1 then 1 else 0 end)*100.0/@x,10,0)+'%' [GrandParentParticipated]
		 ,str(sum(case when c.SiblingParticipated = 1 then 1 else 0 end)*100.0/@x,10,0)+'%' [SiblingParticipated]
		 ,str(sum(case when c.NonPrimaryFSWParticipated = 1 then 1 else 0 end)*100.0/@x,10,0)+'%' [NonPrimaryFSWParticipated]
		 -- new 
		 ,str(sum(case when c.FatherAdvocateParticipated = 1 then 1 else 0 end)*100.0/@x,10,0)+'%' [FatherAdvocateParticipated]
		 ,str(sum(case when c.HVSupervisorParticipated = 1 then 1 else 0 end)*100.0/@x,10,0)+'%' [HVSupervisorParticipated]
		 ,str(sum(case when c.SupervisorObservation = 1 then 1 else 0 end)*100.0/@x,10,0)+'%' [SupervisorObservation]
		 ,str(sum(case when c.OtherParticipated = 1 then 1 else 0 end)*100.0/@x,10,0)+'%' [OtherParticipated]

/*
	.PC1Participated = chkPC1Participated.Checked
	.PC2Participated = chkPC2Participated.Checked
	.OBPParticipated = chkOBPParticipated.Checked
	.FatherFigureParticipated = chkFatherFigureParticipated.Checked	 ' new
	.TCParticipated = chkTCParticipated.Checked
	.GrandParentParticipated = chkGrandParentParticipated.Checked
	.SiblingParticipated = chkSiblingParticipated.Checked
	.NonPrimaryFSWParticipated = chkNonPrimaryFSWParticipated.Checked	 ' new
	
	.FatherAdvocateParticipated = chkFatherAdvocateParticipated.Checked	 ' new
	.HVSupervisorParticipated = chkHVSupervisorParticipated.Checked
	.SupervisorObservation = chkSupervisorObservation.Checked
	.OtherParticipated = chkOtherParticipated.Checked
*/



		 ,str(sum(case when (isnull(c.CDChildDevelopment,0) = 0 and isnull(c.CDToys,0) = 0
				  and isnull(c.CDOther,0) = 0) or substring(c.VisitType,4,1) = '1'
				  then 0 else 1 end)*100.0/@x,10,0)+'%' [ChildDevelopment]

		 ,str(sum(case when (isnull(c.PCChildInteraction,0) = 0 and isnull(c.PCChildManagement,0) = 0
				  and isnull(c.PCFeelings,0) = 0 and isnull(c.PCStress,0) = 0
				  and isnull(c.PCBasicNeeds,0) = 0 and isnull(c.PCShakenBaby,0) = 0 and isnull(c.PCShakenBabyVideo,
					  0) = 0
				  and isnull(c.PCOther,0) = 0) or substring(c.VisitType,4,1) = '1' then 0 else 1 end)*100.0/@x,10,0)+'%' 
					  [PCInteraction]

		 ,str(sum(case when (isnull(c.HCGeneral,0) = 0 and isnull(c.HCChild,0) = 0 and isnull(c.HCDental,0) = 0
				  and isnull(c.HCFeeding,0) = 0 and isnull(c.HCBreastFeeding,0) = 0
				  and isnull(c.HCNutrition,0) = 0 and isnull(c.HCFamilyPlanning,0) = 0 and isnull(c.HCProviders,0) 
					  = 0
				  and isnull(c.HCFASD,0) = 0 and isnull(c.HCSexEducation,0) = 0
				  and isnull(c.HCPrenatalCare,0) = 0 and isnull(c.HCMedicalAdvocacy,0) = 0 and isnull(c.HCSafety,0) 
					  = 0
				  and isnull(c.HCSmoking,0) = 0 and isnull(c.HCSIDS,0) = 0
				  and isnull(c.HCOther,0) = 0) or substring(c.VisitType,4,1) = '1' then 0 else 1 end)*100.0/@x,10,0)+'%' 
					  [HealthCare]

		 ,str(sum(case when (isnull(c.FFDomesticViolence,0) = 0 and isnull(c.FFFamilyRelations,0) = 0
				  and isnull(c.FFSubstanceAbuse,0) = 0
				  and isnull(c.FFMentalHealth,0) = 0 and isnull(c.FFCommunication,0) = 0
				  and isnull(c.FFOther,0) = 0) or substring(c.VisitType,4,1) = '1'
				  then 0 else 1 end)*100.0/@x,10,0)+'%' [FamilyFunction]

		 ,str(sum(case when (isnull(c.SSCalendar,0) = 0 and isnull(c.SSHousekeeping,0) = 0
				  and isnull(c.SSTransportation,0) = 0 and isnull(c.SSEmployment,0) = 0
				  and isnull(c.SSMoneyManagement,0) = 0 and isnull(c.SSChildCare,0) = 0
				  and isnull(c.SSProblemSolving,0) = 0 and isnull(c.SSEducation,0) = 0 and isnull(c.SSJob,0) = 0
				  and isnull(c.SSOther,0) = 0) or substring(c.VisitType,4,1) = '1'
				  then 0 else 1 end)*100.0/@x,10,0)+'%' [SelfSufficincy]

		 ,str(sum(case when (isnull(c.CIProblems,0) = 0 and isnull(c.CIOther,0) = 0) or substring(c.VisitType,4,1) = 
			 '1'
				  then 0 else 1 end)*100.0/@x,10,0)+'%' [CrisisIntervention]

		 ,str(sum(case when (isnull(c.PAForms,0) = 0 and isnull(c.PAVideo,0) = 0
				  and isnull(c.PAGroups,0) = 0 and isnull(c.PAIFSP,0) = 0
				  and isnull(c.PARecreation,0) = 0 and isnull(c.PAOther,0) = 0
				  ) or substring(c.VisitType,4,1) = '1'
				  then 0 else 1 end)*100.0/@x,10,0)+'%' [ProgramActivity]

		 ,str(sum(case when (isnull(c.CATransportation,0) = 0 and isnull(c.CAGoods,0) = 0 and isnull(c.CALegal,0) = 
			 0
				  and isnull(c.CAHousing,0) = 0
				  and isnull(c.CAAdvocacy,0) = 0 and isnull(c.CATranslation,0) = 0 and isnull(c.CALaborSupport,0) = 
					  0
				  and isnull(c.CAChildSupport,0) = 0
				  and isnull(c.CAParentRights,0) = 0 and isnull(c.CAVisitation,0) = 0 and isnull(c.CAOther,0) = 
					  0)
				  or substring(c.VisitType,4,1) = '1'
				  then 0 else 1 end)*100.0/@x,10,0)+'%' [ConcreteAcivities]

		from HVCase as a
			join CaseProgram as b on b.HVCaseFK = a.HVCasePK
			INNER JOIN dbo.SplitString(@programfk,',') on b.programfk = listitem
			join HVLog as c on a.HVCasePK = c.HVCaseFK
			inner join WorkerProgram wp on WorkerFK = FSWFK AND wp.programfk = listitem
			inner join dbo.udfCaseFilters(@casefilterspositive,'', @programfk) cf on cf.HVCaseFK = a.HVCasePK
		where 
		--b.ProgramFK = @programfk and 
		cast(c.VisitStartTime as date)  between @StartDt and @EndDt
		--and (b.DischargeDate is null
		--or b.DischargeDate > @EndDt)
		and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
	),

	---------------------------------------------------------------------

	q2
	as (

	select
		  sum(case when substring(c.VisitType,4,1) <> '1' then 1 else 0 end) as [nX]
		 ,sum(case when substring(c.VisitType,4,1) = '1' then 1 else 0 end) [AttempedX]
		 ,avg(case when substring(c.VisitType,4,1) != '1' 
		 then (c.VisitLengthHour * 60 + c.VisitLengthMinute) else null end) [AverageLengthX]
		 ,str(sum(case when isnull(a.TCDOB,a.EDC) >= cast(c.VisitStartTime as date) then 1 else 0 end)*100.0/@yX,10,0)+'%' [PrenatalX]
		 ,str(sum(case when isnull(a.TCDOB,a.EDC) < cast(c.VisitStartTime as date) then 1 else 0 end)*100.0/@yX,10,0)+'%' [PostnatalX]

         -- type of visit
		 ,str(sum(case when c.VisitType = '100000' then 1 else 0 end)*100.0/@xX,10,0)+'%' [InPC1HomeOnlyX]
		 ,str(sum(case when c.VisitType = '010000' then 1 else 0 end)*100.0/@xX,10,0)+'%' [InFatherFigureOBPHomeOnlyX]
		 ,str(sum(case when c.VisitType = '100010' then 1 else 0 end)*100.0/@xX,10,0)+'%' [InOutOfPC1HomeX]
		 ,str(sum(case when c.VisitType = '010010' then 1 else 0 end)*100.0/@xX,10,0)+'%' [InOutOfFatherFigureOBPHomeX]
		 ,str(sum(case when SUBSTRING(c.VisitType,1,2) = '11' then 1 else 0 end)*100.0/@xX,10,0)+'%' [InBothPC1FatherFigureOBPHomeX]
		 ,str(sum(case when c.VisitType = '000010' then 1 else 0 end)*100.0/@xX,10,0)+'%' [OutOfBothPC1FatherFigureOBPHomeX]
		 ,str(sum(case when SUBSTRING(c.VisitType,1,2) = '11' and substring(c.VisitType,5,1) = '1' then 1 else 0 end)*100.0/@xX,10,0)+'%' [InBothPC1FatherFigureOBPHomeAndOutBothX]
		 -- new type of visit


		 ,str(sum(case when substring(c.VisitType,1,1) = '1' or substring(c.VisitType,2,1) = '1' then 1 else 0 end)
		  *100.0/@xX,10,0)+'%' [InParticipantHomeX]
		 ,str(sum(case when substring(c.VisitType,5,1) = '1' and substring(c.VisitType,1,1) != '1'
				  and substring(c.VisitType,2,1) != '1' then 1 else 0 end)*100.0/@xX,10,0)+'%' [OutParticipantHomeX]
		 ,str(sum(case when (substring(c.VisitType,1,1) = '1' or substring(c.VisitType,2,1) = '1')
				  and substring(c.VisitType,5,1) = '1'
				  then 1 else 0 end)*100.0/@xX,10,0)+'%' [InOutParticipantHomeX]

		 ,sum(case when substring(c.VisitType,4,1) != '1' and substring(c.VisitType,5,1) = '1' then 1 else 0 end) [OutOfHomeX]
		 ,str(sum(case when substring(c.VisitType,5,1) = '1' and substring(c.VisitLocation,1,1) = '1' then 1 else 0 end)*100.0/
			 @OutOfHomeX,10,0)+'%' [MedicalProviderOfficeX]
		 ,str(sum(case when substring(c.VisitType,5,1) = '1' and substring(c.VisitLocation,2,1) = '1' then 1 else 0 end)*100.0/
			 @OutOfHomeX,10,0)+'%' [OtherProviderOfficeX]
		 ,str(sum(case when substring(c.VisitType,5,1) = '1' and substring(c.VisitLocation,3,1) = '1' then 1 else 0 end)*100.0/
			 @OutOfHomeX,10,0)+'%' [HomeVisitOfficeX]
		 ,str(sum(case when substring(c.VisitType,5,1) = '1' and substring(c.VisitLocation,4,1) = '1' then 1 else 0 end)*100.0/
			 @OutOfHomeX,10,0)+'%' [HospitalX]
		 ,str(sum(case when substring(c.VisitType,5,1) = '1' and substring(c.VisitLocation,5,1) = '1' then 1 else 0 end)*100.0/
			 @OutOfHomeX,10,0)+'%' [OtherLocationX]

		 ,str(sum(case when c.PC1Participated = 1 then 1 else 0 end)*100.0/@xX,10,0)+'%' [PC1ParticipatedX]
		 ,str(sum(case when c.PC2Participated = 1 then 1 else 0 end)*100.0/@xX,10,0)+'%' [PC2ParticipatedX]
		 ,str(sum(case when c.OBPParticipated = 1 then 1 else 0 end)*100.0/@xX,10,0)+'%' [OBPParticipatedX]
		 ,str(sum(case when c.FatherFigureParticipated = 1 then 1 else 0 end)*100.0/@xX,10,0)+'%' [FatherFigureParticipatedX]
		 ,str(sum(case when c.TCParticipated = 1 then 1 else 0 end)*100.0/@xX,10,0)+'%' [TCParticipatedX]
		 ,str(sum(case when c.GrandParentParticipated = 1 then 1 else 0 end)*100.0/@xX,10,0)+'%' [GrandParentParticipatedX]
		 ,str(sum(case when c.SiblingParticipated = 1 then 1 else 0 end)*100.0/@xX,10,0)+'%' [SiblingParticipatedX]
		 ,str(sum(case when c.NonPrimaryFSWParticipated = 1 then 1 else 0 end)*100.0/@xX,10,0)+'%' [NonPrimaryFSWParticipatedX]
		  -- new 
		 ,str(sum(case when c.FatherAdvocateParticipated = 1 then 1 else 0 end)*100.0/@xX,10,0)+'%' [FatherAdvocateParticipatedX]
		 ,str(sum(case when c.HVSupervisorParticipated = 1 then 1 else 0 end)*100.0/@xX,10,0)+'%' [HVSupervisorParticipatedX]
		 ,str(sum(case when c.SupervisorObservation = 1 then 1 else 0 end)*100.0/@xX,10,0)+'%' [SupervisorObservationX]
		 ,str(sum(case when c.OtherParticipated = 1 then 1 else 0 end)*100.0/@xX,10,0)+'%' [OtherParticipatedX]

		 ,str(sum(case when (isnull(c.CDChildDevelopment,0) = 0 and isnull(c.CDToys,0) = 0
				  and isnull(c.CDOther,0) = 0) or substring(c.VisitType,4,1) = '1'
				  then 0 else 1 end)*100.0/@xX,10,0)+'%' [ChildDevelopmentX]

		 ,str(sum(case when (isnull(c.PCChildInteraction,0) = 0 and isnull(c.PCChildManagement,0) = 0
				  and isnull(c.PCFeelings,0) = 0 and isnull(c.PCStress,0) = 0
				  and isnull(c.PCBasicNeeds,0) = 0 and isnull(c.PCShakenBaby,0) = 0 and isnull(c.PCShakenBabyVideo,
					  0) = 0
				  and isnull(c.PCOther,0) = 0) or substring(c.VisitType,4,1) = '1' then 0 else 1 end)*100.0/@xX,10,0)+'%' 
					  [PCInteractionX]

		 ,str(sum(case when (isnull(c.HCGeneral,0) = 0 and isnull(c.HCChild,0) = 0 and isnull(c.HCDental,0) = 0
				  and isnull(c.HCFeeding,0) = 0 and isnull(c.HCBreastFeeding,0) = 0
				  and isnull(c.HCNutrition,0) = 0 and isnull(c.HCFamilyPlanning,0) = 0 and isnull(c.HCProviders,0) 
					  = 0
				  and isnull(c.HCFASD,0) = 0 and isnull(c.HCSexEducation,0) = 0
				  and isnull(c.HCPrenatalCare,0) = 0 and isnull(c.HCMedicalAdvocacy,0) = 0 and isnull(c.HCSafety,0) 
					  = 0
				  and isnull(c.HCSmoking,0) = 0 and isnull(c.HCSIDS,0) = 0
				  and isnull(c.HCOther,0) = 0) or substring(c.VisitType,4,1) = '1' then 0 else 1 end)*100.0/@xX,10,0)+'%' 
					  [HealthCareX]

		 ,str(sum(case when (isnull(c.FFDomesticViolence,0) = 0 and isnull(c.FFFamilyRelations,0) = 0
				  and isnull(c.FFSubstanceAbuse,0) = 0
				  and isnull(c.FFMentalHealth,0) = 0 and isnull(c.FFCommunication,0) = 0
				  and isnull(c.FFOther,0) = 0) or substring(c.VisitType,4,1) = '1'
				  then 0 else 1 end)*100.0/@xX,10,0)+'%' [FamilyFunctionX]

		 ,str(sum(case when (isnull(c.SSCalendar,0) = 0 and isnull(c.SSHousekeeping,0) = 0
				  and isnull(c.SSTransportation,0) = 0 and isnull(c.SSEmployment,0) = 0
				  and isnull(c.SSMoneyManagement,0) = 0 and isnull(c.SSChildCare,0) = 0
				  and isnull(c.SSProblemSolving,0) = 0 and isnull(c.SSEducation,0) = 0 and isnull(c.SSJob,0) = 0
				  and isnull(c.SSOther,0) = 0) or substring(c.VisitType,4,1) = '1'
				  then 0 else 1 end)*100.0/@xX,10,0)+'%' [SelfSufficincyX]

		 ,str(sum(case when (isnull(c.CIProblems,0) = 0 and isnull(c.CIOther,0) = 0) or substring(c.VisitType,4,1) = 
			 '1'
				  then 0 else 1 end)*100.0/@xX,10,0)+'%' [CrisisInterventionX]


		 ,str(sum(case when (isnull(c.PAForms,0) = 0 and isnull(c.PAVideo,0) = 0
				  and isnull(c.PAGroups,0) = 0 and isnull(c.PAIFSP,0) = 0
				  and isnull(c.PARecreation,0) = 0 and isnull(c.PAOther,0) = 0
				  ) or substring(c.VisitType,4,1) = '1'
				  then 0 else 1 end)*100.0/@xX,10,0)+'%' [ProgramActivityX]

		 ,str(sum(case when (isnull(c.CATransportation,0) = 0 and isnull(c.CAGoods,0) = 0 and isnull(c.CALegal,0) = 
			 0
				  and isnull(c.CAHousing,0) = 0
				  and isnull(c.CAAdvocacy,0) = 0 and isnull(c.CATranslation,0) = 0 and isnull(c.CALaborSupport,0) = 
					  0
				  and isnull(c.CAChildSupport,0) = 0
				  and isnull(c.CAParentRights,0) = 0 and isnull(c.CAVisitation,0) = 0 and isnull(c.CAOther,0) = 
					  0)
				  or substring(c.VisitType,4,1) = '1'
				  then 0 else 1 end)*100.0/@xX,10,0)+'%' [ConcreteAcivitiesX]

		from HVCase as a
			join CaseProgram as b on b.HVCaseFK = a.HVCasePK
			INNER JOIN dbo.SplitString(@programfk,',') on b.programfk = listitem
			join HVLog as c on a.HVCasePK = c.HVCaseFK
			inner join WorkerProgram wp on WorkerFK = FSWFK AND wp.programfk = listitem
			inner join dbo.udfCaseFilters(@casefilterspositive,'', @programfk) cf on cf.HVCaseFK = a.HVCasePK
		where 
		--b.ProgramFK = @programfk and 
		cast(c.VisitStartTime as date)  between @StartDtX and @EndDtX
		--and (b.DischargeDate is null
		--or b.DischargeDate > @EndDtX)
		and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
	)

	select *
		from q1
			join q2 on 1 = 1

GO
