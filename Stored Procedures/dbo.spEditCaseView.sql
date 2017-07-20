SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditCaseView](@CaseViewPK int=NULL,
@PC1ID nchar(13)=NULL,
@Username varchar(max)=NULL,
@ViewDate datetime=NULL)
AS
UPDATE CaseView
SET 
PC1ID = @PC1ID, 
Username = @Username, 
ViewDate = @ViewDate
WHERE CaseViewPK = @CaseViewPK
GO
