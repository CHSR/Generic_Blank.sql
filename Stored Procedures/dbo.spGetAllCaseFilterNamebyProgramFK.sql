SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dorothy Baum/Dar Chen>
-- Create date: <Apr 21, 2010 - July 8, 2013>
-- Description:	<Get all the listCaseCriteria by ProgramFK>
-- =============================================
CREATE procedure [dbo].[spGetAllCaseFilterNamebyProgramFK]
    @ProgramFK as int = null
as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

	-- Insert statements for procedure here
	select listCaseFilterNamePK
		  ,rtrim(FieldTitle) as FieldTitle
		  ,FilterType
		  ,isnull(b.AppCodeText, '(Missing)') as FilterTypeText
		  ,rtrim(Hint) as Hint
		  ,ProgramFK
		  ,OptionsList = SUBSTRING ((SELECT ',' + rtrim(FilterOption) from listCaseFilterNameOption cfno 
		  WHERE cfno.CaseFilterNameFK = cfn.listCaseFilterNamePK FOR XML PATH ( '' )), 2, 1000)
		  --,OptionsCodeList = SUBSTRING ((SELECT ',' + rtrim(FilterOptionCode) from listCaseFilterNameOption cfno 
		  --WHERE cfno.CaseFilterNameFK = cfn.listCaseFilterNamePK FOR XML PATH ( '' )), 2, 1000)
		  ,OptionsPKList = SUBSTRING ((SELECT ',' + rtrim(convert(VARCHAR(20), listCaseFilterNameOptionPK)) from listCaseFilterNameOption cfno 
		  WHERE cfno.CaseFilterNameFK = cfn.listCaseFilterNamePK FOR XML PATH ( '' )), 2, 1000)
		  ,Inactive = CASE WHEN Inactive IS NULL THEN 'N' WHEN Inactive = 1 THEN 'Y' ELSE 'N' END 
		  ,InactiveValue = CASE WHEN Inactive IS NULL THEN '' WHEN Inactive = 1 THEN 'True' ELSE '' END 
		from listCaseFilterName cfn
		LEFT OUTER JOIN codeApp AS b ON b.AppCode = FilterType AND b.AppCodeGroup = 'CaseFilterType'
		where ProgramFK = isnull(@ProgramFK,ProgramFK)
		order by listCaseFilterNamePK
end
GO
