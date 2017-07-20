SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[WorkerAssignmentDetail]
AS
SELECT     WorkerAssignmentPK, HVCaseFK, ProgramFK, StartAssignmentDate, WorkerFK, ISNULL(EndAssignment, DischargeDate) AS EndAssignmentDate
FROM         (SELECT     cp.DischargeDate, wa1.WorkerAssignmentPK, wa1.HVCaseFK, wa1.ProgramFK, wa1.WorkerAssignmentDate AS StartAssignmentDate, wa1.WorkerFK, 
                                              DATEADD(day, - 1,
                                                  (SELECT     TOP (1) WorkerAssignmentDate
                                                    FROM          dbo.WorkerAssignment AS wa2
                                                    WHERE      (WorkerAssignmentDate > wa1.WorkerAssignmentDate) AND (HVCaseFK = wa1.HVCaseFK) AND (ProgramFK = wa1.ProgramFK)
                                                    ORDER BY WorkerAssignmentDate)) AS EndAssignment
                       FROM          dbo.WorkerAssignment AS wa1 INNER JOIN
                                              dbo.CaseProgram AS cp ON wa1.HVCaseFK = cp.HVCaseFK AND wa1.ProgramFK = cp.ProgramFK) AS a
GO
