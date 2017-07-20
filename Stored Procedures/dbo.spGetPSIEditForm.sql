SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Dar Chen
-- Create date: 4/2/2012
-- Description: 
-- =============================================
CREATE PROCEDURE [dbo].[spGetPSIEditForm]
@myPSIPK int	
AS
BEGIN
	SET NOCOUNT ON;
	select *
	from [dbo].[PSI]
	where [PSIPK] = @myPSIPK
END




GO
