SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[spGetAllTerminatedWorkers]
  @ProgramFK  int = NULL
as

set nocount on
SELECT c.ProgramName
, a.LastName, a.FirstName
, convert(varchar(12), b.TerminationDate, 101) [TerminationDate]
, CASE WHEN b.FAWStartDate IS NOT NULL THEN 'FAW ' ELSE '' END +
CASE WHEN b.FSWStartDate IS NOT NULL THEN 'FSW ' ELSE '' END +
CASE WHEN b.FatherAdvocateStartDate IS NOT NULL THEN 'FAdv ' ELSE '' END +
CASE WHEN b.SupervisorStartDate IS NOT NULL THEN 'SUP ' ELSE '' END +
CASE WHEN b.ProgramManagerStartDate IS NOT NULL THEN 'PM ' ELSE '' END [Roles]
, b.ProgramFK
, a.WorkerPK
, b.WorkerProgramPK
FROM Worker AS a
JOIN WorkerProgram AS b ON a.WorkerPK = b.WorkerFK
JOIN HVProgram AS c ON c.HVProgramPK = b.ProgramFK
WHERE b.TerminationDate IS NOT NULL
AND ProgramFK = isnull(@ProgramFK, ProgramFK)
AND (LastName NOT LIKE 'Supervisor%' AND FirstName NOT LIKE 'Historical%')
ORDER BY c.ProgramName, a.LastName, a.FirstName






GO
