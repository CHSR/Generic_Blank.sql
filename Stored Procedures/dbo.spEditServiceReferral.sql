SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditServiceReferral](@ServiceReferralPK int=NULL,
@FamilyCode char(2)=NULL,
@FamilyCodeSpecify varchar(100)=NULL,
@FSWFK int=NULL,
@HVCaseFK int=NULL,
@NatureOfReferral char(2)=NULL,
@OtherServiceSpecify varchar(500)=NULL,
@ProgramFK int=NULL,
@ProvidingAgencyFK int=NULL,
@ReasonNoService char(2)=NULL,
@ReasonNoServiceSpecify varchar(500)=NULL,
@ReferralDate datetime=NULL,
@ServiceCode char(2)=NULL,
@ServiceReceived char(1)=NULL,
@ServiceReferralEditor char(10)=NULL,
@StartDate datetime=NULL)
AS
UPDATE ServiceReferral
SET 
FamilyCode = @FamilyCode, 
FamilyCodeSpecify = @FamilyCodeSpecify, 
FSWFK = @FSWFK, 
HVCaseFK = @HVCaseFK, 
NatureOfReferral = @NatureOfReferral, 
OtherServiceSpecify = @OtherServiceSpecify, 
ProgramFK = @ProgramFK, 
ProvidingAgencyFK = @ProvidingAgencyFK, 
ReasonNoService = @ReasonNoService, 
ReasonNoServiceSpecify = @ReasonNoServiceSpecify, 
ReferralDate = @ReferralDate, 
ServiceCode = @ServiceCode, 
ServiceReceived = @ServiceReceived, 
ServiceReferralEditor = @ServiceReferralEditor, 
StartDate = @StartDate
WHERE ServiceReferralPK = @ServiceReferralPK
GO
