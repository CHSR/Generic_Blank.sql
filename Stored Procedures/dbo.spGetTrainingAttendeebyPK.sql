SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetTrainingAttendeebyPK]

(@TrainingAttendeePK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM TrainingAttendee
WHERE TrainingAttendeePK = @TrainingAttendeePK
GO
