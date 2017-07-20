SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddCaseView](@PC1ID nchar(13)=NULL,
@Username varchar(max)=NULL,
@ViewDate datetime=NULL)
AS
INSERT INTO CaseView(
PC1ID,
Username,
ViewDate
)
VALUES(
@PC1ID,
@Username,
@ViewDate
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
