SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelCaseView](@CaseViewPK int)

AS


DELETE 
FROM CaseView
WHERE CaseViewPK = @CaseViewPK
GO
