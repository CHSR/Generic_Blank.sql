SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Chris Papas> (originally created by Dorothy on July 29, 2010
-- Create date: <May 23, 2012 
-- Description:	<returns count of forms before entered date. for @formlist use comma-delimited list of forms>
-- =============================================
CREATE PROCEDURE [dbo].[GetFormsBeforeDate] (@eventdate as datetime, @hvcasefk int, @formlist varchar(200))

AS 

select count(*) as howmany,codeFormName 
from codeForm, FormReview
where codeFormAbbreviation= FormReview.formType 
and hvcasefk = @hvcasefk
and @formlist LIKE('%,' + formtype + ',%') 
and formdate < @eventdate
group by codeFormName

GO
