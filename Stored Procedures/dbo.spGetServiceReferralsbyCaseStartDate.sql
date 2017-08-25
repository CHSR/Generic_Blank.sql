SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[spGetServiceReferralsbyCaseStartDate] (@HVCaseFK int
													, @CaseStartDate datetime
													 )
as
	begin
		set nocount on;

		select distinct
				sr.*
		from	ServiceReferral sr
		inner join CaseProgram cp on sr.HVCaseFK = cp.HVCaseFK
									 and sr.ProgramFK = cp.ProgramFK
		where	sr.HVCaseFK = @HVCaseFK
				and CaseStartDate <= @CaseStartDate
				--and ReferralDate <= isnull(DischargeDate, getdate())
		order by ReferralDate;
	 
	end;







GO
