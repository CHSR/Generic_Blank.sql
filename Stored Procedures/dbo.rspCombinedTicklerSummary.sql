SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Feb 5, 2012>
-- Description:	<report: Combined Tickler Summary>
--				Moved from FamSys - 02/05/12 jrobohn
-- exec dbo.rspCombinedTicklerSummary @programfk='1',@rdate='2013-03-01 00:00:00',@supervisorfk=NULL,@workerfk=79
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
--            added this code to the workerprogram join condition: AND wp.programfk = listitem

-- added tcdob - missing from the combined FUP report ... Khalsa
-- =============================================
CREATE procedure [dbo].[rspCombinedTicklerSummary]
(
    @programfk    varchar(max)    = null,
    @rdate        datetime,
    @supervisorfk int             = null,
    @workerfk     int             = null
)
as
	if @programfk is null
	begin
		select @programfk = substring((select ','+ltrim(rtrim(str(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = replace(@programfk,'"','')

	DECLARE @tblASQTicklerCohort TABLE(
		HVCasePK INT,
		LevelName varchar(50) NOT NULL,
		[PC1ID] [char](13) NOT NULL,
		pc1name varchar(200) NOT NULL,
		[tcdob] [datetime] NULL,
		[GestationalAge] INT,
		[EventDescription] varchar(50) NULL,
		[DueDate] [datetime] NULL,
		[TargetChild] VARCHAR(200),
		[fswname] VARCHAR(200),
		[supervisor] VARCHAR(200),			
		[ForWhom] VARCHAR(200)
		
	)		

		INSERT INTO @tblASQTicklerCohort	
			  select 
					HVCasePK
					,LevelName
					,pc1id
					,rtrim(pc1.pcfirstname)+' '+rtrim(pc1.pclastname) pc1name
					--,hvcase.tcdob
					,case
					   when hvcase.tcdob is not null then
						   hvcase.tcdob
					   else
						   hvcase.edc
					end as tcdob
					
					,gestationalage
					,eventDescription
					,case
						 when interval < 24 then
							 dateadd(dd,dueby,(((40-gestationalage)*7)+hvcase.tcdob))
						 else
							 dateadd(dd,dueby,hvcase.tcdob)
					 end DueDate
					,substring((select distinct ', '+rtrim(tcfirstname)+' '+rtrim(tclastname)
									from tcid
									where hvcase.hvcasepk = tcid.hvcasefk
										 and tcid.programfk = caseprogram.programfk
									for xml path ('')),3,1000) TargetChild
					,rtrim(fsw.firstname)+' '+rtrim(fsw.lastname) fswname
					,ltrim(rtrim(supervisor.firstname))+' '+ltrim(rtrim(supervisor.lastname)) supervisor
					,rtrim(tcfirstname)+' '+rtrim(tclastname) ForWhom
				  from caseprogram
					  inner join hvcase on hvcasepk = caseprogram.hvcasefk
					  inner join pc pc1 on pc1fk = pc1.pcpk
					  inner join tcid on tcid.hvcasefk = hvcasepk 
					  --and tcid.programfk = caseprogram.programfk (11/25/2013 - Chris Papas removed, not bringing in transferred cases)
					  --inner join appoptions on caseprogram.programfk = appoptions.programfk and optionitem = 'asq version'
					  inner join codeduebydates on scheduledevent = 'ASQ' 
					  --inner join codeduebydates on scheduledevent = optionValue
					  inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
					  inner join worker fsw on fsw.workerpk = currentfswfk
					  inner join workerprogram on workerfk = fsw.workerpk AND workerprogram.ProgramFK=ListItem
					  inner join worker supervisor on supervisorfk = supervisor.workerpk
					  inner join codelevel on codelevelpk = currentlevelfk
					  left join asq on asq.hvcasefk = hvcasepk 
						--and asq.programfk = caseprogram.programfk (11/25/2013 - Chris Papas removed, not bringing in transferred cases)
						and codeduebydates.interval = TCAge
				  where asq.hvcasefk is NULL
				       AND HVCase.TCDOD IS NULL
					   and caseprogress >= 11
					   and currentFSWFK = isnull(@workerfk,currentFSWFK)
					   and supervisorfk = isnull(@supervisorfk,supervisorfk)
					   and (dischargedate is null)
					   and year(case
									when interval < 24 then
										dateadd(dd,dueby,(((40-gestationalage)*7)+hvcase.tcdob))
									else
										dateadd(dd,dueby,hvcase.tcdob)
								end) = year(@rdate)
					   and month(case
									 when interval < 24 then
										 dateadd(dd,dueby,(((40-gestationalage)*7)+hvcase.tcdob))
									 else
										 dateadd(dd,dueby,hvcase.tcdob)
								 end) = month(@rdate)
				

				;				 
							 
				WITH cteLastHighestASQ AS
				(
				SELECT 
						asqt.HVCasePK			 
					  , max(TCAge) AS Interval
				 
				  FROM @tblASQTicklerCohort asqt  
				  LEFT JOIN ASQ A ON asqt.HVCasePK = a.HVCaseFK 
				 GROUP BY HVCasePK	
				 --ORDER BY HVCasePK 
				)

				,
				cteExcludeOptionalsIfCasesAreASQTCReceivingIsYes as
				(
					-- get hvcasepk's that we will exclude because for them ASQTCReceiving = 1 and EventDescription contains optional
				SELECT DISTINCT 		
					  cc.HVCasePK		 
					  FROM @tblASQTicklerCohort cc
				INNER  JOIN cteLastHighestASQ cl ON cl.HVCasePK = cc.HVCasePK
				LEFT   JOIN ASQ asqq ON cl.HVCasePK = asqq.HVCaseFK -- OR asqq.HVCaseFK IS null
				WHERE  
					(asqq.TCAge  = cl.Interval OR cl.Interval IS NULL)
					AND
					(asqq.ASQTCReceiving = 1 AND  EventDescription LIKE '%optional%')
					
				)				




	
	select *
		from (
			  -- ASQ
 
								 

				SELECT DISTINCT 
					   LevelName
					 , PC1ID
					 , pc1name
					 , cc.tcdob
					 , GestationalAge
					 
					 , CASE WHEN asqq.ASQTCReceiving = 1 THEN 'Please contact EI program for update'
						 ELSE 
						EventDescription
						END AS EventDescription
						
					 , DueDate
					 , TargetChild
					 , fswname
					 , supervisor
					 , ForWhom				

					 
					  FROM @tblASQTicklerCohort cc
				INNER  JOIN cteLastHighestASQ cl ON cl.HVCasePK = cc.HVCasePK
				LEFT   JOIN ASQ asqq ON cl.HVCasePK = asqq.HVCaseFK -- OR asqq.HVCaseFK IS null

				WHERE  
					(asqq.TCAge  = cl.Interval OR cl.Interval IS NULL)
					AND
					cc.HVCasePK NOT IN (SELECT HVCasePK FROM cteExcludeOptionalsIfCasesAreASQTCReceivingIsYes)

				
								 
								 
								 
			  union
			  ---- ASQ-SE
			  select LevelName
					,pc1id
					,rtrim(pc1.pcfirstname)+' '+rtrim(pc1.pclastname) pc1name
					--,hvcase.tcdob
					,case
					   when hvcase.tcdob is not null then
						   hvcase.tcdob
					   else
						   hvcase.edc
					end as tcdob
					
					,gestationalage
					,eventDescription
					,dateadd(dd,dueby,hvcase.tcdob) DueDate
					,substring((select distinct ', '+rtrim(tcfirstname)+' '+rtrim(tclastname)
									from tcid
									where hvcase.hvcasepk = tcid.hvcasefk
										 and tcid.programfk = caseprogram.programfk
									for xml path ('')),3,1000) TargetChild
					,rtrim(fsw.firstname)+' '+rtrim(fsw.lastname) fswname
					,ltrim(rtrim(supervisor.firstname))+' '+ltrim(rtrim(supervisor.lastname)) supervisor
					,rtrim(tcfirstname)+' '+rtrim(tclastname) ForWhom
				  from caseprogram
					  inner join hvcase on hvcasepk = caseprogram.hvcasefk
					  inner join pc pc1 on pc1fk = pc1.pcpk
					  inner join tcid on tcid.hvcasefk = hvcasepk and tcid.programfk = caseprogram.programfk
					  --inner join appoptions on caseprogram.programfk = appoptions.programfk and optionitem = 'asqse version'
					  inner join codeduebydates on scheduledevent = 'ASQSE-1'  --optionValue
					  --inner join codeduebydates on scheduledevent = optionValue
					  inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
					  inner join worker fsw on fsw.workerpk = currentfswfk
					  inner join workerprogram on workerfk = fsw.workerpk AND workerprogram.ProgramFK = ListItem
					  inner join worker supervisor on supervisorfk = supervisor.workerpk
					  inner join codelevel on codelevelpk = currentlevelfk
					  left join asqse on asqse.hvcasefk = hvcasepk and asqse.programfk = caseprogram.programfk 
					  and codeduebydates.interval = asqseTCAge
				  where asqse.hvcasefk is NULL
				       AND HVCase.TCDOD IS NULL
					   and caseprogress >= 11
					   and currentFSWFK = isnull(@workerfk,currentFSWFK)
					   and supervisorfk = isnull(@supervisorfk,supervisorfk)
					   and (dischargedate is null)
					   and year(dateadd(dd,dueby,hvcase.tcdob)) = year(@rdate)
					   and month(dateadd(dd,dueby,hvcase.tcdob)) = month(@rdate)
			  union
			  ---- FOLLOW UP
			  select LevelName
					,pc1id
					,rtrim(pc1.pcfirstname)+' '+rtrim(pc1.pclastname) pc1name
					--,hvcase.tcdob
					,case
					   when hvcase.tcdob is not null then
						   hvcase.tcdob
					   else
						   hvcase.edc
					end as tcdob
					
					,gestationalage
					,eventDescription
					,dateadd(dd,dueby,hvcase.tcdob) DueDate
					,substring((select distinct ', '+rtrim(tcfirstname)+' '+rtrim(tclastname)
									from tcid
									where hvcase.hvcasepk = tcid.hvcasefk
										 and tcid.programfk = caseprogram.programfk
									for xml path ('')),3,1000) TargetChild
					,rtrim(fsw.firstname)+' '+rtrim(fsw.lastname) fswname
					,ltrim(rtrim(supervisor.firstname))+' '+ltrim(rtrim(supervisor.lastname)) supervisor
					,null ForWhom
				  from caseprogram
					  inner join hvcase on hvcasepk = caseprogram.hvcasefk
					  inner join pc pc1 on pc1fk = pc1.pcpk
					  inner join tcid on tcid.hvcasefk = hvcasepk and tcid.programfk = caseprogram.programfk
					  inner join codeduebydates on scheduledevent = 'Follow Up'
					  inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
					  inner join worker fsw on fsw.workerpk = currentfswfk
					  inner join workerprogram on workerfk = fsw.workerpk AND workerprogram.ProgramFK=ListItem
					  inner join worker supervisor on supervisorfk = supervisor.workerpk
					  inner join codelevel on codelevelpk = currentlevelfk
					  left join followup on followup.hvcasefk = hvcasepk and followup.programfk = caseprogram.programfk 
					  and codeduebydates.interval = followupinterval
				  where followup.hvcasefk is NULL
				       AND HVCase.TCDOD IS NULL
					   and caseprogress >= 11
					   and currentFSWFK = isnull(@workerfk,currentFSWFK)
					   and supervisorfk = isnull(@supervisorfk,supervisorfk)
					   and (dischargedate is null)
					   and year(dateadd(dd,dueby,hvcase.tcdob)) = year(@rdate)
					   and month(dateadd(dd,dueby,hvcase.tcdob)) = month(@rdate)
				--------------------

				UNION
				-- IFSP/FPG
                 select LevelName
					,pc1id
					,rtrim(pc1.pcfirstname)+' '+rtrim(pc1.pclastname) pc1name
					--,hvcase.tcdob
					,case
					   when hvcase.tcdob is not null then
						   hvcase.tcdob
					   else
						   hvcase.edc
					end as tcdob
					--, hvcase.IntakeDate AS IntakeDate
					
					--, CASE WHEN ISNULL(hvcase.edc,hvcase.tcdob) <= hvcase.IntakeDate THEN 'Postnatal' ELSE 'Prenatal'
					--END AS Status

					--,DueBy AS DueBy
					
					,gestationalage
					,eventDescription
					,dateadd(dd,dueby,hvcase.IntakeDate) DueDate
					,substring((select distinct ', '+rtrim(tcfirstname)+' '+rtrim(tclastname)
									from tcid
									where hvcase.hvcasepk = tcid.hvcasefk
										 and tcid.programfk = caseprogram.programfk
									for xml path ('')),3,1000) TargetChild
					,rtrim(fsw.firstname)+' '+rtrim(fsw.lastname) fswname
					,ltrim(rtrim(supervisor.firstname))+' '+ltrim(rtrim(supervisor.lastname)) supervisor
					--,rtrim(tcfirstname)+' '+rtrim(tclastname) ForWhom
					,'' ForWhom
					
				  from caseprogram
					  inner join hvcase on hvcasepk = caseprogram.hvcasefk
					  inner join pc pc1 on pc1fk = pc1.pcpk
					  inner join tcid on tcid.hvcasefk = hvcasepk and tcid.programfk = caseprogram.programfk
					  --inner join appoptions on caseprogram.programfk = appoptions.programfk and optionitem = 'asqse version'
					  inner join codeduebydates on scheduledevent = 'IFSP/FGP'  --optionValue
					  --inner join codeduebydates on scheduledevent = optionValue
					  inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
					  inner join worker fsw on fsw.workerpk = currentfswfk
					  inner join workerprogram on workerfk = fsw.workerpk AND workerprogram.ProgramFK = ListItem
					  inner join worker supervisor on supervisorfk = supervisor.workerpk
					  inner join codelevel on codelevelpk = currentlevelfk
					  left join asqse on asqse.hvcasefk = hvcasepk and asqse.programfk = caseprogram.programfk 
					  and codeduebydates.interval = asqseTCAge
				  where asqse.hvcasefk is NULL
				       AND HVCase.TCDOD IS NULL
					   and caseprogress >= 11
					   and currentFSWFK = isnull(@workerfk,currentFSWFK)
					   and supervisorfk = isnull(@supervisorfk,supervisorfk)
					   and (dischargedate is null)

					   and year(dateadd(dd,dueby,hvcase.IntakeDate)) = year(@rdate)
					   and month(dateadd(dd,dueby,hvcase.IntakeDate)) = month(@rdate)

				-------------------
			
				 union
			  ---- PSI 10/01/2012 added by dar chen
			  select LevelName
					,pc1id
					,rtrim(pc1.pcfirstname)+' '+rtrim(pc1.pclastname) pc1name
					--,hvcase.tcdob
					,case
					   when hvcase.tcdob is not null then
						   hvcase.tcdob
					   else
						   hvcase.edc
					end as tcdob
					,gestationalage
					,eventDescription
					,dateadd(dd,dueby,ISNULL(hvcase.tcdob, hvcase.edc)) DueDate
					,substring((select distinct ', '+rtrim(tcfirstname)+' '+rtrim(tclastname)
									from tcid
									where hvcase.hvcasepk = tcid.hvcasefk
										 and tcid.programfk = caseprogram.programfk
									for xml path ('')),3,1000) TargetChild
					,rtrim(fsw.firstname)+' '+rtrim(fsw.lastname) fswname
					,ltrim(rtrim(supervisor.firstname))+' '+ltrim(rtrim(supervisor.lastname)) supervisor
					,null ForWhom
				  from caseprogram
					  inner join hvcase on hvcasepk = caseprogram.hvcasefk
					  inner join pc pc1 on pc1fk = pc1.pcpk
					  inner join tcid on tcid.hvcasefk = hvcasepk and tcid.programfk = caseprogram.programfk
					  inner join codeduebydates on scheduledevent = 'PSI'
					  inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
					  inner join worker fsw on fsw.workerpk = currentfswfk
					  inner join workerprogram on workerfk = fsw.workerpk  AND workerprogram.ProgramFK=ListItem
					  inner join worker supervisor on supervisorfk = supervisor.workerpk
					  inner join codelevel on codelevelpk = currentlevelfk
					  left join PSI on PSI.hvcasefk = hvcasepk and PSI.programfk = caseprogram.programfk 
					  and codeduebydates.interval = PSIInterval
				  where PSI.hvcasefk is NULL
				       AND HVCase.TCDOD IS NULL
					   and caseprogress >= 11
					   and currentFSWFK = isnull(@workerfk,currentFSWFK)
					   and supervisorfk = isnull(@supervisorfk,supervisorfk)
					   and (dischargedate is null)
					   and year(dateadd(dd,dueby,ISNULL(hvcase.tcdob, hvcase.edc))) = year(@rdate)
					   and month(dateadd(dd,dueby,ISNULL(hvcase.tcdob, hvcase.edc))) = month(@rdate)
					   
					   		   
					   ) t
		order by fswname
				,duedate
GO
