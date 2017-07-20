SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Chris Papas
-- Create date: 10/28/2010
-- Description:	Get list of forms still requiring supervisor review
-- =============================================
-- Author:    <Jay Robohn>
-- Description: <copied from FamSys Feb 20, 2012 - see header below>
-- =============================================
create procedure [dbo].[rspSupervisorReview]
(
    @programfk varchar(max)    = null
)
as
begin

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')


	select FormFK
		  ,FormDate
		  ,FormReviewPK
		  ,codeFormname
		  ,pc1id
		  ,formreviewcreator
		  ,case CurrentFSWFK
			   when CurrentFSWFK then
				   CurrentFSWFK
			   else
				   CurrentFAWFK
		   end as CurrentWrkr
		  ,supervisorfk
		  ,FirstName as SuperFName
		  ,LastName as SUPLName
		from FormReview
			left join codeForm on codeForm.codeFormAbbreviation = formreview.formtype
			left join caseprogram on caseprogram.hvcasefk = formreview.hvcasefk
			left join workerprogram on workerprogram.workerfk = case CurrentFSWFK
																	when CurrentFSWFK then
																		CurrentFSWFK
																	else
																		CurrentFAWFK
																end
			left join worker on worker.workerpk = workerprogram.supervisorfk
			inner join dbo.SplitString(@programfk,',') on FormReview.programfk = listitem
		where ReviewedBy is null
end

GO
