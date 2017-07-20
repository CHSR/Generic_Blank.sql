SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddEducation](@EducationCreator char(10)=NULL,
@EducationMonthlyHours int=NULL,
@FormDate datetime=NULL,
@FormFK int=NULL,
@FormType char(2)=NULL,
@HVCaseFK int=NULL,
@Interval char(2)=NULL,
@PCType char(3)=NULL,
@ProgramFK int=NULL,
@ProgramName char(50)=NULL,
@ProgramType char(2)=NULL,
@ProgramTypeSpecify varchar(100)=NULL)
AS
INSERT INTO Education(
EducationCreator,
EducationMonthlyHours,
FormDate,
FormFK,
FormType,
HVCaseFK,
Interval,
PCType,
ProgramFK,
ProgramName,
ProgramType,
ProgramTypeSpecify
)
VALUES(
@EducationCreator,
@EducationMonthlyHours,
@FormDate,
@FormFK,
@FormType,
@HVCaseFK,
@Interval,
@PCType,
@ProgramFK,
@ProgramName,
@ProgramType,
@ProgramTypeSpecify
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
