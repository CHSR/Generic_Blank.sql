SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 11, 2012>
-- Description:	<Copied originally from FamSys - see header below> <Get list of all Supervisors by Program>
-- =============================================
CREATE procedure [dbo].[spGetWorkersbyProgram]
    @ProgramFK int = null
as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

	exec spGetAllWorkersbyProgram @ProgramFK
	-- Insert statements for procedure here
	--select FirstName
	--	  ,LastName
	--	  ,WorkerPK
	--	from Worker
	--		left join WorkerProgram on WorkerProgram.WorkerFK = Worker.WorkerPK
	--	where WorkerProgram.ProgramFK = @ProgramFK
	--	order by LastName
	--			,FirstName
end
GO
