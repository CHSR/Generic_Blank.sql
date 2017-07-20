SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelCaseProgram](@CaseProgramPK int)

AS


DELETE 
FROM CaseProgram
WHERE CaseProgramPK = @CaseProgramPK
GO
