SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <March 28, 2012>
-- Description:	<Call to get all records by PCType associated with HVCaseFK>
-- Main purpose: <Follow-up Form>
-- =============================================


CREATE PROCEDURE [dbo].[spGetEmploymentByHVCasePK]
	@PCType AS VARCHAR(3),	
	@HVCaseFK INT


AS

SELECT *, StillWorkingText = 
CASE stillworking WHEN '1' THEN 'Yes'
				  WHEN '0' THEN 'No' 
ELSE '' 
END
FROM employment
WHERE HVCaseFK = @HVCaseFK
AND PCType = @PCType 
GO
