SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Chris Papas
-- Create date: Nov. 19, 2012
-- Description:	Get all Medical Facilities by Program 
-- =============================================
CREATE procedure [dbo].[spGetAllListMedicalFacilities] (@programfk int)

AS

	SELECT *
	FROM dbo.listMedicalFacility
	WHERE ProgramFK = ISNULL(@ProgramFK,ProgramFK)
	ORDER BY MFName, MFAddress
GO
