SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeInterval](@IntervalDescription char(100)=NULL,
@IntervalMaxMonth int=NULL,
@IntervalName char(10)=NULL)
AS
INSERT INTO codeInterval(
IntervalDescription,
IntervalMaxMonth,
IntervalName
)
VALUES(
@IntervalDescription,
@IntervalMaxMonth,
@IntervalName
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
