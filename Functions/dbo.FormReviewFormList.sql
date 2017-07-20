SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Jay Robohn
-- Create date: 09/15/14
-- Description:	Get all Form Reviews by HVCaseFK.
--				This is a modification of the FormReviewedTableList() function, 
--				which loads a specific form's FormReview rows for a ProgramFK
-- =============================================
CREATE function [dbo].[FormReviewFormList] (@HVCaseFK int)

returns @results table (FormType char(2)
						, FormFK int
						, IsReviewRequired int
						, IsFormReviewed int
					   )
as
	begin
		with cteMain
		as 
			(
				select	fr.FormType
						  , FormFK
						  , dbo.IsFormReviewTurnedOn(fr.FormDate, fr.FormType, fr.ProgramFK) as IsReviewRequired
						  , dbo.IsFormReviewed(fr.FormDate, fr.FormType, fr.FormFK) as IsFormReviewed
					from FormReview fr
					inner join FormReviewOptions fro on fro.ProgramFK = fr.ProgramFK and fro.FormType = fr.FormType
					where fr.HVCaseFK = @HVCaseFK
			)
		insert @results
				(FormType, FormFK, IsReviewRequired, IsFormReviewed)
			select	m.FormType
					  , m.FormFK
					  , m.IsReviewRequired
					  , case when m.IsReviewRequired = 0 then null else m.IsFormReviewed end as IsFormReviewed
				from cteMain m
		return
	end
GO
