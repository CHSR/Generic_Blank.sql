SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditASQ](@ASQPK int=NULL,
@ProgramFK int=NULL,
@ASQCommunicationScore numeric(4, 1)=NULL,
@ASQEditor char(10)=NULL,
@ASQFineMotorScore numeric(4, 1)=NULL,
@ASQGrossMotorScore numeric(4, 1)=NULL,
@ASQInWindow bit=NULL,
@ASQPersonalSocialScore numeric(4, 1)=NULL,
@ASQProblemSolvingScore numeric(4, 1)=NULL,
@ASQTCReceiving char(1)=NULL,
@DateCompleted datetime=NULL,
@DevServicesStartDate date=NULL,
@DiscussedWithPC1 bit=NULL,
@FSWFK int=NULL,
@HVCaseFK int=NULL,
@ReviewCDS bit=NULL,
@TCAge char(2)=NULL,
@TCIDFK int=NULL,
@TCReferred char(1)=NULL,
@UnderCommunication bit=NULL,
@UnderFineMotor bit=NULL,
@UnderGrossMotor bit=NULL,
@UnderPersonalSocial bit=NULL,
@UnderProblemSolving bit=NULL,
@VersionNumber varchar(10)=NULL)
AS
UPDATE ASQ
SET 
ProgramFK = @ProgramFK, 
ASQCommunicationScore = @ASQCommunicationScore, 
ASQEditor = @ASQEditor, 
ASQFineMotorScore = @ASQFineMotorScore, 
ASQGrossMotorScore = @ASQGrossMotorScore, 
ASQInWindow = @ASQInWindow, 
ASQPersonalSocialScore = @ASQPersonalSocialScore, 
ASQProblemSolvingScore = @ASQProblemSolvingScore, 
ASQTCReceiving = @ASQTCReceiving, 
DateCompleted = @DateCompleted, 
DevServicesStartDate = @DevServicesStartDate, 
DiscussedWithPC1 = @DiscussedWithPC1, 
FSWFK = @FSWFK, 
HVCaseFK = @HVCaseFK, 
ReviewCDS = @ReviewCDS, 
TCAge = @TCAge, 
TCIDFK = @TCIDFK, 
TCReferred = @TCReferred, 
UnderCommunication = @UnderCommunication, 
UnderFineMotor = @UnderFineMotor, 
UnderGrossMotor = @UnderGrossMotor, 
UnderPersonalSocial = @UnderPersonalSocial, 
UnderProblemSolving = @UnderProblemSolving, 
VersionNumber = @VersionNumber
WHERE ASQPK = @ASQPK
GO
