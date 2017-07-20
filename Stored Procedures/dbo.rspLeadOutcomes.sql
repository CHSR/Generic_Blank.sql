SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jrobohn
-- Create date: 03Apr2013
-- Description:	Runs the lead assessment/screening outcomes report (mainly of interest to Clinton county)
-- rspLeadOutcomes 6, '20130101', '20130331'
-- =============================================
CREATE procedure [dbo].[rspLeadOutcomes]
(
    @ProgramFK int, 
    @StartDate  datetime,
    @EndDate    datetime
)

as
begin

	;

	with cteLeadAssessments as 
		(select PC1ID
				, rtrim(PCFirstName) + ' ' + rtrim(PCLastName) as PC1Name
				, rtrim(TCFirstName) + ' ' + rtrim(TCLastName) as TCName
				, t.TCDOB
				, cast(FollowUpDate as date) as FollowUpDate
				, case when LeadAssessment = '0' then 'Negative' when LeadAssessment = '1' then 'Positive' else 'Blank' end as LeadAssessOutcome
		from FollowUp fu
		inner join CommonAttributes ca on ca.HVCaseFK = fu.HVCaseFK and FollowUpPK = FormFK and FormType='FU'
		inner join CaseProgram cp on cp.HVCaseFK = fu.HVCaseFK
		inner join TCID t on fu.HVCaseFK = t.HVCaseFK
		inner join HVCase h on h.HVCasePK = cp.HVCaseFK
		inner join PC p on p.PCPK = h.PC1FK
		where fu.ProgramFK = @ProgramFK 
				and FollowUpDate between @StartDate and @EndDate
		),
	cteLeadScreenings as 
		(select PC1ID
				, rtrim(PCFirstName) + ' ' + rtrim(PCLastName) as PC1Name
				, rtrim(TCFirstName) + ' ' + rtrim(TCLastName) as TCName
				, t.TCDOB
				, cast(TCItemDate as date) as TCItemDate
				, case when LeadLevelCode = '01' then 'Negative' when LeadLevelCode = '02' then 'Positive' else 'Unknown' end as LeadScreenOutcome
		from TCMedical tcm
		inner join CaseProgram cp on cp.HVCaseFK = tcm.HVCaseFK
		inner join TCID T on T.TCIDPK = tcm.TCIDFK
		inner join HVCase h on h.HVCasePK = cp.HVCaseFK
		inner join PC p on p.PCPK = h.PC1FK
		where tcm.ProgramFK = @ProgramFK 
				and TCItemDate between @StartDate and @EndDate
				and TCMedicalItem = (select MedicalItemCode from codeMedicalItem where MedicalItemText = 'Lead Screening')
		)		
	select isnull(la.PC1ID, ls.PC1ID) as PC1ID
			, isnull(la.PC1Name, ls.PC1Name) as PC1Name
			, isnull(la.TCName, ls.TCName) as TCName
			, isnull(la.TCDOB, ls.TCDOB) as TCDOB
			, FollowUpDate as LeadAssessDate
			, LeadAssessOutcome
			, TCItemDate as LeadScreenDate
			, LeadScreenOutcome
	from cteLeadAssessments la
	full outer join cteLeadScreenings ls on la.PC1ID = ls.PC1ID
	order by PC1ID

end
GO
