SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Object:  StoredProcedure [dbo].[rspDemographics]    Script Date: 10/11/2013 14:27:01 ******/
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
--            added this code to the workerprogram join condition: AND wp.programfk = listitem

CREATE procedure [dbo].[rspDemographics]
(
    @StartDate date,
    @EndDate   date,
    @ProgramFK int,
    @SiteFK    int
)
as
begin
	declare @tblDemographics table(
		GroupBy varchar(64),
		Descript varchar(60),
		Number varchar(10),
		Percentage varchar(10),
		LineType char(1)
	)

	if @ProgramFK is null
	begin
		select @ProgramFK = substring((select ','+ltrim(rtrim(str(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end;

	with cteMain
	as (select HVCasePK
			  ,case
				   when DischargeDate is not null and DischargeDate <> '' and DischargeDate <= @EndDate then
					   DischargeDate
				   else
					   @EndDate
			   end as lastdate
			  ,datediff(year,P.PCDOB,IntakeDate) as AgeAtIntake
			  ,aRace.AppCodeText as Race
			  ,aEducation.AppCodeText as Education
			  ,IntakeDate
			  ,caIntakePC1.IsCurrentlyEmployed as PC1CurrentEmployment
			  ,caIntakePC1.EducationalEnrollment as PC1CurrentEducationalEnrollment
			  ,caIntakePC2.IsCurrentlyEmployed as PC2CurrentEmployment
			  ,caIntakePC2.EducationalEnrollment as PC2CurrentEducationalEnrollment
			  ,caIntakePC1.PBTANF
			  ,caIntakePC1.PBFoodStamps
			  ,caIntakePC1.PC1ReceivingMedicaid
			  ,caIntakePC1.MaritalStatus
			  ,OBPinHomeIntake
			  ,PC2inHomeIntake

			from HVCase c
				inner join CaseProgram cp on cp.HVCaseFK = c.HVCasePK
				inner join PC P on P.PCPK = c.PC1FK
				inner join CommonAttributes caIntakePC1 on caIntakePC1.HVCaseFK = c.HVCasePK and caIntakePC1.FormType = 'IN-PC1'
				inner join dbo.SplitString(@ProgramFK,',') on cp.programfk = listitem
				left outer join CommonAttributes caIntakePC2 on caIntakePC2.HVCaseFK = c.HVCasePK and caIntakePC1.FormType = 'IN-PC2'
				left outer join Worker w on w.WorkerPK = cp.CurrentFSWFK
				left outer join WorkerProgram wp on wp.WorkerFK = w.WorkerPK AND wp.programfk = listitem
				left outer join codeApp aRace on P.Race = aRace.AppCode and aRace.AppCodeGroup = 'Race'
				left outer join codeApp aEducation on caIntakePC1.HighestGrade = aEducation.AppCode and aEducation.AppCodeGroup = 'Education'
			where IntakeDate <= @EndDate
				 and IntakeDate is not null
				 and (DischargeDate >= @StartDate
				 or DischargeDate is null)
				 -- and SiteFK = isnull(@SiteFK,SiteFK)
	),
	cteTCs
	as (select distinct HVCaseFK
					   ,count(T.HVCaseFK) as TCCount
			from TCID T
				inner join cteMain on cteMain.HVCasePK = T.HVCaseFK
			group by HVCaseFK
	),
	cteTCsOnMedicaid
	as (select distinct T.HVCaseFK
					   ,count(T.HVCaseFK) as TCOnMedicaidCount
			from TCID T
				inner join cteMain on cteMain.HVCasePK = T.HVCaseFK
				inner join CommonAttributes caTC on caTC.FormFK = T.TCIDPK
			where caTC.TCReceivingMedicaid = '1'
			group by T.HVCaseFK
	),
	cteFirstTimeMothers
	as (select count(HVCasePK) as FirstTimeMothers
			from cteMain
			where HVCasePK not in (select cteMain.HVCasePK
									   from OtherChild oc
									   where oc.HVCaseFK = cteMain.HVCasePK
											and oc.Relation2PC1 = '01')
	)
	select *
		from cteMain
			inner join cteTCs on cteTCs.HVCaseFK = cteMain.HVCasePK
			inner join cteTCsOnMedicaid on cteTCsOnMedicaid.HVCaseFK = cteMain.HVCasePK

end
GO
