SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelcodeDueByDates](@codeDueByDatesPK int)

AS


DELETE 
FROM codeDueByDates
WHERE codeDueByDatesPK = @codeDueByDatesPK
GO
