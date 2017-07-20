SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddPreassessment](@CaseStatus char(2)=NULL,
@DischargeReason char(2)=NULL,
@DischargeReasonSpecify varchar(500)=NULL,
@DischargeSafetyReason char(2)=NULL,
@DischargeSafetyReasonDV bit=NULL,
@DischargeSafetyReasonMH bit=NULL,
@DischargeSafetyReasonOther bit=NULL,
@DischargeSafetyReasonSA bit=NULL,
@DischargeSafetyReasonSpecify varchar(500)=NULL,
@FSWAssignDate datetime=NULL,
@HVCaseFK int=NULL,
@KempeDate datetime=NULL,
@KempeResult bit=NULL,
@PAActivitySpecify varchar(500)=NULL,
@PACall2Parent int=NULL,
@PACallFromParent int=NULL,
@PACaseReview int=NULL,
@PACreator char(10)=NULL,
@PADate datetime=NULL,
@PAFAWFK int=NULL,
@PAFSWFK int=NULL,
@PAGift int=NULL,
@PAOtherActivity int=NULL,
@PAOtherHVProgram int=NULL,
@PAParent2Office int=NULL,
@PAParentLetter int=NULL,
@PAProgramMaterial int=NULL,
@PAVisitAttempt int=NULL,
@PAVisitMade int=NULL,
@ProgramFK int=NULL,
@TransferredtoProgram varchar(50)=NULL)
AS
INSERT INTO Preassessment(
CaseStatus,
DischargeReason,
DischargeReasonSpecify,
DischargeSafetyReason,
DischargeSafetyReasonDV,
DischargeSafetyReasonMH,
DischargeSafetyReasonOther,
DischargeSafetyReasonSA,
DischargeSafetyReasonSpecify,
FSWAssignDate,
HVCaseFK,
KempeDate,
KempeResult,
PAActivitySpecify,
PACall2Parent,
PACallFromParent,
PACaseReview,
PACreator,
PADate,
PAFAWFK,
PAFSWFK,
PAGift,
PAOtherActivity,
PAOtherHVProgram,
PAParent2Office,
PAParentLetter,
PAProgramMaterial,
PAVisitAttempt,
PAVisitMade,
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
@FSWAssignDate,
@HVCaseFK,
@KempeDate,
@KempeResult,
@PAActivitySpecify,
@PACall2Parent,
@PACallFromParent,
@PACaseReview,
@PACreator,
@PADate,
@PAFAWFK,
@PAFSWFK,
@PAGift,
@PAOtherActivity,
@PAOtherHVProgram,
@PAParent2Office,
@PAParentLetter,
@PAProgramMaterial,
@PAVisitAttempt,
@PAVisitMade,
@ProgramFK,
@TransferredtoProgram
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO