SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		<Dorothy Baum>
-- Create date: <June 16, 2009>
-- Description:	<Multi-call to get all the data for the ASQ Form>
-- =============================================
create PROCEDURE [dbo].[spGetASQEditForm]
	-- Add the parameters for the stored procedure here
@myASQPK int	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
declare @myTCIDFK int, @myTCAge char(2), @myASQVersion varchar(10)
exec spGetASQbyPKWithOutput @ASQPK=@myASQPK,@TCIDFK=@myTCIDFK Output, @TCAge=@myTCAge Output,@ASQVersion =@myASQVersion Output
exec spGetScoreASQbyTCAGEVersion @TCAge=@myTCAge,@ASQVersion = @myASQVersion

END




GO
