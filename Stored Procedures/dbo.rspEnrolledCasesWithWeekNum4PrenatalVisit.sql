SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:         <Devinder Singh Khalsa>
-- Create date: <Jyly 16th, 2012>
-- Description:    <gets you data for Enrolled Program Caseload Quarterly and Contract Period>
-- exec [rspEnrolledCasesWithWeekNum4PrenatalVisit] ',27,','10/01/2013','07/30/2014'
-- =============================================
create procedure [dbo].[rspEnrolledCasesWithWeekNum4PrenatalVisit](@programfk    varchar(max)    = null,
                                                        @sdate        datetime,
                                                        @edate        datetime                                                     
                                                        )

as
BEGIN

with cteMain
as
(

SELECT 
h.HVCasePK
,PC1ID 
,h.IntakeDate
,h.tcdob as dob
,h.edc
,case
   when h.tcdob is not null then
        h.tcdob
   else
        h.edc
end as tcdob


,ca.ReceivingPreNatalCare 
,h.FirstPrenatalCareVisitUnknown
,ca.FormType


,h.FirstPrenatalCareVisit
,40 - datediff(week,h.FirstPrenatalCareVisit,
case
   when h.tcdob is not null then
        h.tcdob
   else
        h.edc
end
) as weekNumber

FROM HVCase h 
INNER JOIN CaseProgram cp ON h.HVCasePK = cp.HVCaseFK 
inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem     
LEFT JOIN CommonAttributes ca ON ca.hvcasefk = h.hvcasepk 

WHERE IntakeDate IS NOT NULL 
AND IntakeDate between @sdate and @edate
and tcdob between @sdate and @edate
and ca.FormType in ('TC')
and tcdob is not null
)



SELECT * FROM  cteMain 
order by HVCasePK  


-- exec [rspEnrolledCasesWithWeekNum4PrenatalVisit] ',27,','10/01/2013','07/30/2014'








END


GO
