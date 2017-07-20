SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dorothy Baum>
-- Create date: <May 21, 2010>
-- Description:	<Query to get all records of one formtype for
-- a specified hvcasefk/programfk, one use to approve all multi record forms, i.e., TCMedical>
-- =============================================

CREATE PROCEDURE [dbo].[spGetAllFormReviewByFormType]
	(
	@FormType varchar(2),
	@HVCaseFK int,	
	@ProgramFK int
	)
AS
	SET NOCOUNT ON
	
	SELECT *
	FROM FormReview
	WHERE FormType = @FormType
	AND HVCaseFK = @HVCaseFK
	AND ProgramFK =  @ProgramFK
	
	RETURN

GO
