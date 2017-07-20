SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		<Dorothy Baum>
-- Create date: <June 29, 2009>
-- Description:	<Multi-call to get all the data for the ASQ Form>
-- =============================================
CREATE PROCEDURE [dbo].[spGetASQSEEditForm]-- Add the parameters for the stored procedure here
    @myASQSEPK INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
	DECLARE @myTCIDFK     INT,
            @myTCAge      CHAR(2),
            @myASQSEVersion VARCHAR(10)
	EXEC spGetASQSEbyPKWithOutput @ASQSEPK = @myASQSEPK, @TCIDFK = @myTCIDFK OUTPUT, @TCAge = @myTCAge OUTPUT, @ASQSEVersion = @myASQSEVersion OUTPUT
	EXEC spGetScoreASQSEbyTCAGEVersion @TCAge = @myTCAge, @ASQSEVersion = @myASQSEVersion

END
GO
