SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Chris Papas
-- Create date: 06/18/2014
-- Description:	Get everyone who's Active
-- =============================================
CREATE procedure [dbo].[rspGetActiveCaseCount]
(
    @programfk int    = null
)

as
begin

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

	select COUNT(PC1ID) AS theCount FROM dbo.CaseProgram
	WHERE ProgramFK = @programfk
	AND DischargeDate IS NULL
	
end
GO
