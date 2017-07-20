SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[HVLevelDetail]
AS
SELECT     HVLevelPK, HVCaseFK, ProgramFK, LevelName, CaseWeight, MaximumVisit, MinimumVisit, LevelFK, StartLevelDate, ISNULL(EndLevel, DischargeDate) 
                      AS EndLevelDate
FROM         (SELECT     cp.DischargeDate, lv1.HVLevelPK, lv1.HVCaseFK, lv1.ProgramFK, dbo.codeLevel.LevelName, dbo.codeLevel.CaseWeight, dbo.codeLevel.MaximumVisit, 
                                              dbo.codeLevel.MinimumVisit, lv1.LevelFK, lv1.LevelAssignDate AS StartLevelDate, DATEADD(day, - 1,
                                                  (SELECT     TOP (1) LevelAssignDate
                                                    FROM          dbo.HVLevel AS lv2
                                                    WHERE      (LevelAssignDate > lv1.LevelAssignDate) AND (HVCaseFK = lv1.HVCaseFK)
                                                    ORDER BY LevelAssignDate)) AS EndLevel
                       FROM          dbo.HVLevel AS lv1 INNER JOIN
                                              dbo.codeLevel ON dbo.codeLevel.codeLevelPK = lv1.LevelFK INNER JOIN
                                              dbo.CaseProgram AS cp ON lv1.HVCaseFK = cp.HVCaseFK AND lv1.ProgramFK = cp.ProgramFK AND lv1.LevelAssignDate >= cp.CaseStartDate AND 
                                              ISNULL(cp.DischargeDate, GETDATE()) >= lv1.LevelAssignDate) AS a
GO
