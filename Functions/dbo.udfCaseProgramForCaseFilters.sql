SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<jrobohn>
-- Create date: <11-14-12>
-- Description:	<Returns a list of CaseProgram rows, including any applicable case filters>
-- =============================================
CREATE function [dbo].[udfCaseProgramForCaseFilters]
(
	-- Add the parameters for the function here
	@ProgramFKs varchar(120)
)
returns
@tblCases table 
(
	HVCasePK int
	,ProgramFK int
	,answers varchar(50)
)
as
begin
	-- Fill the table variable with the rows for your result set
	insert into @tblCases
		select HVCasePK
			 ,cp.ProgramFK
			 ,cast(isnull(CaseFilterNameFK,listCaseFilterNamePK) as varchar(10))+
				isnull(dbo.FilterValue(FilterType,CaseFilterNameChoice,CaseFilterNameOptionFK, CaseFilterValue),'') as answers
		from CaseProgram cp
		inner join HVCase hvc on cp.HVCaseFK = hvc.HVCasePK
		inner join listCaseFilterName cfn on cfn.ProgramFK = cp.ProgramFK
		left join CaseFilter cf on hvc.HVCasePK = cf.HVCaseFK and CaseFilterNameFK = cfn.listCaseFilterNamePK
		inner join dbo.SplitString(@ProgramFKs,',') on cp.programfk = listitem
		
	return 
end
GO
