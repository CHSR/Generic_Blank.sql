SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddlistCaseFilterName](@FieldTitle varchar(50)=NULL,
@FilterType char(2)=NULL,
@Hint varchar(100)=NULL,
@ProgramFK int=NULL,
@Inactive bit=NULL)
AS
INSERT INTO listCaseFilterName(
FieldTitle,
FilterType,
Hint,
ProgramFK,
Inactive
)
VALUES(
@FieldTitle,
@FilterType,
@Hint,
@ProgramFK,
@Inactive
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
