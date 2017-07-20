SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddFormReviewOptions](@FormReviewEndDate datetime=NULL,
@FormReviewOptionsCreator char(10)=NULL,
@FormReviewStartDate datetime=NULL,
@FormType char(2)=NULL,
@ProgramFK int=NULL)
AS
INSERT INTO FormReviewOptions(
FormReviewEndDate,
FormReviewOptionsCreator,
FormReviewStartDate,
FormType,
ProgramFK
)
VALUES(
@FormReviewEndDate,
@FormReviewOptionsCreator,
@FormReviewStartDate,
@FormType,
@ProgramFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
