SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		<Dorothy Baum>
-- Create date: <05/29/09>
-- Description:	<returns dates of next and previous events for checking the proper order of events>
-- =============================================
CREATE PROCEDURE [dbo].[spGetDatesbyInterval](@Tablename varchar(20),@DateField varchar(20),
				@FKfield varchar(20), @FK int, @IntervalField varchar(20), 
				@PreviousInterval varchar(2),@NextInterval varchar(2),
				@NextDateOut datetime OUTPUT,@PreviousDateOut datetime OUTPUT)
	-- Add the parameters for the stored procedure here
	AS
	DECLARE @SelectStatement nVarchar(100);
	DECLARE @TheDate dateTime;


	SET @SelectStatement = N'Select @lDateOut = '+ @dateField+' FROM ' + @Tablename +
							' Where '+@FKfield+'=@lFk and '+
									  @IntervalField +'= @linterval'
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	-- execute the same statment with previous interval
	EXEC  sp_Executesql @SelectStatement,
						N'@lDateOut datetime OUTPUT, @lFk int, @linterval varchar(2)',
						@lFk=@Fk,@linterval=@PreviousInterval,@lDateOut=@TheDate OUTPUT;
	
	SET @PreviousDateOut=@TheDate
	-- null out the output so that it doesn't remember the original answer

	Set @TheDate= null


	-- execute with next interval
	EXEC  sp_Executesql @SelectStatement,
						N'@lDateOut datetime OUTPUT, @lFk int, @linterval varchar(2)',
						@lFk=@Fk,@linterval=@NextInterval,@lDateOut=@TheDate OUTPUT;
	
	-- set the output variable
	SET @NextDateOut=@TheDate

	

GO
