SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spGetWorkerbyName]
	@ProgramFK int = NULL,
	@LastName as varchar(250),
	@FirstName as varchar(250)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT WorkerPK 
	From Worker 
	LEFT JOIN WorkerProgram ON WorkerProgram.WorkerFK=Worker.WorkerPK
	WHERE WorkerProgram.ProgramFK=@ProgramFK 
	AND Worker.LastName=@LastName 
	AND Worker.FirstName=@FirstName
END
GO
