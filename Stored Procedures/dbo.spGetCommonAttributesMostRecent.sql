SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spGetCommonAttributesMostRecent] 
	@HVCaseFK [int],
	@ProgramFK [int]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT top 1 *
FROM CommonAttributes
WHERE HVCaseFK = @HVCaseFK
AND ProgramFK = @ProgramFK
order by FormDate desc

END
GO
