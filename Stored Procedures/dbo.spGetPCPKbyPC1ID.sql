SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spGetPCPKbyPC1ID] 
	-- Add the parameters for the stored procedure here

	@PC1ID as char(13) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT pc1fk FROM hvcase
	LEFT JOIN caseprogram ON caseprogram.hvcasefk=hvcase.hvcasepk 
	WHERE caseprogram.pc1id=@pc1id
END
GO
