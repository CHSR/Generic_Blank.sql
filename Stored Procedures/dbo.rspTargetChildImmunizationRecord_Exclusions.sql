SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <copied from FamSys - see header below>
-- =============================================
CREATE procedure [dbo].[rspTargetChildImmunizationRecord_Exclusions]
(
    @programfk varchar(max)    = null,
    @rdate     datetime
)
as
	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

	---- TCMedical
	select distinct pc1id
				   ,rtrim(tcfirstname)+' '+rtrim(tclastname) TargetChild
				   ,hvcase.tcdob
				   ,nOiMMUNIZATION
		from caseprogram
			inner join hvcase on hvcasepk = caseprogram.hvcasefk
			inner join tcid on tcid.hvcasefk = hvcasepk and tcid.programfk = caseprogram.programfk
			--inner join TCMedical on TCMedical.hvcasefk = hvcasepk and TCMedical.programfk = caseprogram.programfk and TCMedical.TCIDFK = TCID.TCIDPK and @rdate >= TCItemDate
			--inner join codeMedicalItem cmi on MedicalItemCode = TCMedical.TCMedicalItem and MedicalItemCode <= 13
			inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			inner join (select hvcasefk
							  ,programfk
							  ,max(HVlevelpk) HVlevelpk
							from HVLevelDetail
								inner join dbo.SplitString(@programfk,',') on programfk = listitem
							where StartLevelDate <= @rdate
							group by hvcasefk
									,programfk) hl2 on hvcasepk = hl2.hvcasefk and caseprogram.programfk = hl2.programfk
			inner join HVLevelDetail hl1 on hl2.HVlevelpk = hl1.HVlevelpk
		where (hvcase.tcdob is not null
			 and hvcase.tcdob <= dateadd(dd,-30.44,@rdate)) -- caseprogress >= 11
			 and intakedate <= @rdate
			 and (dischargedate is null
			 or dischargedate > @rdate)
			 and (TCID.NoImmunization <> 0
			 and TCID.NoImmunization is not null)
			 and levelname <> 'Level X'
		order by pc1id
				,TargetChild
				,hvcase.TCDOB
GO
