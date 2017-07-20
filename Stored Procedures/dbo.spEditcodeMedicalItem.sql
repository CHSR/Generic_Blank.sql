SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditcodeMedicalItem](@codeMedicalItemPK int=NULL,
@MedicalItemCode char(2)=NULL,
@MedicalItemGroup varchar(20)=NULL,
@MedicalItemText char(60)=NULL,
@MedicalItemTitle char(20)=NULL,
@MedicalItemUsedWhere varchar(50)=NULL,
@NeedsDescription bit=NULL,
@Inactive bit=NULL)
AS
UPDATE codeMedicalItem
SET 
MedicalItemCode = @MedicalItemCode, 
MedicalItemGroup = @MedicalItemGroup, 
MedicalItemText = @MedicalItemText, 
MedicalItemTitle = @MedicalItemTitle, 
MedicalItemUsedWhere = @MedicalItemUsedWhere, 
NeedsDescription = @NeedsDescription, 
Inactive = @Inactive
WHERE codeMedicalItemPK = @codeMedicalItemPK
GO
