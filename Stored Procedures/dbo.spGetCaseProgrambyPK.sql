SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetCaseProgrambyPK]

(@CaseProgramPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM CaseProgram
WHERE CaseProgramPK = @CaseProgramPK
GO
