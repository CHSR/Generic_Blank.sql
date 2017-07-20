SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jay Robohn
-- Create date: Nov. 12, 2011
-- Description:	<returns tcid values by HVCaseFk, for twins, triplets, etc.>
-- =============================================
CREATE PROCEDURE [dbo].[spGetTCIDbyHVCaseFK](@HVCaseFK int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT [BirthTerm]
      ,[BirthWtLbs]
      ,[BirthWtOz]
      ,[DeliveryType]
      ,[Ethnicity]
      ,[FSWFK]
      ,[GestationalAge]
      ,[HVCaseFK]
      ,[IntensiveCare]
      ,[MultipleBirth]
      ,[NoImmunization]
      ,[NumberofChildren]
      ,[ProgramFK]
      ,[Race]
      ,[RaceSpecify]
      ,[SmokedPregnant]
      ,[TCDOB]
      ,[TCFirstName]
      ,[TCGender]
	  ,[TCIDFormCompleteDate]
      ,[TCIDCreateDate]
      ,[TCIDCreator]
      ,[TCIDEditDate]
      ,[TCIDEditor]
      ,[TCIDPK]
      ,[TCLastName]
      ,[VaricellaZoster]
      ,[TCDOD]
  FROM [dbo].[TCID]
	WHERE HVCaseFK=@HVCaseFK
END



GO
