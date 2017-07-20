SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditEmployment](@EmploymentPK int=NULL,
@EmploymentEditor char(10)=NULL,
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
UPDATE Employment
SET 
EmploymentEditor = @EmploymentEditor, 
EmploymentEndDate = @EmploymentEndDate, 
EmploymentMonthlyHours = @EmploymentMonthlyHours, 
EmploymentStartDate = @EmploymentStartDate, 
FormDate = @FormDate, 
FormFK = @FormFK, 
FormType = @FormType, 
HVCaseFK = @HVCaseFK, 
Interval = @Interval, 
EmploymentMonthlyWages = @EmploymentMonthlyWages, 
PCType = @PCType, 
ProgramFK = @ProgramFK, 
StillWorking = @StillWorking
WHERE EmploymentPK = @EmploymentPK
GO
