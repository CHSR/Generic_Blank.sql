SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 08/09/12
-- Description:	Get all Form Reviews by programfk and formtype.
--				This was created because the utility to check formreview goes item by item, and in a large
--				table (like the 1000+ in TrainingHome) it was taking 5 minutes or more to go through the whole list
-- =============================================
CREATE FUNCTION [dbo].[FormReviewedTableList]
(
  @FormType  varchar(2),
  @ProgFK INT
)

  returns @results table (
    FormFK INT
    ,IsApproved VARCHAR(1)
    
  ) AS BEGIN
      
			if exists(SELECT FormReviewOptionsPK FROM FormReviewOptions fro WHERE ProgramFK=@ProgFK AND FormType=@FormType)
				BEGIN
				insert @results (FormFK, IsApproved)
						SELECT DISTINCT FormFK
							,CASE WHEN fr.ReviewedBy IS NULL THEN  
								CASE WHEN fro.FormReviewStartDate <= fr.Formdate THEN 
									CASE WHEN fro.FormReviewEndDate IS NULL THEN '0' --reviews have started for training
									WHEN fro.FormReviewEndDate > fr.Formdate THEN '0' --reviews have started for training
									ELSE '' END  --review end date is greater than the training date for this training
								WHEN fro.FormReviewStartDate > fr.Formdate THEN ''  --reviews have NOT started for training
								WHEN fro.FormReviewStartDate IS Null THEN '' END--reviewing training NOT set
							ELSE 
								CASE WHEN fro.FormReviewStartDate <= fr.Formdate THEN '1' --approved and reviews have started for training
									--don't check end date for an approved training, as the user may wonder why an approval is not approved
								WHEN  fro.FormReviewStartDate > fr.Formdate THEN ''  --approved but someone changed review date into future
								WHEN  fro.FormReviewStartDate IS Null THEN '' END --approved but somehow reviewing training NOT set
							END AS 'IsApproved'
						FROM FormReview fr
						INNER JOIN [dbo].[FormReviewOptions] fro ON fro.ProgramFK = fr.ProgramFK  
						WHERE (fr.ProgramFK = @ProgFK AND fro.ProgramFK= @progFK)
						AND fr.FormType=@FormType AND fro.FormType=@FormType	
				END
			ELSE
				BEGIN
				insert @results (FormFK, IsApproved)
					SELECT DISTINCT FormFK 
						,1 as 'IsApproved'
					FROM FormReview fr 
					WHERE fr.ProgramFK = @ProgFK
					AND fr.FormType=@FormType
				END
		RETURN
		
    END
GO
