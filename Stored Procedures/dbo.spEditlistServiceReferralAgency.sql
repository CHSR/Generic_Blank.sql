SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditlistServiceReferralAgency](@listServiceReferralAgencyPK int=NULL,
@AgencyIsActive bit=NULL,
@AgencyName varchar(100)=NULL,
@ProgramFK int=NULL)
AS
UPDATE listServiceReferralAgency
SET 
AgencyIsActive = @AgencyIsActive, 
AgencyName = @AgencyName, 
ProgramFK = @ProgramFK
WHERE listServiceReferralAgencyPK = @listServiceReferralAgencyPK
GO
