SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [dbo].[spGetKempebyHVCaseFK] (
	@HVCaseFK INT,
	@ProgramFK INT = NULL
)

AS

SELECT *
FROM Kempe
WHERE HVCaseFK = @HVCaseFK
AND ProgramFK = ISNULL(@ProgramFK, ProgramFK)
GO
