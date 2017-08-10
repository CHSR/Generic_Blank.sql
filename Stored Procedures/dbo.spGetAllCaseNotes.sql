SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Sep. 14, 2015>
-- Description:	<Gets all items for the passed Case FK from the CaseNote table>
-- =============================================

CREATE procedure [dbo].[spGetAllCaseNotes] (@ProgramFK int = null
								 , @PC1ID char(13) = null
								  )
as
	begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
		set nocount on;

    -- Insert statements for procedure here
		select	CaseNotePK
			  , CaseNoteContents
			  , rtrim(left(CaseNoteContents, 55)) + '...' as CaseNoteExtract
			  , CaseNoteCreateDate
			  , CaseNoteCreator
			  , CaseNoteEditDate
			  , convert(varchar(10), CaseNoteDate, 101) as CaseNoteDate
			  , CaseNoteEditor
			  , cn.HVCaseFK
			  , cn.ProgramFK
			  , cp.PC1ID
			  , 'CaseNote.aspx?pc1id=' + PC1ID + '&notepk=' + rtrim(convert(varchar(10), CaseNotePK)) as EditLink
		from	CaseProgram cp
		inner join CaseNote cn on cp.HVCaseFK = cn.HVCaseFK
								  and cp.ProgramFK = cn.ProgramFK
		where	cn.ProgramFK = @ProgramFK
				and cp.PC1ID = @PC1ID;
	
	end;
GO
