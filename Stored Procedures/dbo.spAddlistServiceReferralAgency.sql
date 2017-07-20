SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddlistServiceReferralAgency](@AgencyIsActive bit=NULL,
@AgencyName varchar(100)=NULL,
@ProgramFK int=NULL)
AS
INSERT INTO listServiceReferralAgency(
AgencyIsActive,
AgencyName,
ProgramFK
)
VALUES(
@AgencyIsActive,
@AgencyName,
@ProgramFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
