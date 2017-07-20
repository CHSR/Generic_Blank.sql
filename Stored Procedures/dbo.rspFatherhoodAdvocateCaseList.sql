SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <March 21, 2013>
-- Description:	<This report gets you 'R. Father Figures Case List '> -- similar to FSW Case List
-- rspDataReport_bak 5, '06/01/2012', '09/30/2012'			

-- exec rspFatherhoodAdvocateCaseList 2
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
--            added this code to the workerprogram join condition: AND wp.programfk = listitem
-- =============================================


CREATE procedure [dbo].[rspFatherhoodAdvocateCaseList]
(@programfk    varchar(max)    = null,
 @supervisorfk int             = null,
 @workerfk     int             = null
)

as

--DECLARE @programfk    varchar(max)    = '1'
--DECLARE @supervisorfk int             = null
--DECLARE @workerfk     int             = null

	if @programfk is null
	begin
		select @programfk =
			   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

	declare @caselist table(
		pc1id varchar(13),
		codelevelpk int,
		levelname varchar(200),
		currentleveldate datetime,
		CaseWeight float,
		pcfirstname varchar(200),
		pclastname varchar(200),
		street varchar(200),
		pccsz varchar(200),
		pcphone varchar(200),
		tcfirstname varchar(200),
		tclastname varchar(200),
		tcdob datetime,
		edc datetime,
		faworker varchar(200),
		faworkerlast varchar(200),
		supervisor varchar(200),
		fswworker varchar(200),
		fatherfigurewworker varchar(200),
		DateAcceptService varchar(12),
		RelationToTargetChild VARCHAR(100)
		 
	)

	insert
		into @caselist
		select top 100 percent pc1id
							  ,codelevelpk
							  ,levelname
							  ,currentleveldate
							  ,CaseWeight
							  ,LTRIM(RTRIM(pc.pcfirstname))
							  ,LTRIM(RTRIM(pc.pclastname))
							  ,rtrim(pc.pcstreet)+case
													  when pc.pcapt is null or pc.pcapt = '' then
														  ''
													  else
														  ', Apt: '+rtrim(pc.pcapt)
												  end as street
							  ,rtrim(pc.pccity) + ', ' + pc.pcstate + ' ' + pc.pczip as pccsz
							  ,pc.pcphone + case when pc.PCEmergencyPhone is not null and pc.PCEmergencyPhone <> '' then
										    ', Emr: '+pc.PCEmergencyPhone else '' END 
										  + case when pc.PCCellPhone is not null and pc.PCCellPhone <> '' then
												  ', Cell: '+pc.PCCellPhone else '' end
										   as pcphone
							  ,LTRIM(RTRIM(tcid.tcfirstname))
							  ,LTRIM(RTRIM(tcid.tclastname))
							  ,hvcase.tcdob
							  ,hvcase.edc
							  ,LTRIM(RTRIM(fa.firstname))+' '+LTRIM(RTRIM(fa.lastname)) as faworker
							  ,LTRIM(RTRIM(fa.lastname))+', '+LTRIM(RTRIM(fa.firstname)) as faworkerlast
							  ,LTRIM(RTRIM(supervisor.firstname))+' '+LTRIM(RTRIM(supervisor.lastname)) as supervisor
							  ,LTRIM(RTRIM(fsw.firstname))+' '+LTRIM(RTRIM(fsw.lastname)) as fswworker	
							  ,LTRIM(RTRIM(obp.pcfirstname))+' '+LTRIM(RTRIM(obp.pclastname)) as fatherfigurewworker
							  ,Convert(VARCHAR(12), ff.DateAcceptService, 101) DateAcceptService
							  ,a.AppCodeText
			from hvcase
				inner join caseprogram on caseprogram.hvcasefk = hvcasepk
				inner join workerassignment wa1 on wa1.hvcasefk = caseprogram.hvcasefk
						  and wa1.programfk = caseprogram.programfk
				left join kempe on kempe.hvcasefk = hvcasepk
				inner join codelevel on codelevelpk = currentlevelfk
				inner join pc on pc.pcpk = pc1fk -- pc1
				LEFT JOIN FatherFigure ff ON ff.HVCaseFK = HVCase.HVCasePK
				LEFT JOIN codeApp a ON a.AppCode = ff.RelationToTargetChild AND a.AppCodeUsedWhere LIKE 'FF%'			
				left join tcid on tcid.hvcasefk = hvcasepk AND TCID.TCDOD IS NULL
				inner join worker fa on ff.FatherAdvocateFK = fa.workerpk  -- fa
				inner join worker fsw on CurrentFSWFK = fsw.workerpk   -- fsw
				
				LEFT join pc obp on obp.pcpk = ff.pcfk -- father figure like obp
				
				inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
				
				inner join workerprogram on workerprogram.workerfk = fa.workerpk AND workerprogram.programfk = listitem
				inner join worker supervisor on supervisorfk = supervisor.workerpk
			where ff.FatherAdvocateFK = isnull(@workerfk,ff.FatherAdvocateFK)
				 and supervisorfk = isnull(@supervisorfk,supervisorfk)				 
				 and dischargedate is NULL  -- only open cases
				 AND DateInactive IS NULL  -- only active father figures
				 --AND kempedate IS NOT NULL 'Chris Papas removed 1/28/2011 This was screwing up because there is no kempe date in kempe table once PreAssessment was done, but before Kempe added
				 and casestartdate <= dateadd(dd,1,datediff(dd,0,GETDATE()))

	-- Get a distinct list after concatenating tcid's
	declare @caselist_distinct table(
		CaseWeight float,
		Enrolled_Cases int,
		Preintake_Cases int,
		pc1id varchar(13),
		currentlevel varchar(200),
		pcfirstname varchar(200),
		pclastname varchar(200),
		street varchar(200),
		pccsz varchar(200),
		pcphone varchar(200),
		TargetChild varchar(200),
		faworker varchar(200),
		faworkerlast varchar(200),
		supervisor varchar(200),
		fswworker varchar(200),
		fatherfigurewworker varchar(200),
		DateAcceptService varchar(12),
		RelationToTargetChild VARCHAR(100)  
	)

	insert
		into @caselist_distinct
		select distinct CaseWeight
					   ,(select count(distinct PC1ID)
							 from @caselist c2
							 where codelevelpk >= 10
								  and c2.faworker = r1.faworker) as Enrolled_Cases
					   ,(select count(distinct PC1ID)
							 from @caselist c2
							 where codelevelpk in (7,8,9)
								  and c2.faworker = r1.faworker) as Preintake_Cases
					   ,pc1id
					   ,RTRIM(levelname)+' ('+convert(varchar(12),currentleveldate,101)+')' currentlevel
					   ,pcfirstname
					   ,pclastname
					   ,street
					   ,pccsz
					   ,pcphone
					   ,case
							when tcdob is not null then
								-- concatenate tcid's and hvcase.tcdob
								substring((select distinct ', '+tcfirstname+' '+tclastname
											   from @caselist r2
											   where r1.pc1id = r2.pc1id
											   for xml path ('')),3,1000)+' ('+convert(varchar(12),tcdob,101)+')'
							else
								'EDC: ('+convert(varchar(12),edc,101)+')'
						end TargetChild
					   ,faworker
					   ,faworkerlast
					   ,supervisor
					   ,fswworker
					   ,fatherfigurewworker
					   ,DateAcceptService 
					   ,RelationToTargetChild
			from @caselist r1

	-- Final Query
	select @programfk programfk
		  ,@supervisorfk supervisorfk
		  ,@workerfk workerfk
		  ,(select isnull(sum(CaseWeight),0)
				from @caselist_distinct c2
				where c2.faworker = r1.faworker) as CaseWeight_ttl
		  ,Enrolled_Cases
		  ,Preintake_Cases
		  ,PC1ID
		  ,CurrentLevel
		  ,LTRIM(RTRIM(pcfirstname))+' '+LTRIM(RTRIM(pclastname)) as PC1
		  ,street
		  ,PCCSZ
		  ,PCPhone
		  ,TargetChild
		  ,faworker
		  ,faworkerlast
		  ,Supervisor
		  ,fswworker
		  ,fatherfigurewworker
		  ,DateAcceptService 
		  ,RelationToTargetChild
		from @caselist_distinct r1
		ORDER BY faworker DESC 
		--order by supervisor
		--		,workerlast
		--		,pc1id
GO
