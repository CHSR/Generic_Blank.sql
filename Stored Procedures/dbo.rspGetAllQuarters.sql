SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Feb 15, 2012>
-- Description:	<Reporting utility sproc to calculate and return the completed Quarters from 1 to 4>
-- =============================================
CREATE PROCEDURE [dbo].[rspGetAllQuarters]
	@ProgramFK int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    declare @ContractStartDate date
	set @ContractStartDate = (select ContractStartDate FROM HVProgram P where HVProgramPK=@ProgramFK);
	
	with cteRawQuarters
	as
	(
		select '1st Quarter' as QuarterTitle
				,@ContractStartDate as QuarterStartDate
				,dateadd(day,-1,dateadd(month,3,@ContractStartDate)) as QuarterEndDate			
		union all
		select '2nd Quarter' as QuarterTitle
				,dateadd(month,3,@ContractStartDate) as QuarterStartDate
				,dateadd(day,-1,dateadd(month,6,@ContractStartDate)) as QuarterEndDate
		union all
		select '3rd Quarter' as QuarterTitle
				,dateadd(month,6,@ContractStartDate) as QuarterStartDate
				,dateadd(day,-1,dateadd(month,9,@ContractStartDate)) as QuarterEndDate
		union all
		select '4th Quarter' as QuarterTitle
				,dateadd(month,9,@ContractStartDate) as QuarterStartDate
				,dateadd(day,-1,dateadd(month,12,@ContractStartDate)) as QuarterEndDate
	)
	
	select QuarterTitle
			,QuarterStartDate
			,QuarterEndDate
			,convert(varchar(8),QuarterStartDate,1)+','+convert(varchar(8),QuarterEndDate,1) as QuarterDates
			,'{"start":"'+convert(varchar(8),QuarterStartDate,1)+'","end":"'+convert(varchar(8),QuarterEndDate,1)+
				'","contractstart":"'+convert(varchar(8),@ContractStartDate,1)+'","contractend":"'+convert(varchar(8),QuarterEndDate,1)+'"}' as QuarterData
		from cteRawQuarters
END
GO
