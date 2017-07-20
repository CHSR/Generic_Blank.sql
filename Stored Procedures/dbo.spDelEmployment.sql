SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelEmployment](@EmploymentPK int)

AS


DELETE 
FROM Employment
WHERE EmploymentPK = @EmploymentPK
GO
