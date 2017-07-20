SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditFormReviewOptions](@FormReviewOptionsPK int=NULL,
@FormReviewEndDate datetime=NULL,
@FormReviewOptionsEditor char(10)=NULL,
@FormReviewStartDate datetime=NULL,
@FormType char(2)=NULL,
@ProgramFK int=NULL)
AS
UPDATE FormReviewOptions
SET 
FormReviewEndDate = @FormReviewEndDate, 
FormReviewOptionsEditor = @FormReviewOptionsEditor, 
FormReviewStartDate = @FormReviewStartDate, 
FormType = @FormType, 
ProgramFK = @ProgramFK
WHERE FormReviewOptionsPK = @FormReviewOptionsPK
GO
