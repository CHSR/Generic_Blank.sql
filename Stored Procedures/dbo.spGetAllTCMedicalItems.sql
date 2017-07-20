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
CREATE PROCEDURE [dbo].[spGetAllTCMedicalItems]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT MedicalItemCode, MedicalItemText
	FROM dbo.codeMedicalItem
	WHERE MedicalItemUsedWhere = 'TM' -- AND MedicalItemCode != '17'
	ORDER BY CAST(MedicalItemCode AS int)
END

GO
