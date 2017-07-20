SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Chris Papas>
-- Create date: <07/17/12>
-- Description:	<modified version of Jay's spAddFormReview_userTrigger, that eliminates the HVCaseFK requirement 
-- and then reads the codeForm table to get the fields needed to write query of last
-- record rewritten and writes a record into FormReview Table.>
-- =============================================
CREATE PROCEDURE [dbo].[spAddFormReview_userTRIGGERnoHVCaseFK](@FormFK int, @FormTypeValue char(2))
	-- Add the parameters for the stored procedure here
	AS

Declare @TableName varchar(20), @FormDateName varchar(20), 
        @CreatorName varchar(40), @PKName as varchar(20),
		@SelectStatement nVarchar(700),
	    @DateValue datetime, @CreatorValue varchar(20), 
		@PrgFKValue int, 
		@CanBeReviewed bit;

	--make sure that the form is able to be reviewed
	-- query the codeForm table using the FormType to get the field names
	select @TableName = MaintableName,
		   @FormDateName = FormDateName,
		   @CreatorName = CreatorFieldName,
		   @PKName = FormPKName,
		   @CanBeReviewed = CanBeReviewed from codeForm  
	where codeFormAbbreviation=@FormTypeValue;

	IF @CanBeReviewed = 0
		BEGIN
			RETURN
		END

		--set up the query with the fieldnames from the previous query to get the values
			BEGIN
				SET @SelectStatement = N'Select @lFormDate = '+ @FormDateName+'
										  ,@ProgramFK = ProgramFK,
											@Creator  = '+ @CreatorName + ' 
									 FROM ' + @Tablename +
									' Where '+ @PKName +' = @PK'
			END

SET NOCOUNT ON; 

--run the query
EXEC  sp_Executesql @SelectStatement, N'@ProgramFK int OUTPUT, @lFormDate datetime OUTPUT, @Creator varchar(40)OUTPUT, @PK int OUTPUT' ,
				@ProgramFK=@PrgFKValue OUTPUT,@lFormDate = @DateValue output,@Creator = @CreatorValue OUTPUT, @PK=@FormFK OUTPUT ;
 
--run the stored procedure to insert the values obtained in the last query into the FormReview Table
-- don't use stored procedure because it returns identity value on PK and interferes with the main table's PK
--EXEC spAddFormReview @FormType = @FormTypeValue, @FormFK = @FormFK, @FormDate = @DateValue,
--                     @HVCaseFK = @HVCaseFKValue, @ProgramFK = @PrgFKValue, @FormReviewCreator = @CreatorValue
	
INSERT INTO FormReview(FormType,FormFK,FormDate,HVCaseFK,ProgramFK,FormReviewCreator)
Values(@FormTypeValue,@FormFK,@DateValue,NULL,@PrgFKValue,@CreatorValue)
GO
