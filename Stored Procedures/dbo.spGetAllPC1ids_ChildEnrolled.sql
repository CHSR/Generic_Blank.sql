SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb. 15, 2012>
-- Description: <copied from FamSys - see header below>
--              This differs from spGetAllPC1IDs in that it only retrieves 
--				the cases were the TC has been born and entered into the system
-- exec spGetAllPC1IDs_ChildEnrolled 16, 0
-- =============================================
-- =============================================
-- Author:    <Dorothy Baum>
-- Create date: <June 28, 2010>
-- Description: <list of all pc1ids per program>
-- =============================================
CREATE procedure [dbo].[spGetAllPC1ids_ChildEnrolled]
-- Add the parameters for the stored procedure here
(
    @Programfks    varchar(100),
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
		select distinct pc1id
					   ,caseprogram.hvcasefk
					   ,caseprogram.programfk
			from caseprogram
				inner join hvcase
						  on caseprogram.hvcasefk = hvcasepk
				inner join tcid
						  on tcid.hvcasefk = caseprogram.hvcasefk
						  and tcid.programfk = caseprogram.programfk
			where @ProgramFKs like ('%,'+cast(caseprogram.ProgramFK as varchar(100))+',%')
				 and caseprogress >= 9
				 and intakedate is not null
			order by pc1id
	else
		select distinct pc1id
					   ,caseprogram.hvcasefk
					   ,caseprogram.programfk
			from caseprogram
				inner join hvcase
						  on caseprogram.hvcasefk = hvcasepk
				inner join tcid
						  on tcid.hvcasefk = caseprogram.hvcasefk
						  and tcid.programfk = caseprogram.programfk
			where dischargedate is null
				 and @ProgramFKs like ('%,'+cast(caseprogram.ProgramFK as varchar(100))+',%')
				 and caseprogress >= 9
				 and intakedate is not null
			order by pc1id
end
GO
