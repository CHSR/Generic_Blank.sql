SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetHVProgrambyPK]

(@HVProgramPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM HVProgram
WHERE HVProgramPK = @HVProgramPK
GO