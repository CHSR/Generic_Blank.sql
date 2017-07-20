SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelcodeERHospitalReasons](@codeERHospitalReasonsPK int)

AS


DELETE 
FROM codeERHospitalReasons
WHERE codeERHospitalReasonsPK = @codeERHospitalReasonsPK
GO
