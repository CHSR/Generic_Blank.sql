SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Devinder S. Khalsa
-- Create date: 06/20/2012
-- Description:	Report containing  referal sources
-- Usage: rspListReferralSource 1,1  -- INCLUDE ALL ACTIVE AND INACTIVE
-- Usage: rspListReferralSource 1,0  -- INCLUDE ONLY ACTIVE

-- =============================================
CREATE PROCEDURE [dbo].[rspListReferralSource]
( @programfk INT,
@bIncludeInactive      bit             = FALSE 
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 WITH cteMain AS
(  
   
	SELECT [ReferralSourceName], RSIsActive     
	  FROM [listReferralSource]
	  WHERE ProgramFK = @programfk AND 
	  RSIsActive = CASE WHEN NOT @bIncludeInactive = 1 THEN 1 ELSE RSIsActive END   
	  AND ReferralSourceName <> ''	  

)  
  
  SELECT 
		 CASE WHEN RSIsActive = 1 THEN isnull(ReferralSourceName,'') ELSE 
		
		 CASE WHEN ReferralSourceName IS NULL THEN '' ELSE ReferralSourceName + ' ( **Inactive )' END		 
		
		 END AS ReferralSourceName
		     
		 FROM cteMain
		 ORDER BY ReferralSourceName
  
  
  END
GO
