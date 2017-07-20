SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditASQSE](@ASQSEPK int=NULL,
@ASQSEDateCompleted datetime=NULL,
@ASQSEEditor char(10)=NULL,
@ASQSEInWindow bit=NULL,
@ASQSEOverCutOff bit=NULL,
@ASQSEReceiving char(1)=NULL,
@ASQSEReferred char(1)=NULL,
@ASQSETCAge char(2)=NULL,
@ASQSETotalScore numeric(4, 1)=NULL,
@ASQSEVersion varchar(10)=NULL,
@DiscussedWithPC1 bit=NULL,
@FSWFK int=NULL,
@ReviewCDS bit=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL,
@TCIDFK int=NULL)
AS
UPDATE ASQSE
SET 
ASQSEDateCompleted = @ASQSEDateCompleted, 
ASQSEEditor = @ASQSEEditor, 
ASQSEInWindow = @ASQSEInWindow, 
ASQSEOverCutOff = @ASQSEOverCutOff, 
ASQSEReceiving = @ASQSEReceiving, 
ASQSEReferred = @ASQSEReferred, 
ASQSETCAge = @ASQSETCAge, 
ASQSETotalScore = @ASQSETotalScore, 
ASQSEVersion = @ASQSEVersion, 
DiscussedWithPC1 = @DiscussedWithPC1, 
FSWFK = @FSWFK, 
ReviewCDS = @ReviewCDS, 
HVCaseFK = @HVCaseFK, 
ProgramFK = @ProgramFK, 
TCIDFK = @TCIDFK
WHERE ASQSEPK = @ASQSEPK
GO
