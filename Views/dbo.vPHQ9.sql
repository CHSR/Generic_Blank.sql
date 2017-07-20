SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vPHQ9]
AS
SELECT        p.PHQ9PK, p.FormFK, p.FormType, p.HVCaseFK, p.ProgramFK, p.DateAdministered, 
                         CASE WHEN p.FormType = 'TC' THEN t .FSWFK WHEN p.FormType = 'FU' THEN fu.FSWFK WHEN p.FormType = 'KE' THEN k.FAWFK WHEN p.FormType = 'IN' THEN i.FSWFK END AS workerfk
FROM            dbo.PHQ9 AS p LEFT OUTER JOIN
                         dbo.TCID AS t ON t.HVCaseFK = p.HVCaseFK AND t.TCIDPK = p.FormFK AND p.FormType = 'TC' LEFT OUTER JOIN
                         dbo.FollowUp AS fu ON fu.HVCaseFK = p.HVCaseFK AND fu.FollowUpPK = p.FormFK AND p.FormType = 'FU' LEFT OUTER JOIN
                         dbo.Kempe AS k ON k.HVCaseFK = p.HVCaseFK AND k.KempePK = p.FormFK AND p.FormType = 'KE' LEFT OUTER JOIN
                         dbo.Intake AS i ON i.HVCaseFK = p.HVCaseFK AND i.IntakePK = p.FormFK AND p.FormType = 'IN'
WHERE        (p.DateAdministered IS NOT NULL) AND (p.FormFK IS NOT NULL) AND (p.FormFK > 0) AND (p.Invalid = 0)
GO
