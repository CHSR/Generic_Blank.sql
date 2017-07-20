SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 8/16/2012
-- Description:	Report: Training Required Topics
-- EXEC rspTrainReqTopics 1, NULL, NULL
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
-- Edit date: 6/12/2015 CP - Changes for new HFA standards
-- =============================================

--exec dbo.rspTrainReqTopics @prgfk=1,@super=NULL,@worker=151


CREATE procedure [dbo].[rspTrainReqTopics]
	-- Add the parameters for the stored procedure here
	@prgfk AS INT,
	@super AS INT,
	@worker AS INT	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


declare @workerstring as nvarchar(max) = null

    -- Insert statements for procedure here

if @worker is null
	begin --get worker list for program
		select @workerstring = substring((SELECT ','+ltrim(rtrim(str(workerfk)))
									from WorkerProgram wp where wp.ProgramFK=@prgfk
									for xml path ('')),2,8000)
	end


if @worker is NOT null
	begin --get worker list for program
		select @workerstring = @worker
	END
	
	--print @worker	

;with ctWorkerTable as
(
 select workerpk from Worker 
	inner join dbo.SplitString(@workerstring, ',') on Worker.WorkerPK=ListItem
)

  
,ctAttendee AS
(
SELECT t.TrainingPK
	 , t.TrainingDate
	 , ta.WorkerFK
	 , td.SubTopicFK
	 , td.topicfk
	 , codetopic.topiccode
	 , st.SubTopicName
	 , t.IsExempt
FROM Training t
INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK 
INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK
INNER JOIN ctWorkerTable w ON w.WorkerPK = ta.workerfk
INNER JOIN WorkerProgram wp ON wp.WorkerFK=w.WorkerPK  AND wp.ProgramFK=@prgfk
RIGHT JOIN codetopic ON codetopic.codeTopicPK = td.topicfk
left JOIN SubTopic st ON st.SubTopicPK=td.SubTopicFK
where ta.WorkerFK is not null
 
)



, ctMain AS
(
SELECT rtrim(FirstName) + ' ' + rtrim(LastName) AS Name
, fn.WorkerPK
, fn.FAWInitialStart
, fn.SupervisorInitialStart
, fn.FSWInitialStart
, fn.TerminationDate
, fn.HireDate
, fn.FirstASQDate
, fn.FirstHomeVisitDate
, fn.FirstKempeDate
, fn.FirstEvent
, fn.SupervisorFirstEvent
, fn.FirstPSIDate
, fn.FirstPHQDate
, fn.firstHITSDate
, fn.firstAuditCDate
, (SELECT min(trainingdate) FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode='1.0') AS 'f1'
, (SELECT min(trainingdate) FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode='2.0' AND ctA.SubTopicFK IS Null) AS 'f2'
, (SELECT min(trainingdate) FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=65) AS 'f2a'
, (SELECT min(trainingdate) FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=66) AS 'f2b'
, (SELECT min(trainingdate) FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=67) AS 'f2c'
, (SELECT min(trainingdate) FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode='3.0') AS 'f3'
, (SELECT min(trainingdate) FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode='4.0') AS 'f4'
, (SELECT min(trainingdate) FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode='5.0') AS 'f5'
, (SELECT min(trainingdate) FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode='5.5') AS 'f5.5'
, (SELECT min(trainingdate) FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode='6.0') AS 'f6'
, (SELECT min(trainingdate) FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode='7.0') AS 'f7'
, (SELECT min(trainingdate) FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode='7.1') AS 'f7a'
, (SELECT min(trainingdate) FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode='8.0') AS 'f8'
, (SELECT min(trainingdate) FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode='9.0') as 'f9'
, (SELECT min(trainingdate) FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode='9.1') as 'f9.1'
, (SELECT min(trainingdate) FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode='10.0') AS 'f10'
	
	--HW997 Training Tickler and Required Topics - Remove Subtopic 82
--, (SELECT min(trainingdate) FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=82) AS 'f10a'
	--END HW997	
, (SELECT min(trainingdate) FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode='11.0') as 'f11'
, (SELECT min(trainingdate) FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode='12.0') as 'f12'
, (SELECT min(trainingdate) FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode='12.1') as 'f12.1'
, (SELECT min(trainingdate) FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode='13.0') as 'f13'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=1) AS 'f14a'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=2) AS 'f14b'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=3) AS 'f14c'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=4) AS 'f14d'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=5) AS 'f15a'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=6) AS 'f15b'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=7) AS 'f15c'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=8) AS 'f15d'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=9) AS 'f15e'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=10) AS 'f15f'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=11) AS 'f15g'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=12) AS 'f15h'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=13) AS 'f15i'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=14) AS 'f16a'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=15) AS 'f16b'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=16) AS 'f16c'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=17) AS 'f16d'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=18) AS 'f16e'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=19) AS 'f16f'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=3289) AS 'f16g'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=20) AS 'f17a'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=21) AS 'f17b'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=22) AS 'f17c'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=70) AS 'f17d'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=23) AS 'f17e' 
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=24) AS 'f18a'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=25) AS 'f18b'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=26) AS 'f18c'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=27) AS 'f19a'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=28) AS 'f19b'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=29) AS 'f19c'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=30) AS 'f19d'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=31) AS 'f19e'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=32) AS 'f19f'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=33) AS 'f20a'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=34) AS 'f20b'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=35) AS 'f21a'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=36) AS 'f21b'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=37) AS 'f21c'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=38) AS 'f21d'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=76) AS 'f21e'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=83) AS 'f21f'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=84) AS 'f21g'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=39) AS 'f22a'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=40) AS 'f22b'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=71) AS 'f22c'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=41) AS 'f22d'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=42) AS 'f22e'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=43) AS 'f22f'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=44) AS 'f22g'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=45) AS 'f22h'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=46) AS 'f23a'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=47) AS 'f23b'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=48) AS 'f23c'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=49) AS 'f23d'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=50) AS 'f23e'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=51) AS 'f23f'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=52) AS 'f24a'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=53) AS 'f24b'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=54) AS 'f24c'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=55) AS 'f24d'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=56) AS 'f24e'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=57) AS 'f24f'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=58) AS 'f25a'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=59) AS 'f25b'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=60) AS 'f25c'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=61) AS 'f25d'
, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN '01/01/1901' ELSE min(trainingdate) END AS ccc  FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=62) AS 'f25e'
--CP 6/12/2015 Adding New HFA Required topics-----------------
, (SELECT min(trainingdate) FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode='39.0') AS 'f39'
, (SELECT min(trainingdate) FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode='40.0') AS 'f40'
, (SELECT min(trainingdate) FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode='41.0') AS 'f41'
, (SELECT min(trainingdate) FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode='42.0') AS 'f42'
, (SELECT min(trainingdate) FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode='43.0') AS 'f43'
, (SELECT min(trainingdate) FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode='44.0') AS 'f44'
, (SELECT min(trainingdate) FROM ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode='45.0') AS 'f45'

-------END CP 6/12/2015 Adding New HFA Required topics ---------------
FROM Worker w
INNER JOIN dbo.fnGetWorkerEventDates(@prgfk, @super, @worker) fn ON fn.workerpk = w.workerpk
)

SELECT distinct [Name]
	 , [WorkerPK]
	 , convert(VARCHAR(12), [FAWInitialStart], 101) AS [FAWInitialStart]
	 , convert(VARCHAR(12), [SupervisorInitialStart], 101) AS [SupervisorInitialStart]
	 , convert(VARCHAR(12), [SupervisorFirstEvent], 101) AS [SupervisorFirstEvent]
	 , convert(VARCHAR(12), [TerminationDate], 101) AS [TerminationDate]
	 , convert(VARCHAR(12), [HireDate], 101) AS HireDate
	 , convert(VARCHAR(12), [FirstASQDate], 101) AS [FirstASQDate]
	 , convert(VARCHAR(12), [FirstHomeVisitDate], 101) AS [FirstHomeVisitDate]
	 , convert(VARCHAR(12), [FirstKempeDate], 101) AS [FirstKempeDate]
	 , convert(VARCHAR(12), [FirstEvent], 101) AS [FirstEvent]
	 , convert(VARCHAR(12), [FirstEvent], 101) AS [FirstEvent]
	 , convert(VARCHAR(12), [FirstPSIDate], 101) AS [FirstPSIDate]
	 , convert(VARCHAR(12), [FirstPHQDate], 101) AS [FirstPHQDate]
	 , CONVERT(VARCHAR(12), [FirstHITSDate], 101) AS [FirstHITSDate]
	 , CONVERT(VARCHAR(12), [FirstAuditCDate], 101) AS [FirstAuditCDate]
	 , convert(VARCHAR(12), [f1], 101) AS [f1]
	 , CASE isnull([f1], 0)
		WHEN [f1] THEN
			CASE WHEN datediff(dd, [f1], [FirstEvent]) < 0 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f1_ast'	 
	 , convert(VARCHAR(12), [f2], 101) AS [f2]
	 , CASE isnull([f2], 0)
		WHEN [f2] THEN
			CASE WHEN datediff(dd, [f2], [FirstEvent]) < 0 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f2_ast'
	 , convert(VARCHAR(12), [f2a], 101) AS [f2a]
	 , CASE isnull([f2a], 0)
		WHEN [f2a] THEN
			CASE WHEN datediff(dd, [f2a], [FirstEvent]) < 0 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f2a_ast'
	 , convert(VARCHAR(12), [f2b], 101) AS [f2b]
	 , CASE isnull([f2b], 0)
		WHEN [f2b] THEN
			CASE WHEN datediff(dd, [f2b], [FirstEvent]) < 0 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f2b_ast'
	 , convert(VARCHAR(12), [f2c], 101) AS [f2c]
	 , CASE isnull([f2c], 0)
		WHEN [f2c] THEN
			CASE WHEN datediff(dd, [f2c], [FirstEvent]) < 0 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f2c_ast'
	 , convert(VARCHAR(12), [f3], 101) AS [f3]
	 , CASE isnull([f3], 0)
		WHEN [f3] THEN
			CASE WHEN datediff(dd, [f3], [FirstEvent]) < 0 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f3_ast'
	 , convert(VARCHAR(12), [f4], 101) AS [f4]
	 , CASE isnull([f4], 0)
		WHEN [f4] THEN
			CASE WHEN datediff(dd, [f4], [FirstEvent]) < 0 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f4_ast'
	 , convert(VARCHAR(12), [f5], 101) AS [f5]
	 , CASE isnull([f5], 0)
		WHEN [f5] THEN
			CASE WHEN datediff(dd, [f5], [FirstEvent]) < 0 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f5_ast'
	 , convert(VARCHAR(12), [f5.5], 101) AS [f5.5]
	 , CASE isnull([f5.5], 0)
		WHEN [f5.5] THEN
			CASE WHEN datediff(dd, [f5.5], [FirstEvent]) < 0 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f5.5_ast'
	 , convert(VARCHAR(12), [f6], 101) AS [f6]
	 , CASE isnull([f6], 0)
		WHEN [f6] THEN
			CASE WHEN datediff(dd, [f6], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f6_ast'
	 , convert(VARCHAR(12), [f7], 101) AS [f7]
	 , CASE isnull([f7], 0)
		WHEN [f7] THEN
			CASE WHEN datediff(dd, [f7], [HireDate]) < -91 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f7_ast'
	 , convert(VARCHAR(12), [f7a], 101) AS [f7a]
	 , CASE isnull([f7a], 0)
		WHEN [f7a] THEN
			CASE WHEN datediff(dd, [f7a], [HireDate]) < -91 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f7.1_ast'
	 , convert(VARCHAR(12), [f8], 101) AS [f8]
	 , CASE isnull(FSWInitialStart,0)
		WHEN 0 THEN '' --do nothing as 8.0 is only for FSW's
		ELSE 
			CASE WHEN datediff(dd, [f8], [FirstHomeVisitDate]) < 0 THEN '*' END
		END AS 'f8_ast' 
	 , convert(VARCHAR(12), [f9], 101) AS [f9]
	 , CASE isnull(FAWInitialStart,0)
		WHEN 0 THEN '' --do nothing as 9.0 is only for FSW's
		ELSE 
			CASE WHEN datediff(dd, [f9], [FirstKempeDate]) < 0 THEN '*' END
		END AS 'f9_ast' 
	 , convert(VARCHAR(12), [f9.1], 101) AS [f9_1]
	 , CASE isnull(SupervisorInitialStart,0)
		WHEN 0 THEN '' --do nothing as 9.1 is only for Supervisors
		ELSE 
			CASE WHEN datediff(dd, [f9.1], [SupervisorFirstEvent]) < 0 THEN '*' END
		END AS 'f9_1_ast' 
	 , convert(VARCHAR(12), [f10], 101) AS [f10]
	 , CASE isnull(FAWInitialStart,0)
		WHEN 0 THEN '' --do nothing as 9.0 is only for FAW's
		ELSE 
			CASE WHEN datediff(dd, [f10], [FAWInitialStart]) < -183 THEN '*' END
		END AS 'f10_ast'
	
	--HW997 Training Tickler and Required Topics - Remove Subtopic 82
	 --, convert(VARCHAR(12), [f10a], 101) AS [f10a]
	 --, CASE isnull(FAWInitialStart,0)
		--WHEN 0 THEN '' --do nothing as 9.0 is only for FAW's
		--ELSE 
		--	CASE WHEN datediff(dd, [f10a], [FAWInitialStart]) < -183 THEN '*' END
		--END AS 'f10a_ast'
	--END HW997	
		
	 , convert(VARCHAR(12), [f11], 101) AS [f11]
	 , CASE isnull(FSWInitialStart,0)
		WHEN 0 THEN '' --do nothing as 9.0 is only for FSW's
		ELSE 
			CASE WHEN datediff(dd, [f11], [FSWInitialStart]) < -183 THEN '*' END
		END AS 'f11a_ast'
	 , convert(VARCHAR(12), [f12], 101) AS [f12]
	 , CASE isnull(SupervisorInitialStart,0)
		WHEN 0 THEN '' --do nothing as 12 is only for Supervisors
		ELSE 
			CASE WHEN datediff(dd, [f12], [SupervisorInitialStart]) < -183 THEN '*' END
		END AS 'f12_ast'
	 , convert(VARCHAR(12), [f12.1], 101) AS [f12_1]
	 , CASE isnull(SupervisorInitialStart,0)
		WHEN 0 THEN '' --do nothing as 12 is only for Supervisors
		ELSE 
			CASE WHEN datediff(dd, [f12.1], [SupervisorInitialStart]) < -183 THEN '*' END
		END AS 'f12_1_ast'
	 , convert(VARCHAR(12), [f13], 101) AS [f13]
	 , CASE isnull(FSWInitialStart,0)
		WHEN 0 THEN '' --do nothing as 13 ASQ is only for FSW's
		ELSE 
			CASE WHEN datediff(dd, [f13], [firstasqdate]) < 0 THEN '*' END
		END AS 'f13_ast'
	
 , convert(VARCHAR(12), [f39], 101) AS [f39]
	 , CASE isnull([f39], 0)
		WHEN [f39] THEN
			CASE WHEN datediff(dd, [f39], [FirstPHQDate]) < -1 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f39_ast'

 , convert(VARCHAR(12), [f40], 101) AS [f40]
	 , CASE isnull([f40], 0)
		WHEN [f40] THEN
			CASE WHEN datediff(dd, [f40], [HireDate]) < -91 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f40_ast'

 , convert(VARCHAR(12), [f41], 101) AS [f41]
	 , CASE isnull([f41], 0)
		WHEN [f41] THEN
			CASE WHEN datediff(dd, [f41], [HireDate]) < -91 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f41_ast'
	
 , convert(VARCHAR(12), [f42], 101) AS [f42]
	 , CASE isnull([f42], 0)
		WHEN [f42] THEN
			CASE WHEN datediff(dd, [f42], GETDATE()) < -365 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f42_ast'
			
 , convert(VARCHAR(12), [f43], 101) AS [f43]
 	 , CASE isnull(FirstPSIDate,0)
		WHEN 0 THEN '' --do nothing as 43 are only for people completing PSI's
		ELSE 
			CASE WHEN datediff(dd, [f43], [HireDate]) < -91 THEN '*' 
			ELSE '' END
		END AS 'f43_ast'	
	
 , convert(VARCHAR(12), [f44], 101) AS [f44]
	 , CASE isnull([f44], 0)
		WHEN [f44] THEN
			CASE WHEN datediff(dd, [f44], [firstHITSDate]) < 0 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f44_ast'		
		
 , convert(VARCHAR(12), [f45], 101) AS [f45]
	 , CASE isnull([f45], 0)
		WHEN [f45] THEN
			CASE WHEN datediff(dd, [f45], [firstAuditCDate]) < 0 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f45_ast'
	
	
	
	
	
	
	
	
	 , CASE [f14a] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f14a], 101) END AS [f14a]
	 , CASE isnull([f14a], 0)
		WHEN [f14a] THEN
			CASE WHEN datediff(dd, [f14a], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f14a_ast'
	 , CASE [f14b] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f14b], 101) END AS [f14b]
	 , CASE isnull([f14b], 0)
		WHEN [f14b] THEN
			CASE WHEN datediff(dd, [f14b], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f14b_ast'
	 , CASE [f14c] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f14c], 101) END AS [f14c]
	 , CASE isnull([f14c], 0)
		WHEN [f14c] THEN
			CASE WHEN datediff(dd, [f14c], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f14c_ast'
	 , CASE [f14d] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f14d], 101) END AS [f14d]
	 , CASE isnull([f14d], 0)
		WHEN [f14d] THEN
			CASE WHEN datediff(dd, [f14d], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f14d_ast'
	 , CASE [f15a] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f15a], 101) END AS [f15a]
	 , CASE isnull([f15a], 0)
		WHEN [f15a] THEN
			CASE WHEN datediff(dd, [f15a], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f15a_ast'
	 , CASE [f15b] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f15b], 101) END AS [f15b]
	 , CASE isnull([f15b], 0)
		WHEN [f15b] THEN
			CASE WHEN datediff(dd, [f15b], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f15b_ast'
	 , CASE [f15c] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f15c], 101) END AS [f15c]
	 , CASE isnull([f15c], 0)
		WHEN [f15c] THEN
			CASE WHEN datediff(dd, [f15c], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f15ac_ast'
	 , CASE [f15d] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f15d], 101) END AS [f15d]
	 , CASE isnull([f15d], 0)
		WHEN [f15d] THEN
			CASE WHEN datediff(dd, [f15d], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f15d_ast'
	 , CASE [f15e] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f15e], 101) END AS [f15e]
	 , CASE isnull([f15e], 0)
		WHEN [f15e] THEN
			CASE WHEN datediff(dd, [f15e], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f15e_ast'
	 , CASE [f15f] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f15f], 101) END AS [f15f]
	 , CASE isnull([f15f], 0)
		WHEN [f15f] THEN
			CASE WHEN datediff(dd, [f15f], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f15f_ast'
	 , CASE [f15g] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f15g], 101) END AS [f15g]
	 , CASE isnull([f15g], 0)
		WHEN [f15g] THEN
			CASE WHEN datediff(dd, [f15g], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f15g_ast'
	 , CASE [f15h] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f15h], 101) END AS [f15h]
	 , CASE isnull([f15h], 0)
		WHEN [f15h] THEN
			CASE WHEN datediff(dd, [f15h], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f15h_ast'
	 , CASE [f15i] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f15i], 101) END AS [f15i]
	 , CASE isnull([f15i], 0)
		WHEN [f15i] THEN
			CASE WHEN datediff(dd, [f15i], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f15i_ast'
	 , CASE [f16a] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f16a], 101) END AS [f16a]
	 , CASE isnull([f16a], 0)
		WHEN [f16a] THEN
			CASE WHEN datediff(dd, [f16a], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f16a_ast'
	 , CASE [f16b] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f16b], 101) END AS [f16b]
	 , CASE isnull([f16b], 0)
		WHEN [f16b] THEN
			CASE WHEN datediff(dd, [f16b], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f16b_ast'
	 , CASE [f16c] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f16c], 101) END AS [f16c]
	 , CASE isnull([f16c], 0)
		WHEN [f16c] THEN
			CASE WHEN datediff(dd, [f16c], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f16c_ast'
	 , CASE [f16d] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f16d], 101) END AS [f16d] 
	 , CASE isnull([f16d], 0)
		WHEN [f16d] THEN
			CASE WHEN datediff(dd, [f16d], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f16d_ast'
	 , CASE [f16e] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f16e], 101) END AS [f16e]
	 , CASE isnull([f16e], 0)
		WHEN [f16e] THEN
			CASE WHEN datediff(dd, [f16e], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f16e_ast'
	 , CASE [f16f] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f16f], 101) END AS [f16f]
	 , CASE isnull([f16f], 0)
		WHEN [f16f] THEN
			CASE WHEN datediff(dd, [f16f], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f16f_ast'
	 , CASE [f16g] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f16g], 101) END AS [f16g]
	 , CASE isnull([f16g], 0)
		WHEN [f16g] THEN
			CASE WHEN datediff(dd, [f16g], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f16g_ast'
	 , CASE [f17a] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f17a], 101) END AS [f17a]
	 , CASE isnull([f17a], 0)
		WHEN [f17a] THEN
			CASE WHEN datediff(dd, [f17a], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f17a_ast'
	 , CASE [f17b] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f17b], 101) END AS [f17b]
	 , CASE isnull([f17b], 0)
		WHEN [f17b] THEN
			CASE WHEN datediff(dd, [f17b], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f17b_ast'
	 , CASE [f17c] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f17c], 101) END AS [f17c]
	 , CASE isnull([f17c], 0)
		WHEN [f17c] THEN
			CASE WHEN datediff(dd, [f17c], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f17c_ast'
	 , CASE [f17d] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f17d], 101) END AS [f17d]
	 , CASE isnull([f17d], 0)
		WHEN [f17d] THEN
			CASE WHEN datediff(dd, [f17d], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f17d_ast'
	 , CASE [f17e] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f17e], 101) END AS [f17e] --there's no 'd' in this report
	 , CASE isnull([f17e], 0)
		WHEN [f17e] THEN
			CASE WHEN datediff(dd, [f17e], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f17e_ast'
	 , CASE [f18a] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f18a], 101) END AS [f18a]
	 , CASE isnull([f18a], 0)
		WHEN [f18a] THEN
			CASE WHEN datediff(dd, [f18a], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f18a_ast'
	 , CASE [f18b] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f18b], 101) END AS [f18b]
	 , CASE isnull([f18b], 0)
		WHEN [f18b] THEN
			CASE WHEN datediff(dd, [f18b], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f18b_ast'
	 , CASE [f18c] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f18c], 101) END AS [f18c]
	 , CASE isnull([f18c], 0)
		WHEN [f18c] THEN
			CASE WHEN datediff(dd, [f18c], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f18c_ast'
	 , CASE [f19a] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f19a], 101) END AS [f19a]
	 , CASE isnull([f19a], 0)
		WHEN [f19a] THEN
			CASE WHEN datediff(dd, [f19a], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f19a_ast'
	 , CASE [f19b] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f19b], 101) END AS [f19b]
	 , CASE isnull([f19b], 0)
		WHEN [f19b] THEN
			CASE WHEN datediff(dd, [f19b], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f19b_ast'
	 , CASE [f19c] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f19c], 101) END AS [f19c]
	 , CASE isnull([f19c], 0)
		WHEN [f19c] THEN
			CASE WHEN datediff(dd, [f19c], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f19c_ast'
	 , CASE [f19d] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f19d], 101) END AS [f19d]
	 , CASE isnull([f19d], 0)
		WHEN [f19d] THEN
			CASE WHEN datediff(dd, [f19d], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f19d_ast'
	 , CASE [f19e] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f19e], 101) END AS [f19e]
	 , CASE isnull([f19e], 0)
		WHEN [f19e] THEN
			CASE WHEN datediff(dd, [f19e], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f19e_ast'
	 , CASE [f19f] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f19f], 101) END AS [f19f]
	 , CASE isnull([f19f], 0)
		WHEN [f19f] THEN
			CASE WHEN datediff(dd, [f19f], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f19f_ast'
	 , CASE [f20a] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f20a], 101) END AS [f20a]
	 , CASE isnull([f20a], 0)
		WHEN [f20a] THEN
			CASE WHEN datediff(dd, [f20a], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f20a_ast'
	 , CASE [f20b] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f20b], 101) END AS [f20b]
	 , CASE isnull([f20b], 0)
		WHEN [f20b] THEN
			CASE WHEN datediff(dd, [f20b], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f20b_ast'
	 , CASE [f21a] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f21a], 101) END AS [f21a]
	 , CASE isnull([f21a], 0)
		WHEN [f21a] THEN
			CASE WHEN datediff(dd, [f21a], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f21a_ast'
	 , CASE [f21b] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f21b], 101) END AS [f21b]
	 , CASE isnull([f21b], 0)
		WHEN [f21b] THEN
			CASE WHEN datediff(dd, [f21b], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f21b_ast'
	 , CASE [f21c] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f21c], 101) END AS [f21c]
	 , CASE isnull([f21c], 0)
		WHEN [f21c] THEN
			CASE WHEN datediff(dd, [f21c], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f21c_ast'
	 , CASE [f21d] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f21d], 101) END AS [f21d]
	 , CASE isnull([f21d], 0)
		WHEN [f21d] THEN
			CASE WHEN datediff(dd, [f21d], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f21d_ast'
	 , CASE [f21e] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f21e], 101) END AS [f21e]
	 , CASE isnull([f21e], 0)
		WHEN [f21e] THEN
			CASE WHEN datediff(dd, [f21e], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f21e_ast'
	 , CASE [f21f] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f21f], 101) END AS [f21f]
	 , CASE isnull([f21f], 0)
		WHEN [f21f] THEN
			CASE WHEN datediff(dd, [f21f], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f21f_ast'
	 , CASE [f21g] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f21g], 101) END AS [f21g]
	 , CASE isnull([f21g], 0)
		WHEN [f21g] THEN
			CASE WHEN datediff(dd, [f21g], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f21g_ast'
	 , CASE [f22a] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f22a], 101) END AS [f22a]
	 , CASE isnull([f22a], 0)
		WHEN [f22a] THEN
			CASE WHEN datediff(dd, [f22a], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f22a_ast'
	 , CASE [f22b] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f22b], 101) END AS [f22b]
	 , CASE isnull([f22b], 0)
		WHEN [f22b] THEN
			CASE WHEN datediff(dd, [f22b], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f22b_ast'
	 , CASE [f22c] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f22c], 101) END AS [f22c]
	 , CASE isnull([f22c], 0)
		WHEN [f22c] THEN
			CASE WHEN datediff(dd, [f22c], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f22c_ast'
	 , CASE [f22d] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f22d], 101) END AS [f22d]
	 , CASE isnull([f22d], 0)
		WHEN [f22d] THEN
			CASE WHEN datediff(dd, [f22d], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f22d_ast'
	 , CASE [f22e] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f22e], 101) END AS [f22e]
	 , CASE isnull([f22e], 0)
		WHEN [f22e] THEN
			CASE WHEN datediff(dd, [f22e], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f22e_ast'
	 , CASE [f22f] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f22f], 101) END AS [f22f]
	 , CASE isnull([f22f], 0)
		WHEN [f22f] THEN
			CASE WHEN datediff(dd, [f22f], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f22f_ast'
	 , CASE [f22g] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f22g], 101) END AS [f22g]
	 , CASE isnull([f22g], 0)
		WHEN [f22g] THEN
			CASE WHEN datediff(dd, [f22g], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f22g_ast'
	 , CASE [f22h] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f22h], 101) END AS [f22h]
	 , CASE isnull([f22h], 0)
		WHEN [f22h] THEN
			CASE WHEN datediff(dd, [f22h], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f22h_ast'
	 , CASE [f23a] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f23a], 101) END AS [f23a]
	 , CASE isnull([f23a], 0)
		WHEN [f23a] THEN
			CASE WHEN datediff(dd, [f23a], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f23a_ast'
	 , CASE [f23b] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f23b], 101) END AS [f23b]
	 , CASE isnull([f23b], 0)
		WHEN [f23b] THEN
			CASE WHEN datediff(dd, [f23b], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f23b_ast'
	 , CASE [f23c] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f23c], 101) END AS [f23c]
	 , CASE isnull([f23c], 0)
		WHEN [f23c] THEN
			CASE WHEN datediff(dd, [f23c], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f23c_ast'
	 , CASE [f23d] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f23d], 101) END AS [f23d]
	 , CASE isnull([f23d], 0)
		WHEN [f23d] THEN
			CASE WHEN datediff(dd, [f23d], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f23d_ast'
	 , CASE [f23e] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f23e], 101) END AS [f23e]
	 , CASE isnull([f23e], 0)
		WHEN [f23e] THEN
			CASE WHEN datediff(dd, [f23e], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f23e_ast'
	 , CASE [f23f] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f23f], 101) END AS [f23f]
	 , CASE isnull([f23f], 0)
		WHEN [f23f] THEN
			CASE WHEN datediff(dd, [f23f], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f23f_ast'
	 , CASE [f24a] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f24a], 101) END AS [f24a]
	 , CASE isnull([f24a], 0)
		WHEN [f24a] THEN
			CASE WHEN datediff(dd, [f24a], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f24a_ast'
	 , CASE [f24b] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f24b], 101) END AS [f24b]
	 , CASE isnull([f24b], 0)
		WHEN [f24b] THEN
			CASE WHEN datediff(dd, [f24b], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f24b_ast'
	 , CASE [f24c] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f24c], 101) END AS [f24c]
	 , CASE isnull([f24c], 0)
		WHEN [f24c] THEN
			CASE WHEN datediff(dd, [f24c], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f24c_ast'
	 , CASE [f24d] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f24d], 101) END AS [f24d]
	 , CASE isnull([f24d], 0)
		WHEN [f24d] THEN
			CASE WHEN datediff(dd, [f24d], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f24d_ast'
	 , CASE [f24e] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f24e], 101) END AS [f24e]
	 , CASE isnull([f24e], 0)
		WHEN [f24e] THEN
			CASE WHEN datediff(dd, [f24e], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f24e_ast'
	 , CASE [f24f] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f24f], 101) END AS [f24f]
	 , CASE isnull([f24f], 0)
		WHEN [f24f] THEN
			CASE WHEN datediff(dd, [f24f], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f24f_ast'
	 , CASE [f25a] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f25a], 101) END AS [f25a]
	 , CASE isnull([f25a], 0)
		WHEN [f25a] THEN
			CASE WHEN datediff(dd, [f25a], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f25a_ast'
	 , CASE [f25b] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f25b], 101) END AS [f25b]
	 , CASE isnull([f25b], 0)
		WHEN [f25b] THEN
			CASE WHEN datediff(dd, [f25b], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f25b_ast'
	 , CASE [f25c] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f25c], 101) END AS [f25c]
	 , CASE isnull([f25c], 0)
		WHEN [f25c] THEN
			CASE WHEN datediff(dd, [f25c], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f25c_ast'
	 , CASE [f25d] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f25d], 101) END AS [f25d]
	 , CASE isnull([f25d], 0)
		WHEN [f25d] THEN
			CASE WHEN datediff(dd, [f25d], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f25d_ast'
	 , CASE [f25e] WHEN '01/01/1901' THEN 'EXEMPT' ELSE convert(VARCHAR(12), [f25e] , 101) END AS [f25e]
	 , CASE isnull([f25e], 0)
		WHEN [f25e] THEN
			CASE WHEN datediff(dd, [f25e], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f25e_ast'
FROM ctMain
WHERE ctMain.WorkerPK = isnull(@worker,ctMain.WorkerPK)
 ORDER BY Name
END

GO
