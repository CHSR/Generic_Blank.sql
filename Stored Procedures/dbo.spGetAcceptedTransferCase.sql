SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jrobohn
-- Create date: 2014-12-22
-- Description:	
-- Modified: 
-- =============================================
create procedure [dbo].[spGetAcceptedTransferCase]
	-- Add the parameters for the stored procedure here
	@HVCaseFK as int
as
	begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
		set nocount on;

    -- Insert statements for procedure here
		with cteMain as
			(select	1 as ReturnValue 
				from CaseProgram cp
				inner join HVCase c on c.HVCasePK = cp.HVCaseFK
				where	HVCaseFK = @HVCaseFK
						and cp.TransferredtoProgramFK is null
			)

	select case when ReturnValue is null then 0 else ReturnValue end as ReturnValue
	from cteMain
	
	end

GO
