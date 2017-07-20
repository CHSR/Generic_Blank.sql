SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jay Robohn
-- Create date: Aug. 1, 2012
-- Description:	Gets PHQ9 row by FormFK/FormType
-- =============================================

CREATE procedure [dbo].[spGetPHQ9ByForm]
    @FormFK   [int],
    @FormType [char](2)
as

	set nocount on;

	select PHQ9PK
		 , Appetite
		 , BadSelf
		 , BetterOffDead
		 , Concentration
		 , DateAdministered
		 , DepressionReferralMade
		 , Difficulty
		 , Down
		 , FormFK
		 , FormInterval
		 , FormType
		 , HVCaseFK
		 , Interest
		 , Invalid
		 , ParticipantRefused
		 , PHQ9CreateDate
		 , PHQ9Creator
		 , PHQ9EditDate
		 , PHQ9Editor
		 , Positive
		 , ProgramFK
		 , Sleep
		 , SlowOrFast
		 , Tired
		 , TotalScore
	from PHQ9
	where FormFK = @FormFK
		 and FormType = @FormType
GO
