SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<jrobohn>
-- Create date: 2011?? from famsys
-- Description:	gets listing of current medical providers/facilities for PC1s/TCs for currently enrolled cases
-- Edited on 05/28/2014 - HW936, put in ISNULL around medical provider names to fix issue where only a first/last name is entered
-- exec rspMedicalProviderListing '27', '20130101', '20131231', null
-- =============================================
CREATE procedure [dbo].[rspMedicalProviderListing](@programfk varchar(max)    = null,
                                                  @sdate     datetime,
                                                  @edate     datetime,
                                                  @workerfk  int             = null
                                                  )

as

	if @programfk is null
	begin
		select @programfk =
			   substring((select ',' + LTRIM(RTRIM(STR(HVProgramPK)))
							  from HVProgram
							  for xml path ('')), 2, 8000)
	end

	set @programfk = REPLACE(@programfk, '"', '');
	
	with cteChangeFormMedicalInfo as
		(select pc1id
				, ca.HVCaseFK
				, FormDate
				, isnull(pc1mp.mpfirstname, '') + ' ' + isnull(pc1mp.mplastname, '') as PC1MedicalProvider
				, isnull(tcmp.mpfirstname, '') + ' ' + isnull(tcmp.mplastname, '') as TCMedicalProvider
				, pc1mf.mfname as PC1MedicalFacility
				, tcmf.mfname as TCMedicalFacility
			from CommonAttributes ca
			inner join CaseProgram cp on cp.hvcasefk = ca.hvcasefk
			inner join HVCase c on c.HVCasePK = cp.HVCaseFK 
			inner join dbo.SplitString(@programfk, ',') on cp.programfk = listitem
			left join listMedicalProvider pc1mp 
					on pc1mp.listmedicalproviderpk = ca.pc1medicalproviderfk
			left join listMedicalProvider tcmp 
					on tcmp.listmedicalproviderpk = ca.tcmedicalproviderfk
			left join listMedicalFacility pc1mf 
					on pc1mf.listmedicalfacilitypk = ca.pc1medicalfacilityfk
			left join listMedicalFacility tcmf 
					on tcmf.listmedicalfacilitypk = ca.tcmedicalfacilityfk
			where convert(datetime,FormDate,112)+CommonAttributesPK in 
					(select CAMatchingKey=max(convert(datetime,FormDate,112)+CommonAttributesPK)
						from CommonAttributes cainner
						where cainner.hvcasefk=ca.hvcasefk 
								and formtype='CH' 
								and (CommonAttributesCreator <> 'HFNYConv' or CommonAttributesEditor is not null))
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
			inner join dbo.SplitString(@programfk, ',') on cp.programfk = listitem
			inner join HVCase c on c.HVCasePK = cp.HVCaseFK 
			left join listMedicalProvider pc1mp 
					on pc1mp.listmedicalproviderpk = ca.pc1medicalproviderfk
			left join listMedicalFacility pc1mf 
					on pc1mf.listmedicalfacilitypk = ca.pc1medicalfacilityfk
			where convert(datetime,FormDate,112)+CommonAttributesPK in 
						(select CAMatchingKey=max(convert(datetime,FormDate,112)+CommonAttributesPK)
							from CommonAttributes cainner
							where cainner.hvcasefk=ca.hvcasefk 
									and formtype='FU')
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
				, isnull(tcmp.mpfirstname, '') + ' ' + isnull(tcmp.mplastname,'') as TCMedicalProvider
				, tcmf.mfname as TCMedicalFacility
			from commonattributes ca
			inner join caseprogram cp on cp.hvcasefk = ca.hvcasefk
			inner join HVCase c on c.HVCasePK = cp.HVCaseFK 
			inner join dbo.SplitString(@programfk, ',') on cp.programfk = listitem
			left join listMedicalProvider tcmp 
					on tcmp.listmedicalproviderpk = ca.tcmedicalproviderfk
			left join listMedicalFacility tcmf 
					on tcmf.listmedicalfacilitypk = ca.tcmedicalfacilityfk
			where convert(datetime,FormDate,112)+CommonAttributesPK in 
						(select CAMatchingKey=max(convert(datetime,FormDate,112)+CommonAttributesPK)
							from CommonAttributes cainner
							where cainner.hvcasefk=ca.hvcasefk 
									and formtype='FU')
						and intakedate <= @edate 
						and (dischargedate is null
							   or dischargedate > @edate)
						and currentfswfk = isnull(@workerfk, currentfswfk))
	,
	cteIntakePC1MedicalInfo as 
		  (select pc1id
				, ca.HVCaseFK
				, FormDate
				, pc1hasmedicalprovider
				, isnull(pc1mp.mpfirstname, '') + ' ' + isnull(pc1mp.mplastname, '') as PC1MedicalProvider
				, pc1mf.mfname as PC1MedicalFacility
			from commonattributes ca
			inner join intake on intakepk = formfk
						and formdate = intake.intakedate
						and formtype = 'IN'
			inner join caseprogram on caseprogram.hvcasefk = ca.hvcasefk
						and caseprogram.programfk = ca.programfk
			inner join HVCase c on c.HVCasePK = caseprogram.HVCaseFK 
			inner join dbo.SplitString(@programfk, ',') on caseprogram.programfk = listitem
			left join listMedicalProvider pc1mp 
					on pc1mp.listmedicalproviderpk = ca.pc1medicalproviderfk
			left join listMedicalFacility pc1mf 
					on pc1mf.listmedicalfacilitypk = ca.pc1medicalfacilityfk
			where intake.intakedate <= @edate 
					and (dischargedate is null
						   or dischargedate > @edate)
					and currentfswfk = isnull(@workerfk, currentfswfk))
	, 
	cteTCIDMedicalInfo as 
		  (select pc1id
				, ca.HVCaseFK
				, FormDate
				, tchasmedicalprovider
				, isnull(tcmp.mpfirstname, '') + ' ' + isnull(tcmp.mplastname, '') as TCMedicalProvider
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
			   and currentfswfk = isnull(@workerfk, currentfswfk))
select cp.pc1id
--		GetMedicalProviderFacility(@ChangeFormDate datetime
--								, @ChangeFormProviderFacility varchar(210)
--								, @FollowUpDate datetime
--								, @FollowUpInterval varchar(2)
--								, @FollowUpHasProviderFacility char(1)
--								, @IntakeHasProviderFacility char(1)
--								, @IntakeProviderFacility varchar(210)
--								, @ProviderFacility bit
--								, @TCFlag bit
--								, @TCIDFormDate datetime
		, -- determine the PC1MedicalProvider
		dbo.GetMedicalProviderFacility(ch.FormDate
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
		dbo.GetMedicalProviderFacility(ch.FormDate
									, ch.PC1MedicalFacility
									, fupc1.FormDate
									, fupc1.FormInterval
									, fupc1.PC1HasMedicalProvider
									, inpc1.PC1HasMedicalProvider
									, inpc1.PC1MedicalFacility
									, 0
									, null
									, null)
		as PC1MedicalFacility
		, -- determine the TCMedicalProvider
		dbo.GetMedicalProviderFacility(ch.FormDate
									, ch.TCMedicalProvider
									, futc.FormDate
									, futc.FormInterval
									, futc.TCHasMedicalProvider
									, tc.TCHasMedicalProvider
									, tc.TCMedicalProvider
									, 1
									, 1
									, tc.FormDate)
		as TCMedicalProvider
		, -- determine the TCMedicalFacility
		dbo.GetMedicalProviderFacility(ch.FormDate
									, ch.TCMedicalFacility
									, futc.FormDate
									, futc.FormInterval
									, futc.TCHasMedicalProvider
									, tc.TCHasMedicalProvider
									, tc.TCMedicalFacility
									, 0
									, 1
									, tc.FormDate)
		as TCMedicalFacility
from CaseProgram cp 
inner join HVCase c ON cp.HVCaseFK = c.HVCasePK
inner join dbo.SplitString(@programfk, ',') on cp.programfk = listitem
left join cteChangeFormMedicalInfo ch on ch.HVCaseFK = cp.HVCaseFK
left join cteFollowUpPC1MedicalInfo fupc1 on fupc1.HVCaseFK = cp.HVCaseFK
left join cteFollowUpTCMedicalInfo futc on futc.HVCaseFK = cp.HVCaseFK
left join cteIntakePC1MedicalInfo inpc1 on inpc1.HVCaseFK = cp.HVCaseFK
left join cteTCIDMedicalInfo tc on tc.HVCaseFK = cp.HVCaseFK
--left join listmedicalprovider pc1mp on pc1mp.listmedicalproviderpk = pc1.pc1medicalproviderfk
--left join listmedicalprovider tcmp on tcmp.listmedicalproviderpk = tc.tcmedicalproviderfk
--left join listmedicalfacility pc1mf on pc1mf.listmedicalfacilitypk = pc1.pc1medicalfacilityfk
--left join listmedicalfacility tcmf on tcmf.listmedicalfacilitypk = tc.tcmedicalfacilityfk
where IntakeDate <= @edate
		and (dischargedate is null
			or dischargedate > @edate)
		and currentfswfk = isnull(@workerfk, currentfswfk)
order by cp.pc1id
GO
