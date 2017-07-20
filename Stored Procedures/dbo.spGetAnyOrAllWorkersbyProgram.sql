SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--[spGetAnyOrAllWorkersbyProgram] 1, 'FAW,FSW'

-- =============================================
-- Author:		Devinder Singh Khalsa
-- Create date: Oct. 5th, 2011
-- Description:	Return any or all workers, who are performing role,
--				for use in Supervision and Training
-- Modified: jrobohn 2012-07-24 - just calls the common spGetAllWorkersByProgram stored proc
-- =============================================

CREATE procedure [dbo].[spGetAnyOrAllWorkersbyProgram]
    @ProgramFK  int            = null,
    @WorkerType varchar(18)    = null
as

	set nocount on;

	exec spGetAllWorkersbyProgram @ProgramFK, null, @WorkerType

---- using common table expressions (CTE's)
--WITH Workers4GivenRolesAndProgram (LastName, FirstName, WorkerPK, workertype) AS
--( 

--select * from 
--	(select LastName, FirstName, WorkerPK, 'FAW' as workertype
--	from worker
--	inner join workerprogram
--	on workerpk=workerfk
--	where programfk=@programfk and faw = 1
--union all
--	select LastName, FirstName, WorkerPK, 'FSW' as workertype
--	from worker
--	inner join workerprogram
--	on workerpk=workerfk
--	where programfk=@programfk and fsw = 1
--union all
--	select LastName, FirstName, WorkerPK, 'SUP' as workertype
--	from worker
--	inner join workerprogram
--	on workerpk=workerfk
--	where programfk=@programfk and supervisor = 1
--union all
--	select LastName, FirstName, WorkerPK, 'PGM' as workertype
--	from worker
--	inner join workerprogram
--	on workerpk=workerfk
--	where programfk=@programfk and programmanager = 1)a
--where workertype IN (select * from dbo.SplitString(@workertype,','))
--)

--SELECT DISTINCT LastName, FirstName, WorkerPK from Workers4GivenRolesAndProgram
--ORDER BY LastName, FirstName
GO
