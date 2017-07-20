SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeCaseProgress](@CaseProgressCode numeric(3, 1)=NULL,
@CaseProgressBrief varchar(10)=NULL,
@CaseProgressDescription varchar(100)=NULL,
@CaseProgressNote varchar(100)=NULL)
AS
INSERT INTO codeCaseProgress(
CaseProgressCode,
CaseProgressBrief,
CaseProgressDescription,
CaseProgressNote
)
VALUES(
@CaseProgressCode,
@CaseProgressBrief,
@CaseProgressDescription,
@CaseProgressNote
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
