SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditFormReview](@FormReviewPK int=NULL,
@FormDate datetime=NULL,
@FormFK int=NULL,
@FormReviewEditor char(10)=NULL,
@FormType char(2)=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL,
@ReviewDateTime datetime=NULL,
@ReviewedBy varchar(10)=NULL)
AS
UPDATE FormReview
SET 
FormDate = @FormDate, 
FormFK = @FormFK, 
FormReviewEditor = @FormReviewEditor, 
FormType = @FormType, 
HVCaseFK = @HVCaseFK, 
ProgramFK = @ProgramFK, 
ReviewDateTime = @ReviewDateTime, 
ReviewedBy = @ReviewedBy
WHERE FormReviewPK = @FormReviewPK
GO
