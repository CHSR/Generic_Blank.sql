SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Devinder S Khalsa
-- Create date: 12/2/2011
-- Description:	Increments the PC1ID table for use as last 9 numbers of PC1ID
-- Usage: spGetNextPC1ID 19
-- =============================================
CREATE PROCEDURE [dbo].[spGetNextPC1ID]
	-- Add the parameters for the stored procedure here
	@ProgramNumber INT,
	@nextnumber varchar(9) OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ProgramCode CHAR(3)

	IF EXISTS (SELECT TOP 1 * FROM HVProgram h WHERE HVProgramPK = @ProgramNumber)
    
		BEGIN
		
			UPDATE PC1ID
			SET NextNum = (NextNum + 1)		
		
			-- Insert statements for procedure here
			-- get the program code first, given program number
			SET @ProgramCode = (SELECT TOP 1  ProgramCode FROM HVProgram h WHERE HVProgramPK = @ProgramNumber)
			
			-- put together programcode and 6 digit autogenerated number
			SET @nextnumber = @ProgramCode + CONVERT(VARCHAR(6), (SELECT TOP 1 NextNum FROM PC1ID))
			
		END

END



GO