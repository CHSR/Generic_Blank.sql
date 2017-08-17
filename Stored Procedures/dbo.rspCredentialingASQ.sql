SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		<cchen2>
-- Create date: <June 3, 2010>
-- Description:	<report: Credentialing 6-6.B ASQ>
-- Edit date: 
-- rspASQHistory 1
-- =============================================

CREATE procedure [dbo].[rspCredentialingASQ]
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

	if object_id('tempdb..#cteAll') is not null drop table #cteAll

	create table #cteAll (
		   supervisor varchar(100)
		 , worker varchar(100)
		 , PC1ID char(13)
		 , TCName varchar(450)
		 , TCDOB varchar(12)
		 , GestationalAge int
		 , TCAge varchar(150)
		 , DateCompleted varchar(12)
		 , InWindow varchar(50)
		 , [TCAgeCode] char(2)
		 , ASQTCReceiving int
	)

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
		 ,case when ASQInWindow is null then 'Unknown'
			  when ASQInWindow = 1 then 'In Window' else 'Out of Window' end InWindow
		 ,a.TCAge [TCAgeCode]
		 ,ISNULL(a.[ASQTCReceiving],0) ASQTCReceiving
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
			 and d.PC1ID = case when @pc1ID = '' then d.PC1ID else @pc1ID end
			 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
)

, cteNone
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
		 ,'' InWindow
		 ,'' [TCAgeCode]
		 ,0 [ASQTCReceiving]
		from 
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
			 and d.PC1ID = case when @pc1ID = '' then d.PC1ID else @pc1ID end
			 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
			 AND a.HVCaseFK IS NULL
			 AND c.TCDOB IS NOT NULL 
			 AND (CASE WHEN @UnderCutoffOnly = 'Y' THEN 1 ELSE 0 END = 0)
)

insert into #cteAll	
	  SELECT DISTINCT * FROM cteMain
	  UNION all
	  SELECT * FROM cteNone 
	
; with cteAdjAge AS (
	SELECT * 
	
         ,CASE WHEN (CASE WHEN dateadd(year, datediff (year, a.TCDOB, getdate()), a.TCDOB) > getdate()
            THEN datediff(year, a.TCDOB, getdate()) - 1
            ELSE datediff(year, a.TCDOB, getdate())
          END) < 2 AND a.GestationalAge <= 40 
          THEN convert(DATETIME, a.TCDOB, 101) + (40 - a.GestationalAge) * 7
          ELSE convert(DATETIME, a.TCDOB, 101) END AdjTCDOB
	FROM #cteAll AS a
)

, cteFinal AS (
	SELECT *
	,CASE WHEN dateadd(year, datediff (year, AdjTCDOB, getdate()), AdjTCDOB) > getdate()
            THEN datediff(year, AdjTCDOB, getdate()) - 1
            ELSE datediff(year, AdjTCDOB, getdate())
          END as Age
	
	,datediff(month, AdjTCDOB, getdate()) as AgeMonth
	
	, CASE WHEN DateCompleted <> '' 
	THEN CASE WHEN dateadd(year, datediff (year, AdjTCDOB, DateCompleted), AdjTCDOB) > DateCompleted
            THEN datediff(year, AdjTCDOB, DateCompleted) - 1
            ELSE datediff(year, AdjTCDOB, DateCompleted)
          END
	ELSE -1 END AS AgeAtDateCompleted
	
	, CASE WHEN DateCompleted <> '' 
	THEN 
	
		CASE 
			WHEN DATEPART(DAY, AdjTCDOB) > DATEPART(DAY, DateCompleted)
			THEN datediff (month, AdjTCDOB, DateCompleted) - 1
			ELSE datediff (month, AdjTCDOB, DateCompleted)
		END

	--datediff (month, AdjTCDOB, DateCompleted)
	
	
	ELSE -1 END AS AgeAtDateCompletedMonth
	
	
	
	FROM cteAdjAge
	)
	
, cteXXX AS (
	SELECT PC1ID, sum(CASE WHEN AgeAtDateCompleted = -1 THEN 0 
	WHEN (Age - AgeAtDateCompleted) <= 1 THEN 1 ELSE 0 END) AS nASQ
	FROM cteFinal
	GROUP BY PC1ID
)

, cteYYY AS (
	SELECT a.*, b.nASQ
	, CASE WHEN a.Age = 1 THEN (CASE WHEN b.nASQ >= 2 THEN 'Yes' ELSE 'No' END)
	       WHEN a.Age = 2 THEN (CASE WHEN b.nASQ >= 2 THEN 'Yes' ELSE 'No' END)
	       ELSE (CASE WHEN b.nASQ >= 1 THEN 'Yes' ELSE 'No' END)
	  END AS Meets
	FROM cteFinal AS a JOIN cteXXX AS b ON a.PC1ID = b.PC1ID
)

, cteASQTCReceiving AS (
	SELECT d.PC1ID, SUM(CASE WHEN  a.ASQTCReceiving = 1 then 1 ELSE 0 END) AS EI
	FROM ASQ AS a
	inner join CaseProgram d on d.HVCaseFK = a.HVCaseFK
	inner join dbo.SplitString(@programfk,',') on d.programfk = listitem
	GROUP BY d.PC1ID
)

-- Meets,
SELECT 
supervisor, worker, a.PC1ID, TCName, TCDOB, GestationalAge, TCAge, 
DateCompleted, InWindow, [TCAgeCode], AdjTCDOB, Age, AgeMonth,
CASE WHEN AgeAtDateCompleted = -1 THEN 0 ELSE AgeAtDateCompleted END AgeAtDateCompleted, 
nASQ, AgeAtDateCompletedMonth, b.EI, CASE WHEN b.EI > 0 THEN 'EI' ELSE
a.Meets END AS Meets, CASE WHEN a.[ASQTCReceiving] = 1 THEN 'Yes' ELSE 'No' END AS TCReceivingEI
FROM cteYYY AS a JOIN cteASQTCReceiving AS b ON a.PC1ID = b.PC1ID
WHERE Age > 0 AND Age <= 5
order by Age DESC, worker, PC1ID, TCAgeCode

drop table #cteAll
GO
