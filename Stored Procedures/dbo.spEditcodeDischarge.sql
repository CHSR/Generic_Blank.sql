SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditcodeDischarge](@codeDischargePK int=NULL,
@DischargeCode char(2)=NULL,
@DischargeReason char(100)=NULL,
@DischargeUsedWhere varchar(50)=NULL,
@ReportDischargeText char(30)=NULL)
AS
UPDATE codeDischarge
SET 
DischargeCode = @DischargeCode, 
DischargeReason = @DischargeReason, 
DischargeUsedWhere = @DischargeUsedWhere, 
ReportDischargeText = @ReportDischargeText
WHERE codeDischargePK = @codeDischargePK
GO
