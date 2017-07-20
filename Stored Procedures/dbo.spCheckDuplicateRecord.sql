SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		<Dorothy Baum>
-- Create date: <05/29/09>
-- Description:	<returns dates of next and previous events for checking the proper order of events>
-- =============================================
create PROCEDURE [dbo].[spCheckDuplicateRecord](@Tablename varchar(20),@DateField varchar(20),
				@FKfield varchar(20), @FK int, @FormDate datetime,@PkField varchar(20), @PK int, 
				@HasDuplicate bit OUTPUT)
	-- Add the parameters for the stored procedure here
	AS
	DECLARE @SelectStatement nVarchar(150);
	DECLARE @RecCount int;
	

	SET @SelectStatement = N'Select @recordCount = Count(*) FROM ' + @Tablename +
							' Where '+@FKfield+'=@lFk and '+ @PkField+'<>@lPK and '+ @DateField +'=@TheFormDate'
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- execute with next interval
	EXEC  sp_Executesql @SelectStatement,
						N'@lFk int, @lPk int,@TheFormDate datetime,@RecordCount int OUTPUT',
						@lFk=@Fk, @lPk=@PK, @TheFormDate=@FormDate, @RecordCount=@RecCount OUTPUT;
	
	-- set the output variable
	IF @RecCount>0
		SET @HasDuplicate= 1
	Else	
		Set @HasDuplicate = 0

	
GO
