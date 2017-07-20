SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelTrainingAttendee_old](@TrainingAttendee_oldPK int)

AS


DELETE 
FROM TrainingAttendee_old
WHERE TrainingAttendee_oldPK = @TrainingAttendee_oldPK
GO
