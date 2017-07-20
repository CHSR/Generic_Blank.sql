SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelAppOptions](@AppOptionsPK int)

AS


DELETE 
FROM AppOptions
WHERE AppOptionsPK = @AppOptionsPK
GO
