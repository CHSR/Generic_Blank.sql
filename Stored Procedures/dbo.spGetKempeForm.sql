SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		<Dorothy Baum>
-- Create date: <July 20, 2009>
-- Description:	<Multi-call to get all the data for the Kempe Form for ADDING A New One>
-- =============================================
CREATE PROCEDURE [dbo].[spGetKempeForm]
	-- Add the parameters for the stored procedure here
@myHVCaseFK int,
@myProgramFK int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
Declare @myPC1PK int
    -- Insert statements for procedure here
Select @myPC1PK =PC1FK 
from HVCase
where HVCasePK= @myHVCaseFK

exec spGetHVCasebyPK @myHVCaseFK
exec spGetPreassessmentAssessmentCompletedbyHVCaseFK @myHVCaseFK,@myProgramFK
exec spGetPCbyPK @myPC1PK
exec spGetCommonAttributesbyHVCaseFKForm @myHVCaseFK,@myProgramFK, "SC"

END










GO
