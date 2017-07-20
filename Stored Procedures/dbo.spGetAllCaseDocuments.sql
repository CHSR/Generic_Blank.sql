SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Sep. 16, 2016>
-- Description:	<Gets all case documents for the passed Case FK from the Attachment table>
-- =============================================

CREATE procedure [dbo].[spGetAllCaseDocuments] (@ProgramFK int = null
									 , @PC1ID char(13) = null
									  )
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
		from	CaseProgram cp
		inner join Attachment a on cp.HVCaseFK = a.HVCaseFK
								   and cp.ProgramFK = a.ProgramFK
								   and FormType = 'CD'
		where	a.ProgramFK = @ProgramFK
				and cp.PC1ID = @PC1ID
		order by AttachmentCreateDate desc;
	end;
GO
