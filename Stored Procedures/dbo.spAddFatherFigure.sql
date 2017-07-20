SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddFatherFigure](@DateAcceptService datetime=NULL,
@DateInactive datetime=NULL,
@FatherAdvocateFK int=NULL,
@FatherFigureCreator char(10)=NULL,
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
INSERT INTO FatherFigure(
DateAcceptService,
DateInactive,
FatherAdvocateFK,
FatherFigureCreator,
HVCaseFK,
IsOBP,
IsPC2,
IsOther,
LiveInPC1Home,
MarriedToPC1,
PC2InPC1Home,
PCFK,
ProgramFK,
RelationToTargetChild,
RelationToTargetChildOther
)
VALUES(
@DateAcceptService,
@DateInactive,
@FatherAdvocateFK,
@FatherFigureCreator,
@HVCaseFK,
@IsOBP,
@IsPC2,
@IsOther,
@LiveInPC1Home,
@MarriedToPC1,
@PC2InPC1Home,
@PCFK,
@ProgramFK,
@RelationToTargetChild,
@RelationToTargetChildOther
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
