SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jay Robohn
-- Create date: Nov. 12, 2011
-- Modified: 
-- Description:	CaseFilter (Xtra-flds) by ProgramFK
-- exec [spGetAllCaseFilterByHVCaseFK] 183802,34
-- =============================================
CREATE PROCEDURE [dbo].[spGetAllCaseFilterByHVCaseFK]  (@HVCaseFK int, @ProgramFK int)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	with cteCaseFilters
	as
	(select CaseFilterNameFK
			,CaseFilterNameChoice
			,CaseFilterNameOptionFK
			,CaseFilterValue
			,CaseFilterPK
			,HVCaseFK
			,ProgramFK 
		from CaseFilter 
	 Where HVCaseFK=@HVCaseFK) 
	select listCaseFilterNamePK
          ,FieldTitle
          ,case when FilterType='1' then 'Yes/No'
				when FilterType='2' then 'Multiple choice'
				when FilterType='3' then 'Free form'
			end as FilterTitle
          ,Hint
          ,case when FilterType='1' then 
          		  case when CaseFilterNameChoice=1 then 'Yes' 
					when CaseFilterNameChoice=0 then 'No' 
					else '' end 
				when FilterType='2' then cfno.FilterOption
				when FilterType='3' then CaseFilterValue
			end as CaseFilterValue
          ,CaseFilterPK
          ,HVCaseFK
          ,cfn.ProgramFK
	from listCaseFilterName cfn
	left outer join cteCaseFilters CF on cfn.ProgramFK=CF.ProgramFK and 
										 listCaseFilterNamePK= CF.CaseFilterNameFK
	left outer join listCaseFilterNameOption cfno on CaseFilterNameOptionFK = cfno.listCaseFilterNameOptionPK
	where CF.ProgramFK = isnull(@ProgramFK,CF.ProgramFK)
	ORDER BY FieldTitle

END











GO
