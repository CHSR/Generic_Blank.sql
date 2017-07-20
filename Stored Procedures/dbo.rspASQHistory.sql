SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- rspASQHistory 1

CREATE procedure [dbo].[rspASQHistory]
(
    @ProgramFK       VARCHAR(MAX)   = null,
    @SupervisorFK    int            = null,
    @WorkerFK        int            = null,
    @UnderCutoffOnly char(1)        = 'N',
    @PC1ID           varchar(13)    = '',
    @SiteFK          int            = null, 
    @CaseFiltersPositive varchar(100) = ''
    
)
AS

--DECLARE @programfk       VARCHAR(MAX)   = '1'
--DECLARE @supervisorfk    int            = null
--DECLARE @workerfk        int            = null
--DECLARE @UnderCutoffOnly char(1)        = 'N'
--DECLARE @pc1ID           varchar(13)    = ''
--DECLARE @sitefk          int            = NULL
--DECLARE @CaseFiltersPositive varchar(100) = ''
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred


  if @programfk is null
	begin
		select @programfk = substring((select ','+ltrim(rtrim(str(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end
	set @programfk = replace(@programfk,'"','')
	set @SiteFK = isnull(@SiteFK, 0)
	set @CaseFiltersPositive = case	when @CaseFiltersPositive = '' then null
								else @CaseFiltersPositive
						   end;

	declare @n int = 0
	select @n = case when @UnderCutoffOnly = 'Y' then 1 else 0 end


;with cteMain
	as (
	select
		  LTRIM(RTRIM(supervisor.firstname))+' '+LTRIM(RTRIM(supervisor.lastname)) supervisor
		 ,LTRIM(RTRIM(fsw.firstname))+' '+LTRIM(RTRIM(fsw.lastname)) worker
		 ,d.PC1ID
		 ,LTRIM(RTRIM(c.TCFirstName))+' '+LTRIM(RTRIM(c.TCLastName)) TCName
		 ,convert(varchar(12),c.TCDOB,101) TCDOB
		 ,c.GestationalAge
		 ,ltrim(rtrim(replace(b.[AppCodeText],'(optional)',''))) TCAge
		 ,convert(varchar(12),a.DateCompleted,101) DateCompleted
		 ,a.ASQCommunicationScore
		 ,case when UnderCommunication = 1 then '*' else '' end UnderCommunication
		 ,ASQGrossMotorScore
		 ,case when UnderGrossMotor = 1 then '*' else '' end UnderGrossMotor
		 ,ASQFineMotorScore
		 ,case when UnderFineMotor = 1 then '*' else '' end UnderFineMotor
		 ,ASQProblemSolvingScore
		 ,case when UnderProblemSolving = 1 then '*' else '' end UnderProblemSolving
		 ,ASQPersonalSocialScore
		 ,case when UnderPersonalSocial = 1 then '*' else '' end UnderPersonalSocial
		 ,case when TCReferred is null then 'Unknown'
			  when TCReferred = 1 then 'Yes' else 'No' end TCReferred
		 ,case when ASQTCReceiving = '1' then 'Yes' else 'No' end ReviewCDS
		 ,case when ASQInWindow is null then 'Unknown'
			  when ASQInWindow = 1 then 'In Window' else 'Out of Window' end InWindow
		 ,case when DiscussedWithPC1 is null then 'Blank'
			  when DiscussedWithPC1 = 1 then 'Yes' else 'No' end DiscussedWithPC1			  
		 ,a.TCAge [TCAgeCode]

		from ASQ a
			inner join codeApp b on a.TCAge = b.AppCode and b.AppCodeGroup = 'TCAge' and b.AppCodeUsedWhere like '%AQ%'
			inner join TCID c on c.TCIDPK = a.TCIDFK
			inner join CaseProgram d on d.HVCaseFK = a.HVCaseFK
			inner join dbo.SplitString(@programfk,',') on d.programfk = listitem
			inner join dbo.udfCaseFilters(@CaseFiltersPositive, '', @ProgramFK) cf on cf.HVCaseFK = a.HVCaseFK
			inner join worker fsw ON d.CurrentFSWFK = fsw.workerpk
			inner join workerprogram wp on wp.workerfk = fsw.workerpk  AND wp.programfk = listitem
			inner join worker supervisor on wp.supervisorfk = supervisor.workerpk
			inner join
					  (select TCIDFK
							 ,SUM(
							  case when UnderCommunication = 1 then 1 else 0 end+
							  case when UnderFineMotor = 1 then 1 else 0 end+
							  case when UnderGrossMotor = 1 then 1 else 0 end+
							  case when UnderPersonalSocial = 1 then 1 else 0 end+
							  case when UnderProblemSolving = 1 then 1 else 0 end
							  ) flag
						   from ASQ
						   group by TCIDFK
						   having SUM(
								 case when UnderCommunication = 1 then 1 else 0 end+
								 case when UnderFineMotor = 1 then 1 else 0 end+
								 case when UnderGrossMotor = 1 then 1 else 0 end+
								 case when UnderPersonalSocial = 1 then 1 else 0 end+
								 case when UnderProblemSolving = 1 then 1 else 0 end
								 ) >= @n) x
					  on x.TCIDFK = a.TCIDFK

		where
			 d.DischargeDate is null
			 and d.currentFSWFK = ISNULL(@workerfk,d.currentFSWFK)
			 and wp.supervisorfk = ISNULL(@supervisorfk,wp.supervisorfk)
			 --and d.programfk = @programfk
			 and d.PC1ID = case when @pc1ID = '' then d.PC1ID else @pc1ID end
			 --and SiteFK = isnull(@sitefk,SiteFK)
			 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
		--order by supervisor
		--		,worker
		--		,PC1ID
		--		,TCAgeCode
),


cteNone
	as (
	select
		  LTRIM(RTRIM(supervisor.firstname))+' '+LTRIM(RTRIM(supervisor.lastname)) supervisor
		 ,LTRIM(RTRIM(fsw.firstname))+' '+LTRIM(RTRIM(fsw.lastname)) worker
		 ,d.PC1ID
		 ,LTRIM(RTRIM(c.TCFirstName))+' '+LTRIM(RTRIM(c.TCLastName)) TCName
		 ,CASE WHEN c.TCDOB IS NOT NULL THEN convert(varchar(12),c.TCDOB,101) ELSE convert(varchar(12),h.EDC,101) END TCDOB
		 ,c.GestationalAge
		 ,'[None]' TCAge
		 ,'' DateCompleted
		 ,a.ASQCommunicationScore
		 ,case when UnderCommunication = 1 then '*' else '' end UnderCommunication
		 ,ASQGrossMotorScore
		 ,case when UnderGrossMotor = 1 then '*' else '' end UnderGrossMotor
		 ,ASQFineMotorScore
		 ,case when UnderFineMotor = 1 then '*' else '' end UnderFineMotor
		 ,ASQProblemSolvingScore
		 ,case when UnderProblemSolving = 1 then '*' else '' end UnderProblemSolving
		 ,ASQPersonalSocialScore
		 ,case when UnderPersonalSocial = 1 then '*' else '' end UnderPersonalSocial
		 ,'' TCReferred
		 ,'' DiscussedWithPC1
		 ,'' ReviewCDS
		 ,'' InWindow
		 ,'' [TCAgeCode]

		from --ASQ a
			--inner join codeApp b on a.TCAge = b.AppCode and b.AppCodeGroup = 'TCAge' and b.AppCodeUsedWhere like '%AQ%'
			--inner join TCID c on c.TCIDPK = a.TCIDFK
			CaseProgram d 
			INNER JOIN HVCase AS h ON h.HVCasePK = d.HVCaseFK
			inner join dbo.SplitString(@programfk,',') on d.programfk = listitem
			inner join dbo.udfCaseFilters(@CaseFiltersPositive, '', @ProgramFK) cf on cf.HVCaseFK = h.HVCasePK
			inner join worker fsw ON d.CurrentFSWFK = fsw.workerpk
			inner join workerprogram wp on wp.workerfk = fsw.workerpk  AND wp.programfk = listitem
			inner join worker supervisor on wp.supervisorfk = supervisor.workerpk
			LEFT OUTER JOIN TCID c on c.HVCaseFK = d.HVCaseFK
			LEFT OUTER JOIN ASQ AS a ON d.HVCaseFK = a.HVCaseFK
			
		where 
		h.CaseProgress > 8 AND
			 d.DischargeDate is null
			 and d.currentFSWFK = ISNULL(@workerfk,d.currentFSWFK)
			 and wp.supervisorfk = ISNULL(@supervisorfk,wp.supervisorfk)
			 --and d.programfk = @programfk
			 and d.PC1ID = case when @pc1ID = '' then d.PC1ID else @pc1ID end
			 --and SiteFK = isnull(@sitefk,SiteFK)
			 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
			 AND a.HVCaseFK IS NULL
			 AND c.TCDOB IS NOT NULL 
			 AND (CASE WHEN @UnderCutoffOnly = 'Y' THEN 1 ELSE 0 END = 0)
		--order by supervisor
		--		,worker
		--		,PC1ID
		--		,TCAgeCode
)

	  SELECT * FROM cteMain
	  UNION all
	  SELECT * FROM cteNone 
	  order by worker, PC1ID, TCAgeCode
	
	
GO
