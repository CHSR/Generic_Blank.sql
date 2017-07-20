SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Chris Papas
-- Create date: 08/23/2010
-- Description:	Complete list of workers and their details (mostly for conversion data checking)
--				Moved from FamSys - 02/05/12 jrobohn
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
-- =============================================
CREATE procedure [dbo].[rspWorkerInfoList]
(@programfk int)
-- Add the parameters for the stored procedure here
as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

	-- Insert statements for procedure here
	select distinct
				   FirstName
				  ,LastName
				  ,FAW
				  ,FAWStartDate
				  ,FAWEndDate
				  ,FSW
				  ,FSWStartDate
				  ,FSWEndDate
				  ,WorkerProgram.ProgramManager
				  ,ProgramManagerStartDate
				  ,ProgramManagerEndDate
				  ,Supervisor
				  ,SupervisorStartDate
				  ,SupervisorEndDate
				  ,(select rtrim(FirstName)+' '+rtrim(LastName)
						from Worker
						where WorkerPK = SupervisorFK) as SupName
				  ,HVPROGRAM.ProgramName as Program_Name
				  ,HVPROGRAM.ProgramManager
				  ,HVProgram.HVProgramPK
				  ,HireDate
				  ,TerminationDate
		from Worker
			left join WorkerProgram on WorkerProgram.WorkerFK = Worker.WorkerPK AND WorkerProgram.ProgramFK=@programfk
			left join HVPROGRAM on WorkerProgram.ProgramFK = HVProgram.HVProgramPK
		where programfk = @programfk
		order by Program_Name desc
end
GO
