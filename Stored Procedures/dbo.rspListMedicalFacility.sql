SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Devinder S. Khalsa
-- Create date: 06/20/2012
-- MC = MEDICAL Facilities, CSZ = CITY STATE ZIP, FNLN = FIRST NAME LAST NAME
-- if bIncludeInactive = TRUE (means include inactive to active list) then we get ALL ACTIVE AND INACTIVE
-- Description:	Report containing  List Of Medical Facilities
-- Usage: rspListMedicalFacility 1,1  -- INCLUDE ALL ACTIVE AND INACTIVE
-- Usage: rspListMedicalFacility 1,0  -- INCLUDE ONLY ACTIVE

-- =============================================

CREATE PROCEDURE [dbo].[rspListMedicalFacility]
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
isnull(rtrim(MFName),'') as MFNAME
, MFIsActive
,isnull(rtrim(MFAddress),'') as MFADDRESS
,isnull(rtrim(MFCity) + ',','')+'  '+isnull(rtrim(MFState) + ',','')+'  '+isnull(rtrim(MFZip),'') as MFCSZ
,isnull(rtrim(MFPhone),'') as MFPHONE    
  FROM [listMedicalFacility]
  WHERE ProgramFK = @programfk AND 
  MFIsActive = CASE WHEN NOT @bIncludeInactive = 1 THEN 1 ELSE MFIsActive END     
  
 ) 
  
  SELECT 
		CASE WHEN MFIsActive = 1 THEN isnull(MFNAME,'') ELSE 
		
		 CASE WHEN MFNAME IS NULL THEN '' ELSE MFNAME + ' ( **Inactive )' END
		 
		
		 END AS MFNAME  
	   , MFIsActive
	   , MFADDRESS
	   , MFCSZ
	   , MFPHONE FROM cteMain 
  WHERE MFNAME <> ''
  --OR  MFADDRESS IS NOT NULL
  --OR  MFCSZ IS NOT NULL
  ORDER BY MFNAME

  
  
  
  END
GO
