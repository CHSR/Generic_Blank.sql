SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetcodeDueByDatesbyPK]

(@codeDueByDatesPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM codeDueByDates
WHERE codeDueByDatesPK = @codeDueByDatesPK
GO
