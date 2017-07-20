SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditcodeLevel](@codeLevelPK int=NULL,
@CaseWeight numeric(4, 2)=NULL,
@ConstantName varchar(50)=NULL,
@Enrolled bit=NULL,
@LevelGroup char(10)=NULL,
@LevelName varchar(50)=NULL,
@MaximumVisit numeric(4, 2)=NULL,
@MinimumVisit numeric(4, 2)=NULL,
@SubLevelFK int=NULL,
@LevelAbbr varchar(10)=NULL)
AS
UPDATE codeLevel
SET 
CaseWeight = @CaseWeight, 
ConstantName = @ConstantName, 
Enrolled = @Enrolled, 
LevelGroup = @LevelGroup, 
LevelName = @LevelName, 
MaximumVisit = @MaximumVisit, 
MinimumVisit = @MinimumVisit, 
SubLevelFK = @SubLevelFK, 
LevelAbbr = @LevelAbbr
WHERE codeLevelPK = @codeLevelPK
GO
