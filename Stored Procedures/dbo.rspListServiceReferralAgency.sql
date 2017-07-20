SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Devinder S. Khalsa
-- Create date: 06/20/2012
-- Description:	Report containing  Service Referral Agency

-- Usage: rspListServiceReferralAgency 1,1  -- INCLUDE ALL ACTIVE AND INACTIVE
-- Usage: rspListServiceReferralAgency 1,0  -- INCLUDE ONLY ACTIVE

-- =============================================
CREATE PROCEDURE [dbo].[rspListServiceReferralAgency]
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
  
	  SELECT [AgencyName],AgencyIsActive     
	  FROM [listServiceReferralAgency]
	  WHERE ProgramFK = @programfk AND 
	  AgencyIsActive = CASE WHEN NOT @bIncludeInactive = 1 THEN 1 ELSE AgencyIsActive END   
	  AND AgencyName <> ''
 )
 
 
  SELECT 
		CASE WHEN AgencyIsActive = 1 THEN isnull(AgencyName,'') ELSE 
		
		 CASE WHEN AgencyName IS NULL THEN '' ELSE AgencyName + ' ( **Inactive )' END		 
		
		 END AS AgencyName  
		 
	   FROM cteMain  
  ORDER BY AgencyName
  
  
  END

GO
