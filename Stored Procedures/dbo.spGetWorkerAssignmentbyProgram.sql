SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 5/24/2012
-- Description:	Newer Worker Assignment for transferred cases
-- =============================================
CREATE PROCEDURE [dbo].[spGetWorkerAssignmentbyProgram]
	-- Add the parameters for the stored procedure here
	@hvcasefk as INT,
	@programfk AS INT	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT DISTINCT WorkerAssignmentPK, workerassignment.HVCaseFK, workerassignment.ProgramFK, 
	CONVERT(varchar, WorkerAssignmentDate, 101) AS WrkrAssignmentDate, 
	WorkerFK, CurrentFSWFK, FirstName + ' ' + LastName AS WorkerName, CaseProgramPK, WorkerAssignmentDate
	FROM workerassignment 
	INNER JOIN CaseProgram ON workerassignment.HVCasefk=CaseProgram.HVcasefk
		AND CaseProgram.ProgramFK = @programfk
	INNER JOIN Worker ON Worker.WorkerPK = workerassignment.workerfk
	where workerassignment.hvcasefk=@hvcasefk
	AND WorkerAssignment.ProgramFK=@programfk
	ORDER BY WorkerAssignmentDate DESC
END
GO
