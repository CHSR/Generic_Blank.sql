SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetlistMedicalProviderbyPK]

(@listMedicalProviderPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM listMedicalProvider
WHERE listMedicalProviderPK = @listMedicalProviderPK
GO
