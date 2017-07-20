SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelTrainingAttendee](@TrainingAttendeePK int)

AS


DELETE 
FROM TrainingAttendee
WHERE TrainingAttendeePK = @TrainingAttendeePK
GO
