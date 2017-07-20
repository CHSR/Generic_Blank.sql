SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelcodeForm](@codeFormPK int)

AS


DELETE 
FROM codeForm
WHERE codeFormPK = @codeFormPK
GO
