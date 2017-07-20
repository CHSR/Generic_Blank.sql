SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE procedure [dbo].[rspCaseProgram]-- Add the parameters for the stored procedure here
(
    @ProgramFK int,
    @Pc1id     varchar(20),
    @StartDate date,
    @EndDate   date
)
as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

	-- Insert statements for procedure here
	select *
		from CaseProgram cp
		where ProgramFK = isnull(@ProgramFK,ProgramFK)
			 and PC1ID = isnull(@Pc1id,PC1ID)
			 and CaseStartDate between @StartDate and @EndDate
		order by pc1id
end
GO
