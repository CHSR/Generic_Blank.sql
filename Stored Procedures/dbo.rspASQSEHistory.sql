SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- [rspASQSEHistory] 24
CREATE procedure [dbo].[rspASQSEHistory]
(
    @programfk       VARCHAR(MAX)   = null,
    @supervisorfk    int            = null,
    @workerfk        int            = null,
    @UnderCutoffOnly char(1)        = 'N',
    @pc1ID           varchar(13)    = '',
    @sitefk          int            = null,
    @CaseFiltersPositive varchar(100) = ''
)
AS

--DECLARE @programfk       VARCHAR(MAX)   = '1'
--DECLARE @supervisorfk    int            = null
--DECLARE @workerfk        int            = null
--DECLARE @UnderCutoffOnly char(1)        = 'Y'
--DECLARE @pc1ID           varchar(13)    = ''
--DECLARE @sitefk          int            = NULL
--DECLARE @CaseFiltersPositive varchar(100) = ''
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
--            added this code to the workerprogram join condition: AND wp.programfk = listitem

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
		 ,convert(varchar(12),a.ASQSEDateCompleted,101) DateCompleted
		 ,a.ASQSETotalScore
		 ,case when ASQSEOverCutOff = 1 then '*' else '' end ASQSEOverCutOff
		 ,case when ASQSEReferred is null then 'Unknown'
			  when ASQSEReferred = 1 then 'Yes' else 'No' end TCReferred
		 ,case when ASQSEReceiving = '1' then 'Yes' else 'No' end ReviewCDS
		 ,case when ASQSEInWindow is null then 'Unknown'
			  when ASQSEInWindow = 1 then 'In Window' else 'Out of Window' end InWindow
		 ,case when DiscussedWithPC1 is null then 'Blank'
			  when DiscussedWithPC1 = 1 then 'Yes' else 'No' end DiscussedWithPC1
		 ,a.ASQSETCAge [TCAgeCode]
		from ASQSE a
			inner join codeApp b on a.ASQSETCAge = b.AppCode and b.AppCodeGroup = 'TCAge' 
			and b.AppCodeUsedWhere like '%AS%'
			inner join TCID c on c.TCIDPK = a.TCIDFK
			inner join CaseProgram d on d.HVCaseFK = a.HVCaseFK
			inner join dbo.SplitString(@programfk,',') on d.programfk = listitem
			inner join dbo.udfCaseFilters(@casefilterspositive, '', @programfk) cf on cf.HVCaseFK = a.HVCaseFK
			inner join worker fsw on d.CurrentFSWFK = fsw.workerpk
			inner join workerprogram wp on wp.workerfk = fsw.workerpk AND wp.programfk = listitem
			inner join worker supervisor on wp.supervisorfk = supervisor.workerpk
		where
			 d.DischargeDate is NULL
			 AND (@n = 0 OR ASQSEOverCutOff= 1)
			 and d.currentFSWFK = ISNULL(@workerfk,d.currentFSWFK)
			 and wp.supervisorfk = ISNULL(@supervisorfk,wp.supervisorfk)
			 and d.PC1ID = case when @pc1ID = '' then d.PC1ID else @pc1ID end
			 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
		--order by supervisor
		--		,worker
		--		,PC1ID
		--		,TCAgeCode
),

cteNone
	as (
	SELECT DISTINCT
		  LTRIM(RTRIM(supervisor.firstname))+' '+LTRIM(RTRIM(supervisor.lastname)) supervisor
		 ,LTRIM(RTRIM(fsw.firstname))+' '+LTRIM(RTRIM(fsw.lastname)) worker
		 ,d.PC1ID
		 ,LTRIM(RTRIM(c.TCFirstName))+' '+LTRIM(RTRIM(c.TCLastName)) TCName
		 --,convert(varchar(12),c.TCDOB,101) TCDOB
		 ,CASE WHEN c.TCDOB IS NOT NULL THEN convert(varchar(12),c.TCDOB,101) ELSE convert(varchar(12),h.EDC,101) END TCDOB
		 ,c.GestationalAge
		 ,'[None]' TCAge
		 ,'' DateCompleted
		 ,0 AS [ASQSETotalScore]
		 ,'' ASQSEOverCutOff
		 ,'' TCReferred
		 ,'' DiscussedWithPC1
		 ,'' ReviewCDS
		 ,'' InWindow
		 ,'' [TCAgeCode]
	from --ASQSE a
			--inner join codeApp b on a.TCAge = b.AppCode and b.AppCodeGroup = 'TCAge' and b.AppCodeUsedWhere like '%AQ%'
			--inner join TCID c on c.TCIDPK = a.TCIDFK
			CaseProgram d 
			inner join HVCase AS h ON h.HVCasePK = d.HVCaseFK
			inner join dbo.SplitString(@programfk,',') on d.programfk = listitem
			inner join dbo.udfCaseFilters(@casefilterspositive, '', @programfk) cf on cf.HVCaseFK = h.HVCasePK
			inner join worker fsw ON d.CurrentFSWFK = fsw.workerpk
			inner join workerprogram wp on wp.workerfk = fsw.workerpk  AND wp.programfk = listitem
			inner join worker supervisor on wp.supervisorfk = supervisor.workerpk
			left outer join TCID c on c.HVCaseFK = d.HVCaseFK
			left outer join ASQSE AS a ON d.HVCaseFK = a.HVCaseFK
	where
			 h.CaseProgress > 8 AND
			 d.DischargeDate is NULL
			 and d.currentFSWFK = ISNULL(@workerfk,d.currentFSWFK)
			 and wp.supervisorfk = ISNULL(@supervisorfk,wp.supervisorfk)
			 and d.PC1ID = case when @pc1ID = '' then d.PC1ID else @pc1ID end
			 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)		
	         AND a.HVCaseFK IS NULL
	         AND c.TCDOB IS NOT NULL 
	         AND (CASE WHEN @UnderCutoffOnly = 'Y' THEN 1 ELSE 0 END = 0)
)


SELECT * FROM cteMain
UNION all
SELECT * FROM cteNone

order by --supervisor
worker
,PC1ID
,TCAgeCode
GO
