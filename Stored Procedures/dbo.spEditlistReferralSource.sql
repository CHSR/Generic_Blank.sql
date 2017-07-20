SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditlistReferralSource](@listReferralSourcePK int=NULL,
@ProgramFK int=NULL,
@ReferralSourceName char(50)=NULL,
@RSIsActive bit=NULL,
@listReferralSourcePK_old int=NULL,
@IsMICHC bit=NULL)
AS
UPDATE listReferralSource
SET 
ProgramFK = @ProgramFK, 
ReferralSourceName = @ReferralSourceName, 
RSIsActive = @RSIsActive, 
listReferralSourcePK_old = @listReferralSourcePK_old, 
IsMICHC = @IsMICHC
WHERE listReferralSourcePK = @listReferralSourcePK
GO
