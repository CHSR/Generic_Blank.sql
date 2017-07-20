SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeDischarge](@DischargeCode char(2)=NULL,
@DischargeReason char(100)=NULL,
@DischargeUsedWhere varchar(50)=NULL,
@ReportDischargeText char(30)=NULL)
AS
INSERT INTO codeDischarge(
DischargeCode,
DischargeReason,
DischargeUsedWhere,
ReportDischargeText
)
VALUES(
@DischargeCode,
@DischargeReason,
@DischargeUsedWhere,
@ReportDischargeText
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
