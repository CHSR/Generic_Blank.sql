SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Dorothy>
-- Create date: <Mar 18, 2010>
-- Description:	<gets all the Medical reasons for dropdownlists>
-- =============================================
CREATE PROCEDURE [dbo].[spGetAllMedicalReasons]
@reasonGroup varchar(50)= NULL 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT DISTINCT ReasonGroup FROM codeERHospitalReasons
	SELECT * FROM codeERHospitalReasons
	WHERE ReasonGroup=isnull(@reasonGroup,ReasonGroup)
END
GO
