SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Jan. 18, 2012>
-- Description: <copied from FamSys - see header below>
-- =============================================
-- =============================================
-- Author:    <Dorothy Baum>
-- Create date: <June 28, 2010>
-- Description: <list of all pc1ids per program>
-- =============================================
CREATE procedure [dbo].[spGetAllPC1ids]
-- Add the parameters for the stored procedure here
(
    @ProgramFKs    varchar(100),
    @includeClosed bit
)
as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

	if charindex(',',@ProgramFKs) = 0
		set @ProgramFKs = ',' + @ProgramFKs + ','
	
	-- Insert statements for procedure here
	if @includeClosed = 1
		select pc1id
			  ,hvcasefk
			  ,programfk
			from caseprogram
				inner join hvcase
						  on caseprogram.hvcasefk = hvcasepk
			where @ProgramFKs like ('%,'+cast(ProgramFK as varchar(100))+',%')
				 and caseprogress >= 9
				 and intakedate is not null
			order by pc1id
	else
		select pc1id
			  ,hvcasefk
			  ,programfk
			from caseprogram
				inner join hvcase
						  on caseprogram.hvcasefk = hvcasepk
			where dischargedate is null
				 and @ProgramFKs like ('%,'+cast(ProgramFK as varchar(100))+',%')
				 and caseprogress >= 9
				 and intakedate is not null
			order by pc1id
end
GO
