SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dorothy Baum
-- Create date: June 21, 2010
-- Description:	table of hvcasefk that fit the filter passed
-- moved into HFNY 2012-07-07
-- =============================================
CREATE function [dbo].[udfCaseFilters2]
-- Add the parameters for the function here
(
	@positiveClause varchar(max)= null,
	@negativeClause varchar(max)= null,
	@ProgramFKs varchar(100)
)
returns @tblCases table
(
	HVCaseFK int
)
as
begin

--with cteCaseProgram as 
--(
--	select HVCasePK
--		 ,cp.ProgramFK
--		 ,cast(isnull(CaseFilterNameFK,listCaseFilterNamePK) as varchar(10))+
--			isnull(dbo.FilterValue(FilterType,CaseFilterNameChoice,CaseFilterNameOptionFK, CaseFilterValue),'') as answers
--	from CaseProgram cp
--	inner join HVCase hvc on cp.HVCaseFK = hvc.HVCasePK
--	inner join listCaseFilterName cfn on cfn.ProgramFK = cp.ProgramFK
--	left join CaseFilter cf on hvc.HVCasePK = cf.HVCaseFK and CaseFilterNameFK = cfn.listCaseFilterNamePK
--	inner join dbo.SplitString(@ProgramFKs,',') on cp.programfk = listitem
--)

-- positiveClause and negativeClause both not null
if @positiveClause is not null and @negativeClause is not null
	insert into @tblCases
		select pos.hvcasepk
			from
				(select distinct HVCasePK
					 from udfCaseProgramForCaseFilters(@ProgramFKs) cpfcf
						 inner join splitstring(@positiveClause,',') d
								   on d.listitem = cpfcf.answers) pos
				inner join
						  (select distinct HVCasePK
							   from udfCaseProgramForCaseFilters(@ProgramFKs) cpfcf
								   inner join splitstring(@negativeClause,',') d
											 on d.listitem = cpfcf.answers) neg
						  on neg.hvcasepk = pos.hvcasepk

--negativeClause null and positiveClause not null
if @positiveClause is not null and @negativeClause is null
	insert into @tblCases
		select distinct HVCasePK
			from udfCaseProgramForCaseFilters(@ProgramFKs) cpfcf
				inner join splitstring(@positiveClause,',') d
						  on d.listitem = cpfcf.answers

--negativeClause not null and positiveClause is null
if @positiveClause is null and @negativeClause is not null
	insert into @tblCases
		select pos.hvcasefk
			from (select distinct HVCaseFK
					  from CaseProgram cp
						  inner join dbo.SplitString(@ProgramFKs,',')
									on cp.programfk = listitem) pos
				left outer join
							   (select distinct HVCasePK
									from udfCaseProgramForCaseFilters(@ProgramFKs) cpfcf
										inner join splitstring(@negativeClause,',') d
												  on d.listitem = cpfcf.answers) neg
							   on neg.hvcasepk = pos.hvcasefk
			where neg.hvcasepk is null

--both clauses null
if @positiveClause is null and @negativeClause is null
	insert into @tblCases
		select hvcasefk
			from CaseProgram cp
				inner join dbo.SplitString(@ProgramFKs,',')
						  on cp.programfk = listitem

return;
end;
GO
