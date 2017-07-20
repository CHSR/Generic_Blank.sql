SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Chris Papas
-- Create date: Nov. 16, 2012
-- Description:	Get all Medical Providers by Program 
-- =============================================
CREATE procedure [dbo].[spGetAllListMedicalProviders] (@programfk int)

AS

	SELECT *
	FROM dbo.listMedicalProvider
	WHERE ProgramFK = ISNULL(@ProgramFK,ProgramFK)
	ORDER BY mplastname, MPAddress
GO
