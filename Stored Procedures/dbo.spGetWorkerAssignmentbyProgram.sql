SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 5/24/2012
-- Description:	Newer Worker Assignment for transferred cases
-- =============================================
CREATE procedure [dbo].[spGetWorkerAssignmentbyProgram]
	-- Add the parameters for the stored procedure here
	@HVCaseFK as int
  , @ProgramFK as int
as
	begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
		set nocount on;

    -- Insert statements for procedure here
	with cteCaseProgram as
		(select max(CaseProgramPK) as CaseProgramPK
				, HVCaseFK
			from CaseProgram cp
			where HVCaseFK = @HVCaseFK
					and ProgramFK = @ProgramFK
			group by HVCaseFK)

		select WorkerAssignmentPK
			  , wa.HVCaseFK
			  , wa.ProgramFK
			  , convert(varchar, WorkerAssignmentDate, 101) as WrkrAssignmentDate
			  , WorkerFK
			  , rtrim(FirstName) + ' ' + rtrim(LastName) as WorkerName
			  , CaseProgramPK
			  , WorkerAssignmentDate
		from	WorkerAssignment wa
		inner join cteCaseProgram ccp on wa.HVCaseFK = ccp.HVCaseFK
		inner join Worker on Worker.WorkerPK = wa.WorkerFK
		where	wa.HVCaseFK = @HVCaseFK
				and wa.ProgramFK = @ProgramFK
		order by WorkerAssignmentDate desc;
	end;
GO
