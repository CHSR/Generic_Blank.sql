SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[spGetAllHVLevels](@hvcasefk INT=NULL, @programfk INT=NULL, @levelfk VARCHAR(MAX)=NULL)

AS

-- comma delimited list of all agencies
DECLARE @levelfkList VARCHAR(MAX)
SELECT @levelfkList = COALESCE(@levelfkList + ', ', '') + 
   CAST(codelevelpk AS VARCHAR(5))
FROM codelevel

SELECT hvlevel.*
FROM hvlevel
INNER JOIN dbo.SplitString(ISNULL(@levelfk,@levelfkList), ',') sp2
ON sp2.listitem = levelfk
WHERE hvcasefk = ISNULL(@hvcasefk, hvcasefk)
AND programfk = ISNULL(@programfk, programfk)
GO
