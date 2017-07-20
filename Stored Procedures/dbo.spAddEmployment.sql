SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddEmployment](@EmploymentCreator char(10)=NULL,
@EmploymentEndDate datetime=NULL,
@EmploymentMonthlyHours int=NULL,
@EmploymentStartDate datetime=NULL,
@FormDate datetime=NULL,
@FormFK int=NULL,
@FormType char(2)=NULL,
@HVCaseFK int=NULL,
@Interval char(2)=NULL,
@EmploymentMonthlyWages numeric(6, 0)=NULL,
@PCType char(3)=NULL,
@ProgramFK int=NULL,
@StillWorking char(1)=NULL)
AS
INSERT INTO Employment(
EmploymentCreator,
EmploymentEndDate,
EmploymentMonthlyHours,
EmploymentStartDate,
FormDate,
FormFK,
FormType,
HVCaseFK,
Interval,
EmploymentMonthlyWages,
PCType,
ProgramFK,
StillWorking
)
VALUES(
@EmploymentCreator,
@EmploymentEndDate,
@EmploymentMonthlyHours,
@EmploymentStartDate,
@FormDate,
@FormFK,
@FormType,
@HVCaseFK,
@Interval,
@EmploymentMonthlyWages,
@PCType,
@ProgramFK,
@StillWorking
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
