SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Jay Robohn
-- Create date: July 18, 2012
-- Description:	Return workers who are working at a specified program
--				This now just calls the common spGetAllWorkersByProgram stored proc
-- Test: exec spGetWorkersbyProgramPK 30
-- =============================================

CREATE procedure [dbo].[spGetWorkersbyProgramPK]
(
    @ProgramPK int
)
as
	set nocount on;

	exec spGetAllWorkersbyProgram @ProgramPK
	--select w.LastName
	--	  ,w.FirstName
	--	  ,w.WorkerPK
	--from Worker w
	--inner join WorkerProgram wp on wp.WorkerFK = w.WorkerPK
	--where w.LoginCreated = 0
	--		 and wp.ProgramFK = @ProgramPK
	--		 and w.FirstName not in ('Historical','Rensselaer','In State','Out of State')
	--		 and wp.TerminationDate is null
GO
