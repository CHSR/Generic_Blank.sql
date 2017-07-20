SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		<Dorothy Baum>
-- Create date: <Dec 1, 2009>
-- Description:	<Call to get all records by PCType associated with FormFK>
-- Main purpose: <Follow-up Form>
-- =============================================


CREATE PROCEDURE [dbo].[spGetEmploymentByFormFK]
	@PCType AS VARCHAR(3),
	@FormType as CHAR(2),
	@FormFK INT

AS

SELECT *, StillWorkingText = 
CASE stillworking WHEN '1' THEN 'Yes'
				  WHEN '0' THEN 'No' 
ELSE '' 
END
FROM employment
WHERE formfk = @FormFK
AND PCType = @PCType 
AND FormType = @FormType









GO
