SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeRegion](@RegionDescription varchar(100)=NULL,
@RegionName varchar(20)=NULL)
AS
INSERT INTO codeRegion(
RegionDescription,
RegionName
)
VALUES(
@RegionDescription,
@RegionName
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
