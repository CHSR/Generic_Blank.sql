SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetscoreASQbyPK]

(@scoreASQPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM scoreASQ
WHERE scoreASQPK = @scoreASQPK
GO
