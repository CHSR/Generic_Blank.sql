SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






create PROCEDURE  [dbo].[spGetOtherChildrenbyHVCaseFK](
	@HVCaseFK INT,
	@ProgramFK INT = NULL,
	@IntakeDt DateTime = NULL,
	@FormType CHAR(2) = NULL
)

AS

SET NOCOUNT ON;

IF @IntakeDt IS NULL
	BEGIN
		SELECT *    
		FROM OtherChild	
		WHERE HVCaseFK = @HVCaseFK
		AND ProgramFK = ISNULL(@ProgramFK, ProgramFK)
		AND FormType = ISNULL(@FormType, FormType)
	END
ELSE IF @IntakeDt is not null
	BEGIN
		SELECT oc.*,PrenatalCareText = 
			CASE PrenatalCare WHEN '1' THEN 'Yes'
				  WHEN '0' THEN 'No'  
			END, PregnancyOutcomeText, BirthTermText
		FROM OtherChild oc
		LEFT OUTER JOIN
		(Select AppCode,Convert(varchar,convert(int,AppCode)) +'. ' +AppCodeText as PregnancyOutcomeText from codeApp where appCodeGroup='PregnancyOutcome') a
		On pregnancyOutcome=a.AppCode
		LEFT OUTER JOIN
		(Select AppCode,convert(varchar,convert(int,AppCode))+'. '+AppCodeText as BirthTermText from codeApp where appCodeGroup='BirthTerm') b
		On BirthTerm=b.AppCode
		WHERE HVCasefk = @HVCaseFK
		AND ProgramFK=ISNULL(@ProgramFK, ProgramFK)
		AND DOB>=@IntakeDt
		AND FormType = ISNULL(@FormType, FormType)		
	END









GO
