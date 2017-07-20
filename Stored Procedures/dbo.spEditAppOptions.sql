SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditAppOptions](@AppOptionsPK int=NULL,
@OptionDataType char(20)=NULL,
@OptionDescription char(250)=NULL,
@OptionEnd datetime=NULL,
@OptionItem char(50)=NULL,
@OptionStart datetime=NULL,
@OptionValue char(200)=NULL,
@ProgramFK int=NULL)
AS
UPDATE AppOptions
SET 
OptionDataType = @OptionDataType, 
OptionDescription = @OptionDescription, 
OptionEnd = @OptionEnd, 
OptionItem = @OptionItem, 
OptionStart = @OptionStart, 
OptionValue = @OptionValue, 
ProgramFK = @ProgramFK
WHERE AppOptionsPK = @AppOptionsPK
GO
