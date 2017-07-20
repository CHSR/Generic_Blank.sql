SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jay Robohn
-- Dar Chen 3/27/2013
-- Create date: old
-- Description:	Moved from FamSys on Feb 11, 2013
-- =============================================
CREATE procedure [dbo].[spSearchMedicalFacilities]
(
    @MFName     varchar(200)    = '',
    @MFAddress  varchar(40)    = '',
    @MFCity     varchar(20)    = '',
    @MFState    varchar(2)     = '',
    @MFZip      varchar(10)    = '',
    @MFPhone    varchar(12)    = '',
    @MFIsActive bit            = null,
    @ProgramFK  int            = null
)

as

	set nocount on;

--DECLARE    @MFName     varchar(200)    = ''
--DECLARE    @MFAddress  varchar(40)    = ''
--DECLARE    @MFCity     varchar(20)    = ''
--DECLARE    @MFState    varchar(2)     = ''
--DECLARE    @MFZip      varchar(10)    = ''
--DECLARE    @MFPhone    varchar(12)    = ''
--DECLARE    @MFIsActive bit            = null
--DECLARE    @ProgramFK  int            = 6


; WITH v as (

SELECT listMedicalFacilityPK, count(DISTINCT b.HVCaseFK) [n]
FROM dbo.listMedicalFacility AS a
LEFT OUTER JOIN CommonAttributes AS b ON (a.listMedicalFacilityPK = b.PC1MedicalFacilityFK
OR a.listMedicalFacilityPK = b.TCMedicalFacilityFK)
AND b.ProgramFK = @ProgramFK
WHERE a.ProgramFK = @ProgramFK
GROUP BY listMedicalFacilityPK
)

SELECT mf.*, b.n
	FROM listMedicalFacility mf
	LEFT OUTER JOIN v AS b ON mf.listMedicalFacilityPK = b.listMedicalFacilityPK
	WHERE 
	(@MFName = '' OR MFName LIKE @MFName + '%')
	AND (@MFAddress = '' OR MFAddress LIKE '%' + @MFAddress + '%')
	AND (@MFCity = '' OR MFCity LIKE @MFCity + '%')
	AND (@MFState = '' OR MFState LIKE @MFState + '%')
	AND (@MFZip = '' OR MFZip LIKE @MFZip + '%')
	AND (@MFPhone = '' OR MFPhone LIKE '%' + @MFPhone + '%')
	AND MFIsActive = ISNULL(@MFIsActive,MF.MFIsActive)
	AND MF.ProgramFK = ISNULL(@ProgramFK, MF.ProgramFK)
	--ORDER BY 
	--CASE WHEN MF.MFName LIKE @MFName + '%' THEN 1 ELSE 0 END +
	--CASE WHEN MF.MFAddress LIKE '%'+ @MFAddress + '%' THEN 1 ELSE 0 END +
	--CASE WHEN MF.MFCity LIKE '%' + @MFCity + '%' THEN 1 ELSE 0 END +
	--CASE WHEN MF.MFState = @MFState THEN 1 ELSE 0 END +
	--CASE WHEN MF.MFZip LIKE @MFZip + '%' THEN 1 ELSE 0 END +
	--CASE WHEN MF.MFIsActive = @MFIsActive THEN 1 ELSE 0 END
	



GO
