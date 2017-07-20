SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





-- =============================================
-- Author:		<Dorothy Baum>
-- Create date: <05/29/09>
-- Description:	<returns boolean true if there is already a record with the same interval for the case/tcid 
-- for a different pk. (checking for duplicates)>
-- =============================================

create PROCEDURE [dbo].[spCheckDuplicateInterval](@Tablename varchar(20),@PkField varchar(20), @PK int,
				@FKfield varchar(20), @FK int, @IntervalField varchar(20),@Interval varchar(20), 
				@HasDuplicate bit OUTPUT)
	-- Add the parameters for the stored procedure here
	AS
	DECLARE @SelectStatement nVarchar(200);
	DECLARE @RecCount int;
	

	SET @SelectStatement = N'Select @recordCount = Count(*) FROM ' + @Tablename +
							' Where '+@FKfield+'=@lFk and '+@PkField+'<>@lPK and ' +
									  @IntervalField +'= @lInterval'
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- execute with next interval
	EXEC  sp_Executesql @SelectStatement,
						N'@lFk int, @lInterval varchar(20),@lPK int, @RecordCount int OUTPUT',
						@lFk=@Fk, @lInterval=@Interval, @lPK=@PK, @RecordCount=@RecCount OUTPUT;
	
	-- set the output variable
	IF @RecCount>0
		SET @HasDuplicate= 1
	Else	
		Set @HasDuplicate = 0

	

GO
