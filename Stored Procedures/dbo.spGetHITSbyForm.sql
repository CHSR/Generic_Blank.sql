SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[spGetHITSbyForm]
	@FormFK [int],
	@FormType [char](8)
AS

SET NOCOUNT ON;

select HITSPK
	  ,FormFK
	  ,FormInterval
	  ,FormType
	  ,HITSCreateDate
	  ,HITSCreator
	  ,HITSEditDate
	  ,HITSEditor
	  ,HVCaseFK
	  ,Invalid
	  ,Positive
	  ,TotalScore
	  ,Hurt
	  ,Insult
	  ,NotDoneReason
	  ,ProgramFK
	  ,Scream
	  ,Threaten
from HITS H
where FormFK = @FormFK
and FormType = @FormType
GO
