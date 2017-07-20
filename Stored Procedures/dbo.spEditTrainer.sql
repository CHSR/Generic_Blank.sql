SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditTrainer](@TrainerPK int=NULL,
@ProgramFK int=NULL,
@TrainerEditor char(10)=NULL,
@TrainerFirstName char(20)=NULL,
@TrainerLastName char(30)=NULL,
@TrainerOrganization char(30)=NULL,
@TrainerPK_old int=NULL,
@TrainerDescription varchar(50)=NULL)
AS
UPDATE Trainer
SET 
ProgramFK = @ProgramFK, 
TrainerEditor = @TrainerEditor, 
TrainerFirstName = @TrainerFirstName, 
TrainerLastName = @TrainerLastName, 
TrainerOrganization = @TrainerOrganization, 
TrainerPK_old = @TrainerPK_old, 
TrainerDescription = @TrainerDescription
WHERE TrainerPK = @TrainerPK
GO
