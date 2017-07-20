SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddFormReview](@FormDate datetime=NULL,
@FormFK int=NULL,
@FormReviewCreator char(10)=NULL,
@FormType char(2)=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL,
@ReviewDateTime datetime=NULL,
@ReviewedBy varchar(10)=NULL)
AS
INSERT INTO FormReview(
FormDate,
FormFK,
FormReviewCreator,
FormType,
HVCaseFK,
ProgramFK,
ReviewDateTime,
ReviewedBy
)
VALUES(
@FormDate,
@FormFK,
@FormReviewCreator,
@FormType,
@HVCaseFK,
@ProgramFK,
@ReviewDateTime,
@ReviewedBy
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
