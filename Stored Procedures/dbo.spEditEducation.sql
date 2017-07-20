SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditEducation](@EducationPK int=NULL,
@EducationEditor char(10)=NULL,
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
UPDATE Education
SET 
EducationEditor = @EducationEditor, 
EducationMonthlyHours = @EducationMonthlyHours, 
FormDate = @FormDate, 
FormFK = @FormFK, 
FormType = @FormType, 
HVCaseFK = @HVCaseFK, 
Interval = @Interval, 
PCType = @PCType, 
ProgramFK = @ProgramFK, 
ProgramName = @ProgramName, 
ProgramType = @ProgramType, 
ProgramTypeSpecify = @ProgramTypeSpecify
WHERE EducationPK = @EducationPK
GO
