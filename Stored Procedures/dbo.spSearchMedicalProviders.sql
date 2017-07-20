SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[spSearchMedicalProviders] (@MPFirstName VARCHAR(200) = '',
@MPLastName VARCHAR(200) = '', @MPAddress VARCHAR(40)= '', @MPCity VARCHAR(20)='', @MPState VARCHAR(2)='',
@MPZip VARCHAR(10)='', @MPPhone VARCHAR(12)='', @MPIsActive BIT = NULL,
@ProgramFK INT = NULL)

AS

SET NOCOUNT ON;

--DECLARE @MPFirstName VARCHAR(200) = ''
--DECLARE @MPLastName VARCHAR(200) = '' 
--DECLARE @MPAddress VARCHAR(40)= ''
--DECLARE @MPCity VARCHAR(20)=''
--DECLARE @MPState VARCHAR(2)=''
--DECLARE @MPZip VARCHAR(10)='' 
--DECLARE @MPPhone VARCHAR(12)=''
--DECLARE @MPIsActive BIT = NULL
--DECLARE @ProgramFK INT = 6


; WITH v as (

SELECT listMedicalProviderPK, count(DISTINCT b.HVCaseFK) [n]
FROM dbo.listMedicalProvider AS a
LEFT OUTER JOIN CommonAttributes AS b ON (a.listMedicalProviderPK = b.PC1MedicalProviderFK
OR a.listMedicalProviderPK = b.TCMedicalProviderFK)
--AND b.FormType in ('IN', 'CH') 
AND b.ProgramFK = @ProgramFK
WHERE a.ProgramFK = @ProgramFK
GROUP BY listMedicalProviderPK
)

SELECT mp.*,
	MPFirstName+' '+MPLastName as MPName
	, b.n
	FROM listMedicalProvider AS mp
	LEFT OUTER JOIN v AS b ON mp.listMedicalProviderPK = b.listMedicalProviderPK
	WHERE 
	(@MPFirstName = '' OR MPFirstName LIKE @MPFirstName + '%')
	AND (@MPLastName = '' or MPLastName LIKE @MPLastName + '%')
	AND (@MPAddress = '' OR MPAddress LIKE '%' + @MPAddress + '%')
	AND (@MPCity = '' OR MPCity LIKE @MPCity + '%')
	AND (@MPState = '' OR MPState LIKE @MPState + '%')
	AND (@MPZip = '' OR MPZip LIKE @MPZip + '%')
	AND (@MPPhone = '' OR MPPhone LIKE '%' + @MPPhone + '%')
	AND MPIsActive = ISNULL(@MPIsActive,mp.MPIsActive)
	AND mp.ProgramFK = ISNULL(@ProgramFK, mp.ProgramFK)
	--ORDER BY 
	--CASE WHEN mp.MPFirstName LIKE '%'+ @MPFirstName + '%' THEN 1 ELSE 0 END +
	--CASE WHEN mp.MPLastName LIKE '%' + @MPLastName + '%' THEN 1 ELSE 0 END +
	--CASE WHEN mp.MPAddress LIKE '%'+ @MPAddress + '%' THEN 1 ELSE 0 END +
	--CASE WHEN mp.MPCity LIKE '%' + @MPCity + '%' THEN 1 ELSE 0 END +
	--CASE WHEN mp.MPState = @MPState THEN 1 ELSE 0 END +
	--CASE WHEN mp.MPZip LIKE @MPZip + '%' THEN 1 ELSE 0 END +
	--CASE WHEN mp.MPIsActive = @MPIsActive THEN 1 ELSE 0 END
	




GO
