SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:	<dar chen>
-- Create date: <Mar 3, 2014>
-- Description:	<Face Sheet report - Other Children>
-- =============================================
CREATE procedure [dbo].[rspFaceSheetOtherChildren]
(
    @ProgramFK varchar(max) = null,
    @PC1ID char(13) = null
)
as
begin

--DECLARE @ProgramFK VARCHAR(MAX) = N'1'
--DECLARE @PC1ID CHAR(13) = N'NP77010002288'

if @ProgramFK is null
begin
	select @ProgramFK = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
									   from HVProgram
									   for xml path ('')),2,8000)
end;

if @PC1ID = ''
begin
	set @PC1ID = null
end;

SELECT DISTINCT a.HVCaseFK, a.FirstName + ' ' + a.LastName [name]
, convert(VARCHAR(12), a.DOB, 101) [dob]
, c1.AppCodeText [relationShip]
, c2.AppCodeText [livingArrangement]
FROM OtherChild AS a
JOIN CaseProgram AS b ON a.HVCaseFK = b.HVCaseFK
LEFT OUTER JOIN codeApp AS c1 ON c1.AppCodeGroup = 'Relation2PC1' AND c1.AppCode = a.Relation2PC1
LEFT OUTER JOIN codeApp AS c2 ON c2.AppCodeGroup = 'LivingArrangements' AND c2.AppCode = a.LivingArrangement
JOIN dbo.SplitString(@ProgramFK,',') on b.programfk = listitem
WHERE PC1ID = isnull(@PC1ID,PC1ID)
-- AND a.FormType = 'IN'
--ORDER BY a.HVCaseFK

END;


GO
