SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetlistCaseFilterNameOptionbyPK]

(@listCaseFilterNameOptionPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM listCaseFilterNameOption
WHERE listCaseFilterNameOptionPK = @listCaseFilterNameOptionPK
GO
