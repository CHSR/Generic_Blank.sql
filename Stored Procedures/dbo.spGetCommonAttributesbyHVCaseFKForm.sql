SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[spGetCommonAttributesbyHVCaseFKForm]
	@HVCaseFK [int],
	@ProgramFK [int],
	@FormType varchar(8)
AS

SET NOCOUNT ON;

SELECT * 
FROM CommonAttributes
WHERE HVCaseFK = @HVCaseFK
AND ProgramFK = @ProgramFK
and FormType = @FormType

GO
