SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDellistMedicalProvider](@listMedicalProviderPK int)

AS


DELETE 
FROM listMedicalProvider
WHERE listMedicalProviderPK = @listMedicalProviderPK
GO
