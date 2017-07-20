SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeERHospitalReasons](@ReasonCode varchar(2)=NULL,
@ReasonDescription varchar(100)=NULL,
@ReasonGroup varchar(50)=NULL)
AS
INSERT INTO codeERHospitalReasons(
ReasonCode,
ReasonDescription,
ReasonGroup
)
VALUES(
@ReasonCode,
@ReasonDescription,
@ReasonGroup
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
