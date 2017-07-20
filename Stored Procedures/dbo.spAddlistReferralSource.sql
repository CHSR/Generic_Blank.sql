SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddlistReferralSource](@ProgramFK int=NULL,
@ReferralSourceName char(50)=NULL,
@RSIsActive bit=NULL,
@listReferralSourcePK_old int=NULL,
@IsMICHC bit=NULL)
AS
INSERT INTO listReferralSource(
ProgramFK,
ReferralSourceName,
RSIsActive,
listReferralSourcePK_old,
IsMICHC
)
VALUES(
@ProgramFK,
@ReferralSourceName,
@RSIsActive,
@listReferralSourcePK_old,
@IsMICHC
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
