SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddNewReferralSource](@ProgramFK int=NULL,
@ReferralSourceName char(50)=NULL,
@RSIsActive bit=NULL,
@listReferralSourcePK_old int=NULL)
AS

-- Stops inserting duplicates Referral Source Name in a given program
IF(NOT EXISTS(SELECT * FROM listReferralSource WHERE ProgramFK = @ProgramFK AND ReferralSourceName = @ReferralSourceName))
BEGIN 

	INSERT INTO listReferralSource(
	ProgramFK,
	ReferralSourceName,
	RSIsActive,
	listReferralSourcePK_old
	)
	VALUES(
	@ProgramFK,
	@ReferralSourceName,
	@RSIsActive,
	@listReferralSourcePK_old
	)
	
	SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
	
END
ELSE 
BEGIN 
	-- get the existing ReferralSource so that we can SELECT in the dropdown list in HVSCreen.aspx
	SELECT TOP 1 listReferralSourcePK  AS [SCOPE_IDENTITY] from listReferralSource
	WHERE ProgramFK = @ProgramFK AND ReferralSourceName = @ReferralSourceName
END 


GO
