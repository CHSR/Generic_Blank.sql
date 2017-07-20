SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelCaseNote](@CaseNotePK int)

AS


DELETE 
FROM CaseNote
WHERE CaseNotePK = @CaseNotePK
GO
