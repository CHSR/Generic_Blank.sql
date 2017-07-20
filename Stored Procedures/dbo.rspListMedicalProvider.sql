SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Devinder S. Khalsa
-- Create date: 06/20/2012
-- MP = MEDICAL PROVIDER, CSZ = CITY STATE ZIP, FNLN = FIRST NAME LAST NAME
-- if bIncludeInactive = TRUE (means include inactive to active list) then we get ALL ACTIVE AND INACTIVE
-- Description:	Report containing  List Of Medical Providers
-- Usage: rspListMedicalProvider 1,1  -- INCLUDE ALL ACTIVE AND INACTIVE
-- Usage: rspListMedicalProvider 1,0  -- INCLUDE ONLY ACTIVE

-- =============================================
CREATE PROCEDURE [dbo].[rspListMedicalProvider]
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
  
SELECT 
isnull(rtrim(MPLastName),'')+
CASE WHEN len(isnull(rtrim(MPFirstName),'')) > 0 -- Add comma (,) if there is a value in FirstName
 THEN ', ' + isnull(rtrim(MPFirstName),'')
 ELSE
  ''
  end as MPFNLN
  ,MPIsActive
,isnull(rtrim(MPAddress),'') as MPADDRESS
,isnull(rtrim(MPCity) + ',','')+'  '+isnull(rtrim(MPState) + ',','')+'  '+isnull(rtrim(MPZip),'') as MPCSZ
,isnull(rtrim(MPPhone),'') as MPPHONE    
  FROM [listMedicalProvider]
  WHERE ProgramFK = @programfk AND 
  MPIsActive = CASE WHEN NOT @bIncludeInactive = 1 THEN 1 ELSE MPIsActive END 
)  
  
  SELECT 
		CASE WHEN MPIsActive = 1 THEN isnull(MPFNLN,'') ELSE 
		
		 CASE WHEN MPFNLN IS NULL THEN '' ELSE MPFNLN + ' ( **Inactive )' END
		 
		
		 END AS MPFNLN      
 
	   , MPIsActive
	   , MPADDRESS
	   , MPCSZ
	   , MPPHONE FROM cteMain 
    
  ORDER BY MPFNLN
   
  
  END
GO
