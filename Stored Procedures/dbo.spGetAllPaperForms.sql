SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Sep. 16, 2016>
-- Description:	<Gets all Paper Forms from the Attachment table>
-- =============================================

create procedure [dbo].[spGetAllPaperForms]
as
	begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
		set nocount on;

    -- Insert statements for procedure here
		select	AttachmentPK
			  , replace(AttachmentTitle, '.pdf', '') as AttachmentTitle
			  , AttachmentDescription
			  , convert(varchar(10), FormDate, 101) as FormDate
			  , AttachmentCreateDate
			  , AttachmentCreator
		from	Attachment a 
		where	FormType = 'PF'
		order by AttachmentCreateDate desc;
	end;
GO
