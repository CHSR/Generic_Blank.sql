SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetlistMedicalFacilitybyPK]

(@listMedicalFacilityPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM listMedicalFacility
WHERE listMedicalFacilityPK = @listMedicalFacilityPK
GO
