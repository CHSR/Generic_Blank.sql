SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		<Dorothy> 
-- Create date: <April 12, 2010>
-- Description:	<gets Medical Items by code for validation>
-- =============================================
CREATE PROCEDURE [dbo].[spGetCodeMedicalItemsbyCode]
@MedicalItemCode varchar(2)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT * FROM codeMedicalItem
	WHERE MedicalItemCode=@MedicalItemCode
END



GO
