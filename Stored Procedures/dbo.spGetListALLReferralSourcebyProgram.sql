SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Chris Papas
-- Create date: 07/15/2009
-- Description:	Get ReferralSourcenames List by ProgramPK
-- =============================================
CREATE PROCEDURE [dbo].[spGetListALLReferralSourcebyProgram]
	@ProgramPK as Int = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select listReferralSourcePK
		 , ProgramFK
		 , ReferralSourceName + case when IsMICHC = 1 then ' (MICHC)' else '' end as ReferralSourceName
		 , RSIsActive
		 , listReferralSourcePK_old
		 , IsMICHC
	from 
	listReferralSource
	where ProgramFK = @ProgramPK
	order by ReferralSourceName
END

GO
