SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddPreintake](@CaseStatus char(2)=NULL,
@DischargeReason char(2)=NULL,
@DischargeReasonSpecify varchar(500)=NULL,
@DischargeSafetyReason char(2)=NULL,
@DischargeSafetyReasonDV bit=NULL,
@DischargeSafetyReasonMH bit=NULL,
@DischargeSafetyReasonOther bit=NULL,
@DischargeSafetyReasonSA bit=NULL,
@DischargeSafetyReasonSpecify varchar(500)=NULL,
@HVCaseFK int=NULL,
@KempeFK int=NULL,
@PIActivitySpecify varchar(500)=NULL,
@PICall2Parent int=NULL,
@PICallFromParent int=NULL,
@PICaseReview int=NULL,
@PICreator char(10)=NULL,
@PIDate datetime=NULL,
@PIFSWFK int=NULL,
@PIGift int=NULL,
@PIOtherActivity int=NULL,
@PIOtherHVProgram int=NULL,
@PIParent2Office int=NULL,
@PIParentLetter int=NULL,
@PIProgramMaterial int=NULL,
@PIVisitAttempt int=NULL,
@PIVisitMade int=NULL,
@ProgramFK int=NULL,
@TransferredtoProgram varchar(50)=NULL)
AS
INSERT INTO Preintake(
CaseStatus,
DischargeReason,
DischargeReasonSpecify,
DischargeSafetyReason,
DischargeSafetyReasonDV,
DischargeSafetyReasonMH,
DischargeSafetyReasonOther,
DischargeSafetyReasonSA,
DischargeSafetyReasonSpecify,
HVCaseFK,
KempeFK,
PIActivitySpecify,
PICall2Parent,
PICallFromParent,
PICaseReview,
PICreator,
PIDate,
PIFSWFK,
PIGift,
PIOtherActivity,
PIOtherHVProgram,
PIParent2Office,
PIParentLetter,
PIProgramMaterial,
PIVisitAttempt,
PIVisitMade,
ProgramFK,
TransferredtoProgram
)
VALUES(
@CaseStatus,
@DischargeReason,
@DischargeReasonSpecify,
@DischargeSafetyReason,
@DischargeSafetyReasonDV,
@DischargeSafetyReasonMH,
@DischargeSafetyReasonOther,
@DischargeSafetyReasonSA,
@DischargeSafetyReasonSpecify,
@HVCaseFK,
@KempeFK,
@PIActivitySpecify,
@PICall2Parent,
@PICallFromParent,
@PICaseReview,
@PICreator,
@PIDate,
@PIFSWFK,
@PIGift,
@PIOtherActivity,
@PIOtherHVProgram,
@PIParent2Office,
@PIParentLetter,
@PIProgramMaterial,
@PIVisitAttempt,
@PIVisitMade,
@ProgramFK,
@TransferredtoProgram
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
