SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Dorothy Baum
-- Create date: March 30, 2009
-- Description:	ASQ data by ASQPK
-- =============================================
CREATE PROCEDURE [dbo].[spGetASQbyPKWithOutput] @ASQPK int, @TCIDFK int OUTPUT, @TCAGE char(2) OUTPUT, @ASQVersion varchar(10) OUTPUT
	-- Add the parameters for the stored procedure here
--	<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>, 
--	<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--SELECT [ASQCreateDate]
 --     ,[ASQCreator]
 --     ,[ProgramFK]
 --     ,[ASQCommunicationScore]
 --     ,[ASQEditDate]
 --     ,[ASQEditor]
 --     ,[ASQFineMotorScore]
 --     ,[ASQGrossMotorScore]
 --     ,[ASQInWindow]
 --     ,[ASQPersonalSocialScore]
 --     ,[ASQPK]
 --     ,[ASQProblemSolvingScore]
 --     ,[ASQTCReceiving]
 --     ,[DateCompleted]
 --     ,[FSWFK]
 --     ,[HVCaseFK]
 --     ,[TCAge]
 --     ,[TCIDFK]
 --     ,[TCReferred]
 --     ,[UnderCommunication]
 --     ,[UnderFineMotor]
 --     ,[UnderGrossMotor]
 --     ,[UnderPersonalSocial]
 --     ,[UnderProblemSolving]
 --     ,[VersionNumber]
  SELECT *
  FROM [dbo].[ASQ]
  WHERE [ASQPK]=@ASQPK
  SELECT @tcidfk=[TCIDFK],@TCAge=[TCAge],
         @ASQVersion=[VersionNumber] 
  FROM [dbo].[ASQ]
  WHERE [ASQPK]=@ASQPK
END

GO
