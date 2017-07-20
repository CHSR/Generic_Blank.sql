SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[spGetAllCaseFilterTypeItems]
as
select a.AppCode, a.AppCodeText
from dbo.codeApp AS a
WHERE a.AppCodeGroup = 'CaseFilterType'                
AND a.AppCodeUsedWhere LIKE '%CF%'
order by a.AppCode
GO
