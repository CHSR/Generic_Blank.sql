SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditPCProgram](@PCProgramPK int=NULL,
@PCFK int=NULL,
@ProgramFK int=NULL)
AS
UPDATE PCProgram
SET 
PCFK = @PCFK, 
ProgramFK = @ProgramFK
WHERE PCProgramPK = @PCProgramPK
GO
