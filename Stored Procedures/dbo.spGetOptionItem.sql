SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Dorothy Baum>
-- Create date: <June 19,2009>
-- Description:	<Return the OptionValue for OptionItem, ProgramCode, for specify date>
-- =============================================
create PROCEDURE [dbo].[spGetOptionItem]
	(@OptionItem varchar(50),@ProgramFK int,@CompareDate datetime, @OptionValue varchar(200) output)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT @OptionValue = OptionValue FROM appOptions 
    WHERE OptionItem  = @OptionItem and 
		  ProgramFK = @ProgramFK and 
		  @CompareDate between 
		  OptionStart and isnull(OptionEnd,getdate())

END

GO
