SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dorothy Baum
-- Create date: June 21, 2010
-- Description:	table of hvcasefk that fit the filter passed
-- =============================================
CREATE function [dbo].[udfCaseFilters]
(-- Add the parameters for the function here
    @positiveClause varchar(200)    = null,
    @negativeClause	varchar(200)    = null,
    @ProgramFKs		varchar(200)
) 
returns
@tblCases table
(
	HVCaseFK int
) 
as
begin
	declare @HVCasefk int
	---- set up the variables for the filter values
	declare @pospair1 as varchar(100) = '',
            @pospair2 as varchar(100) = '',
            @pospair3 as varchar(100) = '',
            @negpair1 as varchar(100) = '',
            @negpair2 as varchar(100) = '',
            @negpair3 as varchar(100) = '',
            @rownum   as int,
            @listitem as varchar(100)
	--positive clause
	if @positiveClause is not null and @positiveClause != ''
		begin
			declare pos_cursor cursor for
			select *
				  ,rownum = row_number() over (order by listItem)
				from splitstring(@positiveClause,',')

			open pos_cursor;
			fetch next from pos_cursor into @listitem,@rownum

			if @rownum = 1
				set @pospair1 = @listitem;

			while @@Fetch_status = 0
			begin

				if @rownum = 2
					set @pospair2 = @listitem;

				if @rownum = 3
					set @pospair3 = @listitem;

				fetch next from pos_cursor into @listitem,@rownum
			end
			close pos_cursor
			deallocate pos_cursor
		end
	---negative cursor
	if @negativeClause is not null and @negativeClause != ''
		begin
			declare neg_cursor cursor for
			select *
				  ,rownum = row_number() over (order by listItem)
				from splitstring(@negativeClause,',')

			open neg_cursor;
			fetch next from neg_cursor into @listitem,@rownum

			if @rownum = 1
				set @negpair1 = @listitem;

			while @@Fetch_status = 0
			begin

				if @rownum = 2
					set @negpair2 = @listitem;

				if @rownum = 3
					set @negpair3 = @listitem;

				fetch next from neg_cursor into @listitem,@rownum
			end
			close neg_cursor
			deallocate neg_cursor
		end
	---
	if (@positiveClause is null or @positiveClause = '') and (@negativeClause is null or @negativeClause = '') 
		begin
			with cteUniqueCases as 
				(select max(CaseProgramPK) as CaseProgramPK
					from CaseProgram cp
					inner join HVCase hc on hc.HVCasePK = cp.HVCaseFK
					inner join SplitString(@ProgramFKs, ',') ss on ss.ListItem = cp.ProgramFK
					group by HVCaseFK
				)
			insert into @tblCases
				select HVCaseFK as HVCasePK 
				from cteUniqueCases uc
				inner join CaseProgram cp on cp.CaseProgramPK = uc.CaseProgramPK
				--inner join HVCase h on h.HVCasePK = cp.HVCaseFK				
		end
	else
		begin
			insert into @tblCases
				select distinct HVCasePK
					from
						(select HVCasePK
							   ,cp.ProgramFK
							   ,cast(isnull(CaseFilterNameFK,listCaseFilterNamePK) as varchar(10))+';'
								+case 
									when cfn.FilterType = 1
										then case when cf.CaseFilterNameChoice=1 then 'Yes' else 'No' end
									when cfn.FilterType = 2
										then (select cfno.FilterOption from listCaseFilterNameOption cfno where listCaseFilterNameOptionPK=cf.CaseFilterNameOptionFK)
									when cfn.FilterType = 3
										then CaseFilterValue
								end as answers
							from CaseProgram cp
							inner join HVCase on cp.HVCaseFK = HVCasePK
							inner join listCaseFilterName cfn on cfn.ProgramFK = cp.ProgramFK
							left join CaseFilter cf on HVCasePK = cf.HVCaseFK and CaseFilterNameFK = cfn.listCaseFilterNamePK
							inner join dbo.SplitString(@ProgramFKs,',') on cp.programfk = listitem) a
							-- where @programFKS like ('%,'+cast(CaseProgram.ProgramFK as varchar(100))+',%')) a
					where answers in (@pospair1, @pospair2, @pospair3)
						-- (case when @pospair1 is not null then 
						 and answers not in (isnull(@negpair1,answers), isnull(@negpair2,answers), isnull(@negpair3,answers))
		end

	return
	
end
GO
