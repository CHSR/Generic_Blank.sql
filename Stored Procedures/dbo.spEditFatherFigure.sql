SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditFatherFigure](@FatherFigurePK int=NULL,
@DateAcceptService datetime=NULL,
@DateInactive datetime=NULL,
@FatherAdvocateFK int=NULL,
@FatherFigureEditor char(10)=NULL,
@HVCaseFK int=NULL,
@IsOBP bit=NULL,
@IsPC2 bit=NULL,
@IsOther bit=NULL,
@LiveInPC1Home bit=NULL,
@MarriedToPC1 bit=NULL,
@PC2InPC1Home bit=NULL,
@PCFK int=NULL,
@ProgramFK int=NULL,
@RelationToTargetChild char(2)=NULL,
@RelationToTargetChildOther varchar(100)=NULL)
AS
UPDATE FatherFigure
SET 
DateAcceptService = @DateAcceptService, 
DateInactive = @DateInactive, 
FatherAdvocateFK = @FatherAdvocateFK, 
FatherFigureEditor = @FatherFigureEditor, 
HVCaseFK = @HVCaseFK, 
IsOBP = @IsOBP, 
IsPC2 = @IsPC2, 
IsOther = @IsOther, 
LiveInPC1Home = @LiveInPC1Home, 
MarriedToPC1 = @MarriedToPC1, 
PC2InPC1Home = @PC2InPC1Home, 
PCFK = @PCFK, 
ProgramFK = @ProgramFK, 
RelationToTargetChild = @RelationToTargetChild, 
RelationToTargetChildOther = @RelationToTargetChildOther
WHERE FatherFigurePK = @FatherFigurePK
GO
