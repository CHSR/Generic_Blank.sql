SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditcodeRegion](@codeRegionPK int=NULL,
@RegionDescription varchar(100)=NULL,
@RegionName varchar(20)=NULL)
AS
UPDATE codeRegion
SET 
RegionDescription = @RegionDescription, 
RegionName = @RegionName
WHERE codeRegionPK = @codeRegionPK
GO
