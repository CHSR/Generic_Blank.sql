SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddAppOptions](@OptionDataType char(20)=NULL,
@OptionDescription char(250)=NULL,
@OptionEnd datetime=NULL,
@OptionItem char(50)=NULL,
@OptionStart datetime=NULL,
@OptionValue char(200)=NULL,
@ProgramFK int=NULL)
AS
INSERT INTO AppOptions(
OptionDataType,
OptionDescription,
OptionEnd,
OptionItem,
OptionStart,
OptionValue,
ProgramFK
)
VALUES(
@OptionDataType,
@OptionDescription,
@OptionEnd,
@OptionItem,
@OptionStart,
@OptionValue,
@ProgramFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
