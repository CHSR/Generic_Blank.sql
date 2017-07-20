SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddServiceReferral](@FamilyCode char(2)=NULL,
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
@ServiceReferralCreator char(10)=NULL,
@StartDate datetime=NULL)
AS
INSERT INTO ServiceReferral(
FamilyCode,
FamilyCodeSpecify,
FSWFK,
HVCaseFK,
NatureOfReferral,
OtherServiceSpecify,
ProgramFK,
ProvidingAgencyFK,
ReasonNoService,
ReasonNoServiceSpecify,
ReferralDate,
ServiceCode,
ServiceReceived,
ServiceReferralCreator,
StartDate
)
VALUES(
@FamilyCode,
@FamilyCodeSpecify,
@FSWFK,
@HVCaseFK,
@NatureOfReferral,
@OtherServiceSpecify,
@ProgramFK,
@ProvidingAgencyFK,
@ReasonNoService,
@ReasonNoServiceSpecify,
@ReferralDate,
@ServiceCode,
@ServiceReceived,
@ServiceReferralCreator,
@StartDate
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
