SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 06/12/2012
-- Description:	Closed Enrolled Case List
-- exec rspClosedEnrolledCaseList 1,'20120701','20120731',null 1
-- exec rspClosedEnrolledCaseList_original 1,'20120701','20120731'
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
--            added this code to the workerprogram join condition: AND wp.programfk = listitem
-- =============================================
CREATE procedure [dbo].[rspClosedEnrolledCaseList]-- Add the parameters for the stored procedure here
    @programfk VARCHAR(MAX) = null,
    @StartDt   datetime,
    @EndDt     datetime,
	@WorkerFK  int = NULL,
    @SiteFK    int = 0,
    @CaseFiltersPositive varchar(100) = ''
AS

if @programfk is null
	begin
		select @programfk =
			   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	END
set @programfk = REPLACE(@programfk,'"','')

	--DECLARE @StartDt DATE = '01/01/2011'
	--DECLARE @EndDt DATE = '05/31/2011'
	--DECLARE @programfk INT = 17
	set @SiteFK = isnull(@SiteFK, 0)
	set @CaseFiltersPositive = case	when @CaseFiltersPositive = '' then null
									else @CaseFiltersPositive
							   end;
	
	select rtrim(PC.PCLastName)+cast(PC.PCPK as varchar(10)) [key01]
	      , cp.PC1ID
		  ,rtrim(PC.PCLastName)+', '+rtrim(PC.PCFirstName) [Name]
		  ,convert(varchar(12),PC.PCDOB,101) [DOB]
		  ,PC.SSNo [SSNo]
		  ,convert(varchar(12),Kempe.KempeDate,101) [KemptDate]
		  ,convert(varchar(12),HVScreen.ScreenDate,101) [ScreenDate]
		  ,rtrim(w.LastName)+', '+rtrim(w.FirstName) [FSW]
		  ,convert(varchar(12),Intake.IntakeDate,101) [IntakeDate]
		  ,CAST(DATEDIFF(year,PC.PCDOB,Intake.IntakeDate) as varchar(10))+' y' [AgeAtIntake]
		  ,case when cp.DischargeDate is null then '' else convert(varchar(12),cp.DischargeDate,101) end [CloseDate]
		  ,case when cp.DischargeDate is null then 'Case Open' else rtrim(codeDischarge.DischargeReason) end [CloseReason]
		  
		  --,CAST(DATEDIFF(month,Intake.IntakeDate,@EndDt) as varchar(10))+' m' [LengthInProgram]
		  ,CASE WHEN cp.DischargeDate is NOT NULL THEN CAST(DATEDIFF(month,Intake.IntakeDate,cp.DischargeDate) as varchar(10))+' m' ELSE 
		   CAST(DATEDIFF(month,Intake.IntakeDate,@EndDt) as varchar(10))+' m' END [LengthInProgram]
		  
		  ,case when ca.TANFServices = 1 then 'Yes' else 'No' end [TANF]
		  ,case when ca.FormType = 'IN' then 'Intake' else (select top 1 codeApp.AppCodeText
																from codeApp
																where ca.FormInterval = codeApp.AppCode
																	 and codeApp.AppCodeUsedWhere like '%FU%'
																	 and codeApp.AppCodeGroup = 'TCAge'
														   ) end [TANFServiceAt]
		  ,convert(varchar(12),ca.FormDate,101) [Eligible]
		  ,(select count(*)
				from HVLog
				inner join CaseProgram cp1 on cp1.HVCaseFK = HVLog.HVCaseFK
				join dbo.SplitString(@programfk,',') on cp1.programfk = listitem
				inner join dbo.udfCaseFilters(@casefilterspositive, '', @programfk) cf on cf.HVCaseFK = cp1.HVCaseFK
				inner join WorkerProgram wp1 on wp1.WorkerFK = cp1.CurrentFSWFK AND wp1.programfk = listitem
				where VisitType <> '00010'
					 and cast(VisitStartTime AS DATE) <= @EndDt
					 and cast(VisitStartTime AS DATE) >= c.IntakeDate
					 and HVLog.HVCaseFK = c.HVCasePK
					 --and HVLog.ProgramFK = @programfk
					 and (case when @SiteFK = 0 then 1 when wp1.SiteFK = @SiteFK then 1 else 0 end = 1)) [HomeVisits]
		  -- following fields are used for validating (to be removed)
		  ,(select top 1 ca1.CommonAttributesPK
				from CommonAttributes ca1
				where ca1.HVCaseFK = c.HVCasePK
					 and ca1.FormDate <= @EndDt
					 and ca1.FormType in ('FU','IN')
				order by ca1.FormDate desc
		   ) [CommonAttributesPKID]
		  ,ca.FormDate
		  ,ca.TANFServices
		  ,ca.FormType
		  ,ca.FormInterval
		  ,rtrim(T.TCLastName)+', '+rtrim(T.TCFirstName) [tcName]
		  ,convert(varchar(12),T.TCDOB,101) [tcDOB]

		from CaseProgram cp
		    join dbo.SplitString(@programfk,',') on cp.programfk = listitem
			join HVCase c on cp.HVCaseFK = c.HVCasePK
			-- pc1 name, dob, and SS# =  c.PC1FK <-> PC.PCPK -> PC.PCLastName + PC.PCFirstName, PC.PCDOB, PC.SSNo
			join PC on PC.PCPK = c.PC1FK
			-- screen date = cp.HVCaseFK <-> Kempe.HVCaseFK -> Kempe.KempeDate
			join Kempe on Kempe.HVCaseFK = c.HVCasePK
			-- kempe date = cp.HVCaseFK <-> HVScreen.HVCaseFK -> HVScreen.ScreenDate
			join HVScreen on HVScreen.HVCaseFK = c.HVCasePK
			-- FSW & site = cp.CurrentFSWFK <-> Worker.WorkerPK -> Worker.LastName + Worker.FirstName ?? site ??
			left outer join Worker w on w.WorkerPK = cp.CurrentFSWFK and w.WorkerPK = isnull(@WorkerFK, w.WorkerPK)
			join Workerprogram as wp on wp.WorkerFK = w.WorkerPK AND wp.programfk = @programfk
			-- intake date & age at intake = cp.HVCaseFK <-> Intake.HVCaseFK -> Intake.IntakeDate -> (PCDOB - IntakeDate)
			join Intake on Intake.HVCaseFK = c.HVCasePK
			-- closed date & close reason = cp.DischargeDate, cp.DischargeReason <-> codeDischarge.DischargeCode 
			--                              -> codeDischarge.DischargeReason
			left outer join codeDischarge on cp.DischargeReason = codeDischarge.DischargeCode
			-- length in program = @EndDt - IntakeDate

			-- TANFservices, &  eligible = CA (CommonAttributes) : cp.HVCaseFK <-> CA.HVCaseFK and CA.FormType IN ('FU', 'IN')
			-- , CA.FormDate <= @EndDt and CA.TANFServices = 1 
			-- if CA.FormType = 'IN' then FormInterval = 'In Take' else CA.FormInterval <-> codeApp.AppCode and
			-- codeApp.AppCodeUsedWhere LIKE '%FU%' and AppCodeGroup = 'TCAge' -> codeApp.AppCodeText
			-- CA.FormDate = Eligible date
			-- CA.TANFServices = TANF
			-- ON ca.HVCaseFK =  c.HVCasePK AND ca.FormDate <= @EndDt AND ca.FormType IN ('FU', 'IN')
			left outer join CommonAttributes ca
						   on ca.CommonAttributesPK = (select top 1 CommonAttributesPK
														   from CommonAttributes
														   where HVCaseFK = c.HVCasePK
																and FormDate <= @EndDt
																and FormType in ('FU','IN')
														   order by FormDate desc)

			-- # of actual home visits since intake = cp.HVCaseFK <-> HVLog.HVCaseFK, ProgramFK, 
			-- VisitType <> '0001', VisitStartTime < @EndDt and VisitStartTime >=  c.IntakeDate

			left outer join TCID T on T.HVCaseFK = c.HVCasePK
			inner join dbo.udfCaseFilters(@casefilterspositive, '', @programfk) cf on cf.HVCaseFK = c.HVCasePK

		where cp.DischargeDate between @StartDt and @EndDt
			 --and cp.ProgramFK = @programfk
			 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
		order by [key01]
GO
