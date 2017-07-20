SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDellistMedicalFacility](@listMedicalFacilityPK int)

AS


DELETE 
FROM listMedicalFacility
WHERE listMedicalFacilityPK = @listMedicalFacilityPK
GO
