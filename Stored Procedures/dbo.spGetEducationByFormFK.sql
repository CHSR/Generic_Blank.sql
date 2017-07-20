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


CREATE PROCEDURE [dbo].[spGetEducationByFormFK]
	@PCType AS VARCHAR(3),
	@FormType AS CHAR(2),
	@FormFK INT, 
	@Interval INT

AS

SELECT *
FROM education
Inner Join (Select AppCode,convert(varchar,convert(int,AppCode))+'. '+AppCodeText as ProgramTypeText from codeApp where appCodeGroup='EducationProgram') a
On programtype=a.AppCode 
WHERE formfk = @FormFK
AND FormType = @FormType
AND PCType = @PCType
AND Interval <= @Interval











GO
