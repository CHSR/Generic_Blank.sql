SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		<Dorothy Baum>
-- Create date: <June 14, 2010>
-- Description:	<report: Supervisor Case List>
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred

-- rspSupervisorCaseList_delete 1
-- rspSupervisorCaseList_delete 23
-- 02/07/2014 added program capacity ... khalsa
-- =============================================
CREATE procedure [dbo].[rspSupervisorCaseList_delete]
(
    @ProgramFK varchar(max) = null,
    @SupPK     int = null
)
-- Add the parameters for the stored procedure here
as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

	-- Insert statements for procedure here
	if @ProgramFK is null
	begin
		select @ProgramFK =
			   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	end

		--print @ProgramFK

	set @ProgramFK = REPLACE(@ProgramFK,'"','')
	
	
	;
	with ctemain
	as
	(
	select pc1id
		  ,levelname
		  ,caseweight
		  ,supfname
		  ,suplname
		  ,worker.firstname as wfname
		  ,worker.lastname as wlname
		  ,case when levelname in ('Preintake','Preintake-enroll') then 1 else 0 end as PreintakeCount
		  ,case when levelname='Level 1' then 1 else 0 end as Level1Count
		  ,case when levelname='Level 2' then 1 else 0 end as Level2Count
		  ,case when levelname='Level 3' then 1 else 0 end as Level3Count
		  ,case when levelname='Level 4' then 1 else 0 end as Level4Count
		  ,case when levelname='Level 1-SS' then 1 else 0 end as Level1SSCount
		  ,case when levelname='Level 1-Prenatal' then 1 else 0 end as Level1PrenatalCount
		  ,case when levelname='Level X' then 1 else 0 end as LevelXCount
		  ,CaseProgram.ProgramFK
		  ,ProgramCapacity
		from
			(select *
				 from codeLevel
				 where caseweight is not null) cl
			left outer join caseprogram
						   on caseprogram.currentLevelFK = cl.codeLevelPK
			inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			inner join worker
					  on caseprogram.currentFSWFK = worker.workerpk
			inner join workerprogram wp
					  on wp.workerfk = worker.workerpk AND wp.programfk = listitem
			left outer join (select workerpk
								  ,firstName as supfname
								  ,LastName as suplname
								from worker) sw
						   on wp.supervisorfk = sw.workerpk
			left outer join HVProgram h on h.HVProgramPK = CaseProgram.ProgramFK			   
						   
		where
			 dischargedate is null
			 and sw.workerpk = isnull(@SupPK,sw.workerpk)
			 
		)	 
	,ctemainAgain
	as
	(
	select pc1id
		  ,levelname
		  ,caseweight
		  ,supfname
		  ,suplname
		  ,worker.firstname as wfname
		  ,worker.lastname as wlname
		  ,case when levelname in ('Preintake','Preintake-enroll') then 1 else 0 end as PreintakeCount
		  ,case when levelname='Level 1' then 1 else 0 end as Level1Count
		  ,case when levelname='Level 2' then 1 else 0 end as Level2Count
		  ,case when levelname='Level 3' then 1 else 0 end as Level3Count
		  ,case when levelname='Level 4' then 1 else 0 end as Level4Count
		  ,case when levelname='Level 1-SS' then 1 else 0 end as Level1SSCount
		  ,case when levelname='Level 1-Prenatal' then 1 else 0 end as Level1PrenatalCount
		  ,case when levelname='Level X' then 1 else 0 end as LevelXCount
		  ,CaseProgram.ProgramFK
		  ,ProgramCapacity
		from
			(select *
				 from codeLevel
				 where caseweight is not null) cl
			left outer join caseprogram
						   on caseprogram.currentLevelFK = cl.codeLevelPK
			inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			inner join worker
					  on caseprogram.currentFSWFK = worker.workerpk
			inner join workerprogram wp
					  on wp.workerfk = worker.workerpk AND wp.programfk = listitem
			left outer join (select workerpk
								  ,firstName as supfname
								  ,LastName as suplname
								from worker) sw
						   on wp.supervisorfk = sw.workerpk
			left outer join HVProgram h on h.HVProgramPK = CaseProgram.ProgramFK			   
						   
		where
			 dischargedate is null
			 and sw.workerpk = isnull(@SupPK,sw.workerpk)
			 
		)	
		
	,cteProgramCapacity
	as
	( -- calculate the program capacity
	select 

			 --ProgramCapacity,
			 case when ProgramCapacity is null then 'Program capacity blank on Program Information Form.' 
				  else
					CONVERT(VARCHAR,count(PC1ID) - sum(PreintakeCount))
					 + ' (' + CONVERT(VARCHAR, round(COALESCE(cast((count(PC1ID) - sum(PreintakeCount)) AS FLOAT) * 100/ NULLIF(ProgramCapacity,0), 0), 0))  + '%)'
				  end 
			  	AS PerctOfProgramCapacity
			  
			   FROM ctemainAgain
			   group by ProgramFK,ProgramCapacity

			 
		)	 
		
		
		SELECT PC1ID
			  ,LevelName
			  ,CaseWeight
			  ,supfname
			  ,suplname
			  ,wfname
			  ,wlname
			  ,PreintakeCount
			  ,Level1Count
			  ,Level2Count
			  ,Level3Count
			  ,Level4Count
			  ,Level1SSCount
			  ,Level1PrenatalCount
			  ,LevelXCount
			  ,PerctOfProgramCapacity as ProgramCapacity
			  ,case when ProgramCapacity is null then ''
				  else
						  CONVERT(VARCHAR,ProgramCapacity)
				  end 
			  	AS ContractedCapacity
			  
			  			  
			   FROM ctemain, cteProgramCapacity		
		where wfname like 'Matthew'
	
		order by PC1ID
				--suplname
				--,supfname
				--,wlname
				--,wfname

end

-- rspSupervisorCaseList_delete 23
GO
