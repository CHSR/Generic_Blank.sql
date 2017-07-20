SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Dorothy>
-- Create date: <5/5/10>
-- Description:	<get all the forms that can be reviewed add a list of all matching records by ProgramFK
-- indicate the last record per formtype as it is the only one editable.>
-- =============================================
create PROCEDURE [dbo].[spGetAllFormReviewOptions] @ProgramFK int
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT codeFormAbbreviation,codeFormName,FormReviewOptionsPK,
		   FormReviewStartDate,FormReviewEndDate, lastdate FROM 
		(SELECT * FROM codeForm WHERE canbeReviewed=1) a
	LEFT OUTER JOIN 
		(SELECT * FROM FormReviewOptions WHERE ProgramFK=@ProgramFK) b
		ON a.codeFormAbbreviation=b.FormType
	LEFT OUTER JOIN 
		(SELECT MAX(FormReviewStartDate) as lastdate, formtype 
			FROM formReviewOptions WHERE ProgramFK=@ProgramFK GROUP BY formtype) c
			ON b.FormType=c.FormType and b.formReviewStartDate=c.lastdate
		ORDER BY codeFormPK,FormReviewStartDate

END

GO
