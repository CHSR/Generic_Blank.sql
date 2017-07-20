SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 05/27/2011
-- Description:	Returns pc1id and PCMedicalProvider
--              Using for DCF Report #8
-- Copied from FamSys 02-11-12 jrobohn - not sure if we will need this, but we probably will
-- =============================================
CREATE FUNCTION [dbo].[MedicalProvider]
(
	-- Add the parameters for the function here
	@programfk varchar(max) = null,
	@sdate datetime, 
	@edate datetime,
	@workerfk as int
)
RETURNS TABLE 
AS
RETURN 
(
		
	with cteChangeFormMedicalInfo as
		(select pc1id
				, ca.HVCaseFK
				, FormDate
				, pc1mp.mpfirstname + ' ' + pc1mp.mplastname as PC1MedicalProvider
				, IsNull(tcmp.mpfirstname, '') + ' ' + tcmp.mplastname as TCMedicalProvider
				, pc1mf.mfname as PC1MedicalFacility
				, tcmf.mfname as TCMedicalFacility
			from CommonAttributes ca
			inner join CaseProgram cp on cp.hvcasefk = ca.hvcasefk
			inner join HVCase c on c.HVCasePK = cp.HVCaseFK 
			left join listMedicalProvider pc1mp 
					on pc1mp.listmedicalproviderpk = ca.pc1medicalproviderfk
			left join listMedicalProvider tcmp 
					on tcmp.listmedicalproviderpk = ca.tcmedicalproviderfk
			left join listMedicalFacility pc1mf 
					on pc1mf.listmedicalfacilitypk = ca.pc1medicalfacilityfk
			left join listMedicalFacility tcmf 
					on tcmf.listmedicalfacilitypk = ca.tcmedicalfacilityfk
			where cp.programfk = @programfk 
			AND		convert(datetime,FormDate,112)+CommonAttributesPK in 
					(select CAMatchingKey=max(convert(datetime,FormDate,112)+CommonAttributesPK)
						from CommonAttributes cainner
						where cainner.hvcasefk=ca.hvcasefk 
								and formtype='CH' 
								and (CommonAttributesCreator <> 'HFNYConv' OR CommonAttributesEditor IS Not Null ))
					and intakedate <= @edate 
					and (dischargedate is null
						   or dischargedate > @edate)
					and currentfswfk = isnull(@workerfk, currentfswfk))
	,
	cteFollowUpPC1MedicalInfo as 
		(select pc1id
				, ca.HVCaseFK
				, FormInterval
				, FormDate
				, pc1hasmedicalprovider
				, pc1mp.mpfirstname + ' ' + pc1mp.mplastname as PC1MedicalProvider
				, pc1mf.mfname as PC1MedicalFacility
			from commonattributes ca
			inner join caseprogram cp on cp.hvcasefk = ca.hvcasefk
			inner join HVCase c on c.HVCasePK = cp.HVCaseFK 
			left join listMedicalProvider pc1mp 
					on pc1mp.listmedicalproviderpk = ca.pc1medicalproviderfk
			left join listMedicalFacility pc1mf 
					on pc1mf.listmedicalfacilitypk = ca.pc1medicalfacilityfk
			where	cp.programfk = @programfk 
			AND convert(datetime,FormDate,112)+CommonAttributesPK in 
						(select CAMatchingKey=max(convert(datetime,FormDate,112)+CommonAttributesPK)
							from CommonAttributes cainner
							where cainner.hvcasefk=ca.hvcasefk 
									and formtype='FU-PC1')
					and intakedate <= @edate 
					and (dischargedate is null
						   or dischargedate > @edate)
					and currentfswfk = isnull(@workerfk, currentfswfk))
	,
	cteFollowUpTCMedicalInfo as 
		(SELECT pc1id
				, ca.HVCaseFK
				, FormInterval
				, FormDate
				, tchasmedicalprovider
				, IsNull(tcmp.mpfirstname, '') + ' ' + tcmp.mplastname as TCMedicalProvider
				, tcmf.mfname as TCMedicalFacility
			from commonattributes ca
			inner join caseprogram cp on cp.hvcasefk = ca.hvcasefk
			inner join HVCase c on c.HVCasePK = cp.HVCaseFK 
			left join listMedicalProvider tcmp 
					on tcmp.listmedicalproviderpk = ca.tcmedicalproviderfk
			left join listMedicalFacility tcmf 
					on tcmf.listmedicalfacilitypk = ca.tcmedicalfacilityfk
			where 	cp.programfk = @programfk 
			AND convert(datetime,FormDate,112)+CommonAttributesPK in 
						(select CAMatchingKey=max(convert(datetime,FormDate,112)+CommonAttributesPK)
							from CommonAttributes cainner
							where cainner.hvcasefk=ca.hvcasefk 
									and formtype='FU')
						and intakedate <= @edate 
						and (dischargedate is null
							   or dischargedate > @edate)
						and currentfswfk = isnull(@workerfk, currentfswfk))
	,	
	cteTCIDMedicalInfo as 
		  (select pc1id
				, ca.HVCaseFK
				, FormDate
				, tchasmedicalprovider
				, IsNull(tcmp.mpfirstname, '') + ' ' + tcmp.mplastname as TCMedicalProvider
				, tcmf.mfname as TCMedicalFacility
			from commonattributes ca
			inner join tcid on tcidpk = formfk
					and formtype = 'TC'
			inner join caseprogram on caseprogram.hvcasefk = ca.hvcasefk
					and caseprogram.programfk = ca.programfk
			inner join HVCase c on c.HVCasePK = caseprogram.HVCaseFK 
			inner join dbo.SplitString(@programfk, ',') on caseprogram.programfk = listitem
			left join listMedicalProvider tcmp 
					on tcmp.listmedicalproviderpk = ca.tcmedicalproviderfk
			left join listMedicalFacility tcmf 
					on tcmf.listmedicalfacilitypk = ca.tcmedicalfacilityfk
			where intakedate <= @edate
				and (dischargedate is null
			   or dischargedate > @edate)
			   and currentfswfk = isnull(@workerfk, currentfswfk)),
	cteIntakePC1MedicalInfo as 
		  (select pc1id
				, ca.HVCaseFK
				, FormDate
				, pc1hasmedicalprovider
				, pc1mp.mpfirstname + ' ' + pc1mp.mplastname as PC1MedicalProvider
				, pc1mf.mfname as PC1MedicalFacility
			from commonattributes ca
			inner join intake on intakepk = formfk
						and formdate = intake.intakedate
						and formtype = 'IN'
			inner join caseprogram on caseprogram.hvcasefk = ca.hvcasefk
						and caseprogram.programfk = ca.programfk
			inner join HVCase c on c.HVCasePK = caseprogram.HVCaseFK 
			left join listMedicalProvider pc1mp 
					on pc1mp.listmedicalproviderpk = ca.pc1medicalproviderfk
			left join listMedicalFacility pc1mf 
					on pc1mf.listmedicalfacilitypk = ca.pc1medicalfacilityfk
			where 	caseprogram.programfk = @programfk 
			AND intake.intakedate <= @edate 
					and (dischargedate is null
						   or dischargedate > @edate)
					and currentfswfk = isnull(@workerfk, currentfswfk))
select cp.pc1id
		, -- determine the PC1MedicalProvider
		dbo.GetMedicalProvORFacility_NoComments(ch.FormDate
									, ch.PC1MedicalProvider
									, fupc1.FormDate
									, fupc1.FormInterval
									, fupc1.PC1HasMedicalProvider
									, inpc1.PC1HasMedicalProvider
									, inpc1.PC1MedicalProvider
									, 1
									, null
									, null)
		as PC1MedicalProvider
		, -- determine the PC1MedicalFacility
		dbo.GetMedicalProvORFacility_NoComments(ch.FormDate
									, ch.PC1MedicalFacility
									, fupc1.FormDate
									, fupc1.FormInterval
									, fupc1.PC1HasMedicalProvider
									, inpc1.PC1HasMedicalProvider
									, inpc1.PC1MedicalFacility
									, 0
									, null
									, null)
		as PC1MedicalFacility,		
		-- determine the TCMedicalProvider
		dbo.GetMedicalProvORFacility_NoComments(ch.FormDate
									, ch.TCMedicalProvider
									, futc.FormDate
									, futc.FormInterval
									, futc.TCHasMedicalProvider
									, tc.TCHasMedicalProvider
									, tc.TCMedicalProvider
									, 1
									, 1
									, tc.FormDate)
		as TCMedicalProvider,
		-- determine the TCMedicalFacility
		dbo.GetMedicalProvORFacility_NoComments(ch.FormDate
									, ch.TCMedicalFacility
									, futc.FormDate
									, futc.FormInterval
									, futc.TCHasMedicalProvider
									, TC.TCHasMedicalProvider
									, TC.TCMedicalFacility
									, 0
									, null
									, null)
		as TCMedicalFacility,	
		cp.hvcasefk
from CaseProgram cp 
inner join HVCase c ON cp.HVCaseFK = c.HVCasePK
left join cteChangeFormMedicalInfo ch on ch.HVCaseFK = cp.HVCaseFK
left join cteFollowUpPC1MedicalInfo fupc1 on fupc1.HVCaseFK = cp.HVCaseFK
left join cteIntakePC1MedicalInfo inpc1 on inpc1.HVCaseFK = cp.HVCaseFK
left join cteFollowUpTCMedicalInfo futc on futc.HVCaseFK = cp.HVCaseFK
left join cteTCIDMedicalInfo tc on tc.HVCaseFK = cp.HVCaseFK
where cp.programfk = @programfk
		and IntakeDate <= @edate
		and (dischargedate is null
			or dischargedate > @edate)
		and currentfswfk = isnull(@workerfk, currentfswfk)

)
GO
