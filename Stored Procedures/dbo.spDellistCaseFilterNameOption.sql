SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDellistCaseFilterNameOption](@listCaseFilterNameOptionPK int)

AS


DELETE 
FROM listCaseFilterNameOption
WHERE listCaseFilterNameOptionPK = @listCaseFilterNameOptionPK
GO
