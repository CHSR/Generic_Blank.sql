SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelCaseFilter](@CaseFilterPK int)

AS


DELETE 
FROM CaseFilter
WHERE CaseFilterPK = @CaseFilterPK
GO
