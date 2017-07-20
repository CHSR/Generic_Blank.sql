SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetCommonAttributesbyHVCaseFK]
	@HVCaseFK [int],
	@ProgramFK [int]
AS

SET NOCOUNT ON;

SELECT * 
FROM CommonAttributes
WHERE HVCaseFK = @HVCaseFK
AND ProgramFK = @ProgramFK
GO
