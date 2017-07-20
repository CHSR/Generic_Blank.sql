SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddscoreASQSE](@ASQSEVersion varchar(10)=NULL,
@MaximumASQSEScore numeric(3, 0)=NULL,
@SocialEmotionalScore numeric(6, 2)=NULL,
@TCAge char(4)=NULL)
AS
INSERT INTO scoreASQSE(
ASQSEVersion,
MaximumASQSEScore,
SocialEmotionalScore,
TCAge
)
VALUES(
@ASQSEVersion,
@MaximumASQSEScore,
@SocialEmotionalScore,
@TCAge
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
