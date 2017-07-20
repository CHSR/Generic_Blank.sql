SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetEmploymentbyPK]

(@EmploymentPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM Employment
WHERE EmploymentPK = @EmploymentPK
GO
