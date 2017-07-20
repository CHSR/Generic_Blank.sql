SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditcodeERHospitalReasons](@codeERHospitalReasonsPK int=NULL,
@ReasonCode varchar(2)=NULL,
@ReasonDescription varchar(100)=NULL,
@ReasonGroup varchar(50)=NULL)
AS
UPDATE codeERHospitalReasons
SET 
ReasonCode = @ReasonCode, 
ReasonDescription = @ReasonDescription, 
ReasonGroup = @ReasonGroup
WHERE codeERHospitalReasonsPK = @codeERHospitalReasonsPK
GO
