SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetPCProgrambyPK]

(@PCProgramPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM PCProgram
WHERE PCProgramPK = @PCProgramPK
GO
