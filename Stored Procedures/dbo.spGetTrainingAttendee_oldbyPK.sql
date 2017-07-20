SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetTrainingAttendee_oldbyPK]

(@TrainingAttendee_oldPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM TrainingAttendee_old
WHERE TrainingAttendee_oldPK = @TrainingAttendee_oldPK
GO
