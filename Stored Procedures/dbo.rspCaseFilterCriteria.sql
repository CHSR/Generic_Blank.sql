SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dorothy Baum>
-- Create date: <June 17, 2010>
-- Description:	<report: CaseFilter, Criteria : main use reportviewer page control set up>
--				moved from FamSys Feb 20, 2012 by jrobohn
-- =============================================
CREATE procedure [dbo].[rspCaseFilterCriteria]
(
@ProgramFKs varchar(100)
)
as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

	-- First table, distinct list of FieldTitles
	select distinct cf1.ProgramFK
				 ,FieldTitle
				 ,CaseFilterNameFK
		from CaseFilter cf1
			inner join listCaseFilterName lcfn
					on lcfn.listCaseFilterNamePK = cf1.CaseFilterNameFK
		where @ProgramFKs like ('%,'+cast(cf1.programfk as varchar(100))+',%')

	--Second table, distinct list of FilterValues
	select distinct case
						when FilterType = 1
							then case
								when CaseFilterNameChoice = 1 then 'Yes'
								else 'No'
							end
						when FilterType = 2
							then (select FilterOption
									from listCaseFilterNameOption cfno
									where cfno.CaseFilterNameFK = cf.
										CaseFilterNameFK
										 and cfno.listCaseFilterNameOptionPK = 
											 cf.CaseFilterNameOptionFK)
						else
							CaseFilterValue
					end as FilterValue
				 ,cf.ProgramFK
				 ,FieldTitle
				 ,CaseFilterNameFK
		from CaseFilter cf
			inner join listCaseFilterName cfn
					on cfn.listCaseFilterNamePK = cf.CaseFilterNameFK
			inner join dbo.SplitString(@ProgramFKs,',') on cf.programfk = listitem
		-- where @programfks like ('%,'+cast(cf.programfk as varchar(100))+',%')
end
GO
