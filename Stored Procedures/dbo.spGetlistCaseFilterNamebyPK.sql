SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetlistCaseFilterNamebyPK]

(@listCaseFilterNamePK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM listCaseFilterName
WHERE listCaseFilterNamePK = @listCaseFilterNamePK
GO
