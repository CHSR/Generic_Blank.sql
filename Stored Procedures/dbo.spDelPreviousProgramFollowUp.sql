SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jayrobot
-- Create date: 06/22/16
-- Description:	Deletes the follow-up and all related forms 
--				from the previous program when a program 
--				accepts a transfer case.
-- =============================================
CREATE procedure [dbo].[spDelPreviousProgramFollowUp]
	-- Add the parameters for the stored procedure here
	@HVCaseFK int
	, @ProgramFK int
	, @FollowUpFK int
	, @ok as varchar(200) output
as
begin
	-- Detect whether the procedure was called from an active transaction and save  
	-- that for later use. In the procedure, @TranCounter = 0 means there was no active transaction  
	-- and the procedure started one. @TranCounter > 0 means an active  
	-- transaction was started before the procedure was called.  
    declare @TranCounter INT;  
    set @TranCounter = @@TRANCOUNT  
    if @TranCounter > 0  
		-- Procedure called when there is an active transaction.  
		-- Create a savepoint to be able to roll back only the work done  
		-- in the procedure if there is an error.  
        save transaction ProcedureSave;  
    else 
		-- Procedure must start its own transaction.  
        begin transaction;  
	
	begin try
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		set nocount on;

		declare @PC1IssuesFK int
		declare @ReturnValue bit

		select @FollowUpFK = FollowUpPK
				, @PC1IssuesFK = PC1IssuesFK
		from FollowUp fu 
		where HVCaseFK = @HVCaseFK
				and FollowUpInterval = '99'

		if @@ROWCOUNT = 0
			return
			
		delete from FollowUp 
		where HVCaseFK = @HVCaseFK 
				and FollowUpInterval = '99'

		delete from PC1Issues
		where PC1IssuesPK = @PC1IssuesFK

		delete from Employment
		where FormFK = @FollowUpFK
				and FormType = 'FU'
				and Interval = '99'

		delete from Education
		where FormFK = @FollowUpFK
				and FormType = 'FU'
				and Interval = '99'

		delete from PHQ9
		where FormFK = @FollowUpFK
				and FormType = 'FU'
				and FormInterval = '99'

		delete from CommonAttributes
		where HVCaseFK = @HVCaseFK 
				and FormType like 'FU%' 
				and FormInterval = '99'

		-- Successfully deleted 
		set @ok = 'good'
		
		-- Get here if no errors; must commit any transaction started in the  
		-- procedure, but not commit a transaction started before the transaction was called.  

		if @TranCounter = 0
			-- @TranCounter = 0 means no transaction was started before the procedure was called.  
			-- The procedure must commit the transaction it started. 
			commit transaction

	end try

	begin catch
		-- An error occurred; must determine which type of rollback will roll  
		-- back only the work done in the procedure.  
		if @TranCounter = 0
			-- Transaction started in procedure. Roll back complete transaction.  
			rollback transaction
		else
			-- Transaction started before procedure called, do not roll back modifications  
			-- made before the procedure was called.  
			if xact_state() <> -1
				rollback transaction ProcedureSave
				-- If the transaction is uncommitable, a rollback to the savepoint is not allowed  
				-- because the savepoint rollback writes to the log. Just return to the caller, which  
				-- should roll back the outer transaction.  
		
		-- After the appropriate rollback, echo error  
		-- information to the caller.  
        declare @ErrorMessage nvarchar(4000);  
        declare @ErrorSeverity int;  
        declare @ErrorState int;  
  
        select @ErrorMessage = error_message();  
        select @ErrorSeverity = error_severity();  
        select @ErrorState = error_state();  
  
        raiserror (@ErrorMessage, -- Message text.  
                   @ErrorSeverity, -- Severity.  
                   @ErrorState -- State.  
                   );  
    end catch  
end
GO
