SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Dorothy Baum
-- Create date: Aug 27, 2009 >
-- Description:	Select CaseProgram data by FormDate and HVCasePK
-- =============================================
create PROCEDURE [dbo].[spGetCaseProgrambyDate](@HVCaseFK int,@FormDate datetime)  
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT * FROM CaseProgram
WHERE HVCaseFK=@HVCaseFK
and @FormDate >= casestartdate and
(@FormDate<=dischargedate or dischargedate is null)
END
GO
