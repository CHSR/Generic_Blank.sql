SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddlistCaseFilterNameOption](@CaseFilterNameFK int=NULL,
@FilterOption varchar(50)=NULL,
@FilterOptionCode varchar(50)=NULL)
AS
INSERT INTO listCaseFilterNameOption(
CaseFilterNameFK,
FilterOption,
FilterOptionCode
)
VALUES(
@CaseFilterNameFK,
@FilterOption,
@FilterOptionCode
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
