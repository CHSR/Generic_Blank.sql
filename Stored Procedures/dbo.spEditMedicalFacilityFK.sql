SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 11/16/2012
-- Description:	Change MedicalProviderFK when using Duplicate Remover page
-- =============================================
CREATE PROCEDURE [dbo].[spEditMedicalFacilityFK]
	-- Add the parameters for the stored procedure here
	@oldFacilityFK as integer,
	@newFacilityFK as integer
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Update CommonAttributes 
	SET PC1MedicalFacilityFK=@newFacilityFK
	, TCMedicalFacilityFK=@newFacilityFK
	WHERE PC1MedicalFacilityFK=@oldFacilityFK
	OR TCMedicalFacilityFK=@oldFacilityFK

END
GO
