SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDellistCaseFilterName](@listCaseFilterNamePK int)

AS


DELETE 
FROM listCaseFilterName
WHERE listCaseFilterNamePK = @listCaseFilterNamePK
GO
