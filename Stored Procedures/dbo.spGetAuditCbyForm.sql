SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetAuditCbyForm]
	@FormFK [int],
	@FormType [char](2)
AS

SET NOCOUNT ON;

select AuditCPK
	  ,AuditCCreateDate
	  ,AuditCCreator
	  ,AuditCEditDate
	  ,AuditCEditor
	  ,DailyDrinks
	  ,FormFK
	  ,FormInterval
	  ,FormType
	  ,HowOften
	  ,HVCaseFK
	  ,Invalid
	  ,MoreThanSix
	  ,Positive
	  ,ProgramFK
	  ,TotalScore 
from AuditC ac
where FormFK = @FormFK
and FormType = @FormType
GO
