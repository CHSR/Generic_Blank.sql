SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Devinder Singh Khalsa
-- Create date: 02/06/2013
-- Description:	<report: ASQ Tickler Summary>
--				Moved from FamSys - 02/05/12 jrobohn
-- Modified: Exclude ASQs if case is receiving services for EI
-- rspASQTicklerSummary 1, '12/12/2012'
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
--            added this code to the workerprogram join condition: AND wp.programfk = listitem
-- =============================================
CREATE procedure [dbo].[rspASQTicklerSummary]
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

	-- ASQ
	
	
DECLARE @tblASQTicklerSummaryCohort TABLE(
	[PC1ID] [char](13) NOT NULL,
	[HVCasePK] [int] NOT NULL,
	[TCDOB] [datetime] NULL,
	[GestationalAge] INT,
	[cdob] [datetime] NULL,
	[EventDescription] varchar(50) NULL,
	[DueDate] [datetime] NULL,
	[TargetChild] VARCHAR(200),
	[fswname] VARCHAR(200),
	[supervisor] VARCHAR(200)			
)		
	

	
	INSERT INTO @tblASQTicklerSummaryCohort	
	select  
		  pc1id
		  ,hvcase.HVCasePK
		  ,hvcase.tcdob
		  ,gestationalage
		  ,(((40-gestationalage)*7)+hvcase.tcdob) cdob
		  ,eventDescription
		  ,case
			   when interval < 24 then
				   dateadd(dd,dueby,(((40-gestationalage)*7)+hvcase.tcdob))
			   else
				   dateadd(dd,dueby,hvcase.tcdob)
		   end DueDate
		  ,rtrim(tcfirstname)+' '+rtrim(tclastname) TargetChild
		  ,rtrim(fsw.firstname)+' '+rtrim(fsw.lastname) fswname
		  ,ltrim(rtrim(supervisor.firstname))+' '+ltrim(rtrim(supervisor.lastname)) as supervisor		  
		from caseprogram
			inner join hvcase on hvcasepk = caseprogram.hvcasefk
			inner join tcid on tcid.hvcasefk = hvcasepk and tcid.programfk = caseprogram.programfk AND TCID.TCDOD IS NULL
			--inner join appoptions on caseprogram.programfk = appoptions.programfk and optionitem = 'asq version'
			inner join codeduebydates on scheduledevent = 'ASQ' --optionValue
			inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			inner join worker fsw on fsw.workerpk = currentfswfk
			inner join workerprogram on workerfk = fsw.workerpk AND workerprogram.programfk = listitem
			inner join worker supervisor on supervisorfk = supervisor.workerpk
			left join asq on asq.hvcasefk = hvcasepk and asq.programfk = caseprogram.programfk and codeduebydates.interval = TCAge
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
		order by hvcase.HVCasePK

;


WITH cteLastHighestASQ AS
(
SELECT 
		asqt.HVCasePK			 
	  , max(TCAge) AS Interval
 
  FROM @tblASQTicklerSummaryCohort asqt  
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
	  FROM @tblASQTicklerSummaryCohort cc
INNER  JOIN cteLastHighestASQ cl ON cl.HVCasePK = cc.HVCasePK
LEFT   JOIN ASQ asqq ON cl.HVCasePK = asqq.HVCaseFK -- OR asqq.HVCaseFK IS null
WHERE  
	(asqq.TCAge  = cl.Interval OR cl.Interval IS NULL)
	AND
	(asqq.ASQTCReceiving = 1 AND  EventDescription LIKE '%optional%')
	
)

--SELECT * from cteCohort
--SELECT * from cteExcludeOptionalsIfCasesAreASQTCReceivingIsYes

SELECT DISTINCT 
		PC1ID
	 , cc.HVCasePK
	 , TCDOB
	 , GestationalAge
	 , cdob
	 , CASE WHEN asqq.ASQTCReceiving = 1 THEN 'Please contact EI program for update'
		 ELSE 
		EventDescription
		END AS EventDescription
	 , DueDate
	 , TargetChild
	 , fswname
	 , supervisor	 
	 --, cl.Interval
	 --, asqq.ASQTCReceiving 
	 
	  FROM @tblASQTicklerSummaryCohort cc
INNER  JOIN cteLastHighestASQ cl ON cl.HVCasePK = cc.HVCasePK
LEFT   JOIN ASQ asqq ON cl.HVCasePK = asqq.HVCaseFK -- OR asqq.HVCaseFK IS null

WHERE  
	(asqq.TCAge  = cl.Interval OR cl.Interval IS NULL)
	AND
	cc.HVCasePK NOT IN (SELECT HVCasePK FROM cteExcludeOptionalsIfCasesAreASQTCReceivingIsYes)

order by fswname ,DueDate


GO
