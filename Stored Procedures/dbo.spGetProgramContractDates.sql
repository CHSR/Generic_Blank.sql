SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <July 17, 2012>
-- Description:	<gets contract dates given a programFK>
-- exec spGetProgramContractDates 1
-- =============================================
CREATE procedure [dbo].[spGetProgramContractDates](@programfk    varchar(max) = null)

as
BEGIN

    declare @ContractStartDate DATE
    declare @ContractEndDate DATE
    
	set @ContractStartDate = (select ContractStartDate FROM HVProgram P where HVProgramPK=@ProgramFK);
	set @ContractEndDate = (select ContractEndDate FROM HVProgram P where HVProgramPK=@ProgramFK);

	select @ContractStartDate AS ContractStartDate,@ContractEndDate AS ContractEndDate

	--if @ProgramFK is NOT NULL     
	--select ContractStartDate,ContractEndDate FROM HVProgram  where HVProgramPK=@ProgramFK
	--ELSE 
	--select '' AS ContractStartDate, '' AS ContractEndDate

end
GO
