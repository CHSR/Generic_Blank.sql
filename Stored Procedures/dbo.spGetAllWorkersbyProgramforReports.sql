SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:    Dorothy Baum
-- Create date: Sept 23, 2010
-- Description: Return all workers, who are performing role,
--				for use in reports.
-- exec spGetAllWorkersbyProgramforReports 1, 'FSW'
-- =============================================

CREATE procedure [dbo].[spGetAllWorkersbyProgramforReports]
    @ProgramFK  int            = null,
    @WorkerType varchar(20)    = null
as

	set nocount on;

	exec spGetAllWorkersbyProgram @ProgramFK, null, @WorkerType, 0
	-- exec spGetAllWorkersbyProgram @ProgramFK, '19800101', @WorkerType, 1

--select rtrim(LastName) + ', ' + rtrim(FirstName) as WorkerName, FirstName, LastName, WorkerPK from 
--  (select *, 'FAW' as workertype
--  from worker
--  inner join workerprogram
--  on workerpk=workerfk
--  where programfk=@programfk and faw = 1
--union all
--  select *, 'FSW' as workertype
--  from worker
--  inner join workerprogram
--  on workerpk=workerfk
--  where programfk=@programfk and fsw = 1
--union all
--  select *, 'SUP' as workertype
--  from worker
--  inner join workerprogram
--  on workerpk=workerfk
--  where programfk=@programfk and supervisor = 1
--union all
--  select *, 'PGM' as workertype
--  from worker
--  inner join workerprogram
--  on workerpk=workerfk
--  where programfk=@programfk and programmanager = 1)a
--where workertype=@workertype
--order by LastName, FirstName
GO
