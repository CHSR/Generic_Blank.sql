SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditscoreASQSE](@scoreASQSEPK int=NULL,
@ASQSEVersion varchar(10)=NULL,
@MaximumASQSEScore numeric(3, 0)=NULL,
@SocialEmotionalScore numeric(6, 2)=NULL,
@TCAge char(4)=NULL)
AS
UPDATE scoreASQSE
SET 
ASQSEVersion = @ASQSEVersion, 
MaximumASQSEScore = @MaximumASQSEScore, 
SocialEmotionalScore = @SocialEmotionalScore, 
TCAge = @TCAge
WHERE scoreASQSEPK = @scoreASQSEPK
GO
