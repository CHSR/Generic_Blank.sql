SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ==============================================================
-- Author:		jrobohn
-- Create date: 20141023
-- Description:	Gets all FormReview rows for a specific CaseFK
-- exec spGetAllFormReviewByHVCaseFK 
-- ===========================================================
CREATE procedure [dbo].[spGetAllFormReviewByHVCaseFK] (@HVCaseFK int)
as
	begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
		set nocount on;

    -- Insert statements for procedure here
		select	fr.FormType
			  , FormFK
			  , dbo.IsFormReviewTurnedOn(fr.FormDate, fr.FormType, fr.FormFK) as IsReviewRequired
			  , dbo.IsFormReviewed(fr.FormDate, fr.FormType, fr.FormFK) as IsFormReviewed
			  , case when fr.ReviewedBy is null
				 then case when fro.FormReviewStartDate <= fr.FormDate
						   then case when fro.FormReviewEndDate is null then '0' --reviews have started for training
									 when fro.FormReviewEndDate > fr.FormDate then '0' --reviews have started for training
									 else ''
								end  --review end date is greater than the training date for this training
						   when fro.FormReviewStartDate > fr.FormDate then ''  --reviews have NOT started for training
						   when fro.FormReviewStartDate is null then ''
					  end--reviewing training NOT set
				 else case when fro.FormReviewStartDate <= fr.FormDate then '1' --approved and reviews have started for training
				--don't check end date for an approved training, as the user may wonder why an approval is not approved
						   when fro.FormReviewStartDate > fr.FormDate then ''  --approved but someone changed review date into future
						   when fro.FormReviewStartDate is null then ''
					  end --approved but somehow reviewing training NOT set
			end as 'IsApproved'

		from FormReview fr
		inner join FormReviewOptions fro on fro.ProgramFK = fr.ProgramFK
		where fr.HVCaseFK = @HVCaseFK
	end
GO
