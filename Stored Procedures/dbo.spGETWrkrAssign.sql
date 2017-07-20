SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Chris Papas
-- Create date: 12/07/2010
-- Description:	Worker Assignment History for WorkerAssignment page
-- =============================================
CREATE PROCEDURE [dbo].[spGETWrkrAssign]
	-- Add the parameters for the stored procedure here
	@hvcasefk as int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT WorkerAssignmentPK, workerassignment.HVCaseFK, workerassignment.ProgramFK, 
	CONVERT(varchar, WorkerAssignmentDate, 101) AS WrkrAssignmentDate, 
	WorkerFK, CurrentFSWFK, FirstName + ' ' + LastName AS WorkerName, CaseProgramPK
	FROM workerassignment 
	INNER JOIN CaseProgram ON workerassignment.HVCasefk=CaseProgram.HVcasefk
	INNER JOIN Worker ON Worker.WorkerPK = workerassignment.workerfk
	where workerassignment.hvcasefk=@hvcasefk
	ORDER BY WorkerAssignmentDate DESC
END

GO
