SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[spGetlistServiceReferralAgencybyName]

(@AgencyName AS VARCHAR(100), @ProgramFK AS INT)
AS
SET NOCOUNT ON;

SELECT * 
FROM listServiceReferralAgency
WHERE AgencyName = @AgencyName
AND ProgramFK = ISNULL(@ProgramFK, ProgramFK)

GO
