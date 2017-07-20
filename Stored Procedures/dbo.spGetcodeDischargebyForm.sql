SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[spGetcodeDischargebyForm]
	@DischargeUsedWhere VARCHAR(10)
AS

SELECT * 
FROM codeDischarge
WHERE DischargeUsedWhere LIKE '%' + @DischargeUsedWhere + '%' 
ORDER BY Dischargecode

GO
