SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditlistCaseFilterName](@listCaseFilterNamePK int=NULL,
@FieldTitle varchar(50)=NULL,
@FilterType char(2)=NULL,
@Hint varchar(100)=NULL,
@ProgramFK int=NULL,
@Inactive bit=NULL)
AS
UPDATE listCaseFilterName
SET 
FieldTitle = @FieldTitle, 
FilterType = @FilterType, 
Hint = @Hint, 
ProgramFK = @ProgramFK, 
Inactive = @Inactive
WHERE listCaseFilterNamePK = @listCaseFilterNamePK
GO
