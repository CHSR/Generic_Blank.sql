SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditcodeSAT](@codeSATPK int=NULL,
@codeSATPK_old int=NULL,
@ProgramFK int=NULL,
@SATCompareDateField char(8)=NULL,
@SATDescription char(100)=NULL,
@SATInterval char(40)=NULL,
@SATName char(15)=NULL)
AS
UPDATE codeSAT
SET 
codeSATPK_old = @codeSATPK_old, 
ProgramFK = @ProgramFK, 
SATCompareDateField = @SATCompareDateField, 
SATDescription = @SATDescription, 
SATInterval = @SATInterval, 
SATName = @SATName
WHERE codeSATPK = @codeSATPK
GO
