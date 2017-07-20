SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		<Dorothy Baum>
-- Create date: <May 2009>
-- Description:	<returns the interval and the date it was completed for specified table/form>
-- =============================================
create PROCEDURE [dbo].[spGetAllIntervalsbyFK] 
	-- Add the parameters for the stored procedure here
	(@Tablename as varchar(20), @IntervalField as varchar(20),@DateField as varchar(20),@FkField as varchar(20), @FK as int)
AS
DECLARE @SQLString as nvarchar(200);
DECLARE @lForeignKey as int;


	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--SET @Parms = '@lForeignKey int'

    -- Insert statements for procedure here
	SET @SQLString = N'SELECT '+@IntervalField + ' AS Interval,'+ @DateField +' AS Dates FROM ' + @Tablename + ' WHERE ' + @FKField + ' = @lForeignKey' 
	

	EXEC sp_Executesql @SQLString, N'@lForeignKey int' , @lForeignKey=@fk ;
					  





GO
