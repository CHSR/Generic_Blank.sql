SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditAuditC](@AuditCPK int=NULL,
@AuditCEditor char(10)=NULL,
@DailyDrinks int=NULL,
@FormFK int=NULL,
@FormInterval char(2)=NULL,
@FormType char(2)=NULL,
@HowOften int=NULL,
@HVCaseFK int=NULL,
@Invalid bit=NULL,
@MoreThanSix int=NULL,
@Positive bit=NULL,
@ProgramFK int=NULL,
@TotalScore int=NULL)
AS
UPDATE AuditC
SET 
AuditCEditor = @AuditCEditor, 
DailyDrinks = @DailyDrinks, 
FormFK = @FormFK, 
FormInterval = @FormInterval, 
FormType = @FormType, 
HowOften = @HowOften, 
HVCaseFK = @HVCaseFK, 
Invalid = @Invalid, 
MoreThanSix = @MoreThanSix, 
Positive = @Positive, 
ProgramFK = @ProgramFK, 
TotalScore = @TotalScore
WHERE AuditCPK = @AuditCPK
GO
