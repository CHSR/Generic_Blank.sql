SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelEducation](@EducationPK int)

AS


DELETE 
FROM Education
WHERE EducationPK = @EducationPK
GO
