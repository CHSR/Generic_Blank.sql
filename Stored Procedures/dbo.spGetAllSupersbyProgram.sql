SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Chris Papas
-- Create date: <02/09/2010>
-- Description: <Get list of all Supervisors by Program>
-- Modified: jrobohn 2012-07-24 - just calls the common spGetAllWorkersByProgram stored proc
-- =============================================
CREATE procedure [dbo].[spGetAllSupersbyProgram]
    @ProgramFK  int = null,
    @Supervisor bit = false
as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

	exec spGetAllWorkersbyProgram @ProgramFK, null, 'Sup'

	-- Insert statements for procedure here
	--select FirstName
	--	  ,LastName
	--	  ,WorkerPK
	--	from Worker
	--		left join WorkerProgram on WorkerProgram.WorkerFK = Worker.WorkerPK
	--	where WorkerProgram.Supervisor = 'TRUE'
	--		 and WorkerProgram.ProgramFK = @ProgramFK
end
GO
