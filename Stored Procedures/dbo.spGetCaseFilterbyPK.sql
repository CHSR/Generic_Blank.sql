SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetCaseFilterbyPK]

(@CaseFilterPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM CaseFilter
WHERE CaseFilterPK = @CaseFilterPK
GO
