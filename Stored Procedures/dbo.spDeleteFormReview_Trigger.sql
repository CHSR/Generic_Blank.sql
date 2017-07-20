SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dorothy Baum>
-- Create date: <5/19/10>
-- Description:	<Called by Delete Trigger to delete matching record in FormReview Table>
-- =============================================
CREATE PROCEDURE [dbo].[spDeleteFormReview_Trigger] @FormFK int, @FormTypeValue char(2)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @FRPK int
    -- Insert statements for procedure here
	set @FRPK = (Select FormReviewPK from FormReview 
						 Where FormType= @FormTypeValue and 
							      FormFK = @FormFK)

	EXEC spDelFormReview @FormReviewPK=@FRPK
END
GO
