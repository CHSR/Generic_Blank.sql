SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditcodeInterval](@codeIntervalPK int=NULL,
@IntervalDescription char(100)=NULL,
@IntervalMaxMonth int=NULL,
@IntervalName char(10)=NULL)
AS
UPDATE codeInterval
SET 
IntervalDescription = @IntervalDescription, 
IntervalMaxMonth = @IntervalMaxMonth, 
IntervalName = @IntervalName
WHERE codeIntervalPK = @codeIntervalPK
GO
