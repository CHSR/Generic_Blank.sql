SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditcodeCaseProgress](@codeCaseProgressPK int=NULL,
@CaseProgressCode numeric(3, 1)=NULL,
@CaseProgressBrief varchar(10)=NULL,
@CaseProgressDescription varchar(100)=NULL,
@CaseProgressNote varchar(100)=NULL)
AS
UPDATE codeCaseProgress
SET 
CaseProgressCode = @CaseProgressCode, 
CaseProgressBrief = @CaseProgressBrief, 
CaseProgressDescription = @CaseProgressDescription, 
CaseProgressNote = @CaseProgressNote
WHERE codeCaseProgressPK = @codeCaseProgressPK
GO
