SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditlistCaseFilterNameOption](@listCaseFilterNameOptionPK int=NULL,
@CaseFilterNameFK int=NULL,
@FilterOption varchar(50)=NULL,
@FilterOptionCode varchar(50)=NULL)
AS
UPDATE listCaseFilterNameOption
SET 
CaseFilterNameFK = @CaseFilterNameFK, 
FilterOption = @FilterOption, 
FilterOptionCode = @FilterOptionCode
WHERE listCaseFilterNameOptionPK = @listCaseFilterNameOptionPK
GO
