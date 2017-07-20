SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas (a variation on Jay's GetMedicalProviderFacility without the comments)
-- Create date: 6-13-2011
-- Description:	For DCF Report #8 - Does PC1 have a medical provider or medical facility
-- Copied from FamSys 02-11-12 jrobohn - not sure if we will need this, but we probably will
-- =============================================
CREATE FUNCTION [dbo].[GetMedicalProvORFacility_NoComments]
(
	@ChangeFormDate datetime
	, @ChangeFormProviderFacility varchar(210)
	, @FollowUpDate datetime
	, @FollowUpInterval varchar(2)
	, @FollowUpHasProviderFacility char(1)
	, @IntakeHasProviderFacility char(1)
	, @IntakeProviderFacility varchar(210)
	, @ProviderFacility bit
	, @TCFlag bit
	, @TCIDFormDate datetime
)
RETURNS varchar(210)

AS
/*----------------------------------------------------------------------------------------------
' Function       : GetMedicalProviderFacility
'
' Description    : Returns the medical provider/facility based on the state of the passed form references
'
' Change History :
'
' WHEN        WHO  WHAT
'----------------------------------------------------------------------------------------------
'--------------------------------------------------------------------------------------------*/
BEGIN
	declare @MedicalProviderFacility varchar(210)
	declare @ProviderFacilityString varchar(50)
	declare @FollowUpSection varchar(3)
	declare @OriginalFormName varchar(6)

	--Chris Papas added below on 06/13/2011
	SET @FollowUpHasProviderFacility =
		CASE WHEN @FollowUpHasProviderFacility Is Null
			THEN '0'
		ELSE @FollowUpHasProviderFacility
		END
	
	set @ProviderFacilityString = @ChangeFormProviderFacility


	set @FollowUpSection = 
		case
			when @TCFlag = 1
				then 'TC'
			else
				'PC1'
		end

	set @OriginalFormName = 
		case
			when @TCFlag = 1
				then 'TCID'
			else
				'Intake'
		end

	-- determine the PC1MedicalProviderFacility
  	set @MedicalProviderFacility = 
		case 
			when @TCFlag = 1 and @TCIDFormDate is NULL
				then 'N/A - No TC'
			-- no change forms or followups and there is a provider/facility and it was specified
			when @ChangeFormDate is null and @FollowUpDate is null
				and @IntakeHasProviderFacility = '1'
				and @IntakeProviderFacility is not null
				and @IntakeProviderFacility <> ''
				then rtrim(@IntakeProviderFacility)
			-- no change forms or followups and there is a provider/facility, but it was not specified
			when @ChangeFormDate is null and @FollowUpDate is null
				and @IntakeHasProviderFacility = '1'
				and (@IntakeProviderFacility is null
						or @IntakeProviderFacility = '')
				then @ProviderFacilityString
			-- no change forms, latest followup has provider/facility, so get from Intake
			when @ChangeFormDate is null and @FollowUpDate is not null
				and @FollowUpHasProviderFacility = '1'
				and @IntakeProviderFacility is not null
				and @IntakeProviderFacility <> ''
				then rtrim(@IntakeProviderFacility)
			-- no followups, latest change form has provider/facility, so use that one
			when @ChangeFormDate is not null and @FollowUpDate is null
				and @ChangeFormProviderFacility is not null
				and @ChangeFormProviderFacility <> ''
				then rtrim(@ChangeFormProviderFacility)
			-- no change forms, latest followup has provider/facility, so get from Intake
			when @ChangeFormDate is null and @FollowUpDate is not null
				and @FollowUpHasProviderFacility = '1'
				and @IntakeProviderFacility is not null
				and @IntakeProviderFacility <> ''
				then rtrim(@IntakeProviderFacility)
			-- change form is newer than followup and they agree
			when @ChangeFormDate > @FollowUpDate 
					and @FollowUpHasProviderFacility = '1'
					and @ChangeFormProviderFacility is not null
					and @ChangeFormProviderFacility <> '' 
				then rtrim(@ChangeFormProviderFacility)
			-- change form is newer than followup and they do not agree
			when @ChangeFormDate > @FollowUpDate 
					and @FollowUpHasProviderFacility = '1' 
					and (@ChangeFormProviderFacility is null
						or @ChangeFormProviderFacility = '')
				then @ProviderFacilityString
			-- change form is newer than followup and they do not agree
			when @ChangeFormDate > @FollowUpDate 
					and @FollowUpHasProviderFacility = '0' 
					and @ChangeFormProviderFacility is not null
					and @ChangeFormProviderFacility <> ''
				then @ProviderFacilityString
			-- followup is newer than change form and there is no provider/facility
			when @ChangeFormDate <= @FollowUpDate 
					and @FollowUpHasProviderFacility = '0'
					then 'No Medical Provider/facility'
			-- followup is newer than change form and there is a provider/facility, but it is not specified
			when @ChangeFormDate <= @FollowUpDate 
					and @FollowUpHasProviderFacility = '1' 
					and (@ChangeFormProviderFacility is null
						or @ChangeFormProviderFacility = ' ')
				then @ProviderFacilityString
			-- followup is newer than change form and there is a provider/facility
			when @ChangeFormDate <= @FollowUpDate 
					and @FollowUpHasProviderFacility = '1' 
					and @ChangeFormProviderFacility is not null
					and @ChangeFormProviderFacility <> ' '
				then rtrim(@ChangeFormProviderFacility)
			else
				'None'
		end

    RETURN(@MedicalProviderFacility)


END


GO
