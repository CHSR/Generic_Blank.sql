SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelIntake](@IntakePK int)

AS


DELETE 
FROM Intake
WHERE IntakePK = @IntakePK
GO
