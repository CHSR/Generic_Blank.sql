SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[GetFormsGreaterThanDate]
(
    @eventdate as datetime,
    @hvcasefk     int
)
as
	select count(*) as howmany
		  ,codeFormName
		from
			codeForm,FormReview
		where
			 codeFormAbbreviation = FormReview.formType
			 and hvcasefk = @hvcasefk
			 and codeFormAbbreviation <> 'DS'
			 and DATEADD(d,0,DATEDIFF(d,0,formdate)) > @eventdate
		--AND formdate > @eventdate (obviously)
		group by
				codeFormName
GO
