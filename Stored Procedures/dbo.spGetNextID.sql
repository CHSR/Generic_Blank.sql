SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Paps
-- Create date: 8/4/2009
-- Description:	Increments the PC1ID table for use as last 6 numbers of PC1ID
-- =============================================
CREATE PROCEDURE [dbo].[spGetNextID]
	-- Add the parameters for the stored procedure here
	@nextnumber int OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE PC1ID
	SET @nextnumber = NextNum = (NextNum + 1)

END
GO
