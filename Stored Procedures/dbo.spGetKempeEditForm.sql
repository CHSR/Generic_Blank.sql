SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dorothy Baum>
-- Create date: <July 24, 2009>
-- Modified: <Sept 3, 2009> changed to use KempePK as parameter
-- Description:	<Multi-call to get all the data for the Kempe Form for EDITING>
-- =============================================
CREATE procedure [dbo].[spGetKempeEditForm] @myKempePK int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
Declare @lPC1PK int,
	    @lPC1IssuesFK int,
		@lHVCaseFK int;
    -- Insert statements for procedure here

Select @lHVCaseFK = HVCaseFK,
	   @lPC1IssuesFK = PC1IssuesFK
From Kempe
Where KempePK=@myKempePK


Select @lPC1PK =PC1FK
from HVCase
where HVCasePK= @lHVCaseFK

Select @lPC1IssuesFK=PC1IssuesFK 
from Kempe
where HVCasefk=@lHVCaseFK

exec spGetHVCasebyPK @lHVCaseFK
exec spGetKempebyHVCaseFK @lHVCaseFK
exec spGetPreassessmentAssessmentCompletedbyHVCaseFK @lHVCaseFK,null
exec spGetPCbyPK @lPC1PK
exec spGetCommonAttributesbyForm @myKempePK, 'KE'
exec spGetAuditCbyForm @myKempePK, 'KE'
exec spGetHITSbyForm @myKempePK, 'KE'
exec spGetPHQ9ByForm @myKempePK, 'KE'

exec spGetPC1IssuesbyPK @lPC1IssuesFK

END
GO
