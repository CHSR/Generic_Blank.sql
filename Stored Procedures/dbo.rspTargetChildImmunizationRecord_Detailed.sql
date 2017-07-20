SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <copied from FamSys - see header below>
-- =============================================
CREATE procedure [dbo].[rspTargetChildImmunizationRecord_Detailed]
(
    @programfk    varchar(max)    = null,
    @supervisorfk int             = null,
    @workerfk     int             = null,
    @pc1id        varchar(13)     = null,
    @rdate        datetime
)
as
	if @programfk is null
	begin
		select @programfk = substring((select ','+ltrim(rtrim(str(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = replace(@programfk,'"','')

	---- TCMedical
	select pc1id
			,substring((select distinct ', '+rtrim(tcfirstname)+' '+rtrim(tclastname)
							from tcid
							where hvcasepk = tcid.hvcasefk
								and tcid.programfk = programfk
							for xml path ('')),3,1000) TargetChild
			,TCDOB
			,datediff(M,TCDOB,@rdate) TCAge
			,EventDescription
			,TCItemDate
			,case
				when IsDelayed = 1 then
					'Yes'
				else
					'No'
			end IsDelayed
			,interval
			,ltrim(rtrim(fsw.firstname))+' '+ltrim(rtrim(fsw.lastname)) worker
			,ltrim(rtrim(supervisor.firstname))+' '+ltrim(rtrim(supervisor.lastname)) supervisor
		from (select pc1id
					,hvcase.tcdob
					,hvcase.hvcasepk
					,caseprogram.programfk
					,null as TCItemDate
					,0 IsDelayed
					,EventDescription
					,Interval
					,CurrentFSWFK
				  from caseprogram
					  inner join hvcase on hvcasepk = caseprogram.hvcasefk
					  inner join tcid on tcid.hvcasefk = hvcasepk and tcid.programfk = caseprogram.programfk
					  inner join (select EventDescription
										,Interval
										,DueBy
										,MedicalItemCode
									  from codeduebydates
										  inner join codeMedicalItem cmi on ScheduledEvent = cmi.MedicalItemTitle and MedicalItemCode <= 13) codeduebydates on codeduebydates.interval = datediff(M,dateadd(dd,-30.44,HVCase.TCDOB),@rdate)
					  inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
				  where caseprogress >= 11
					   and intakedate <= @rdate
					   and (dischargedate is null)
					   and (TCID.NoImmunization = 0
					   or TCID.NoImmunization is null)
			  union
			  select pc1id
					,hvcase.tcdob
					,hvcase.hvcasepk
					,caseprogram.programfk
					,TCItemDate
					,IsDelayed
					,MedicalItemTitle
					,datediff(M,dateadd(dd,-30.44,HVCase.TCDOB),TCItemDate) Interval
					,CurrentFSWFK
				  from caseprogram
					  inner join hvcase on hvcasepk = caseprogram.hvcasefk
					  inner join tcid on tcid.hvcasefk = hvcasepk and tcid.programfk = caseprogram.programfk
					  inner join TCMedical on TCMedical.hvcasefk = hvcasepk and TCMedical.programfk = caseprogram.programfk and TCMedical.TCIDFK = TCID.TCIDPK and @rdate >= TCItemDate
					  inner join codeMedicalItem cmi on MedicalItemCode = TCMedical.TCMedicalItem and MedicalItemCode <= 13
					  inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
				  where caseprogress >= 11
					   and intakedate <= @rdate
					   and (dischargedate is null)
					   and (TCID.NoImmunization = 0
					   or TCID.NoImmunization is null)) immunizations
			inner join worker fsw on CurrentFSWFK = fsw.workerpk
			inner join workerprogram on workerprogram.workerfk = fsw.workerpk
			inner join worker supervisor on supervisorfk = supervisor.workerpk
			inner join (select hvcasefk
							  ,programfk
							  ,max(HVlevelpk) HVlevelpk
							from HVLevelDetail
								inner join dbo.SplitString(@programfk,',') on programfk = listitem
							where StartLevelDate <= @rdate
							group by hvcasefk
									,programfk) hl2 on hvcasepk = hl2.hvcasefk and immunizations.programfk = hl2.programfk
			inner join HVLevelDetail hl1 on hl2.HVlevelpk = hl1.HVlevelpk
		where currentFSWFK = isnull(@workerfk,currentFSWFK)
			 and supervisorfk = isnull(@supervisorfk,supervisorfk)
			 and PC1ID = isnull(@pc1id,PC1ID)
			 and levelname <> 'Level X'
		order by PC1ID
				,case when TCItemDate is null then 1 else 0 end
				,EventDescription
				,TCItemDate desc

GO
