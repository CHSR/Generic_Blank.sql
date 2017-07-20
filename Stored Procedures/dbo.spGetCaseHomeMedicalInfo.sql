SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 12/19/2012
-- Description:	Get the most recent medical provider/facility 7for PC/TC for use on CaseHome Page
-- =============================================
CREATE procedure [dbo].[spGetCaseHomeMedicalInfo] (@HVCaseFK int)
as
	begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
		set nocount on;

    -- Insert statements for procedure here
    
		with	cteFUP
				  as (
		--Step 1 : Get most recent followup data
					  select top 1
								FormDate as FUDate
							  , FormInterval as FUFormInterval
							  , PC1HasMedicalProvider
							  , @HVCaseFK as HVCaseFK
							  , CommonAttributesPK
					  from		CommonAttributes ca
					  where		HVCaseFK = @HVCaseFK
								and FormType like 'FU'
					  order by	FormDate desc
							  , CommonAttributesPK desc
					 ) ,
				ctePC
				  as (
		--Step 2: Get most recent medical / facility data from PC
					  select top 1
								FormDate as PCDate
							  , FormType as PCFormType
							  , FormInterval as PCFormInterval
							  , PC1MedicalProviderFK
							  , PC1MedicalFacilityFK
							  , @HVCaseFK as HVCaseFK
							  , CommonAttributesPK
					  from		CommonAttributes ca
					  where		HVCaseFK = @HVCaseFK
								and FormType in ('CH', 'IN')
					  order by	FormDate desc
							  , CommonAttributesPK desc
					 ) ,
				cteTCFU
				  as (
		--Step 3 : Get TC Has medical provider
					  select top 1
								TCHasMedicalProvider
							  , @HVCaseFK as HVCaseFK
							  , CommonAttributesPK
					  from		CommonAttributes ca
					  where		HVCaseFK = @HVCaseFK
								and FormType = 'FU'
					  order by	FormDate desc
							  , CommonAttributesPK desc
					 ) ,
				cteTC
				  as (
		--Step 4: Get most recent medical / facility data from PC
					  select top 1
								FormDate as TCDate
							  , FormType as TCFormType
							  , FormInterval as TCFormInterval
							  , TCMedicalProviderFK
							  , TCMedicalFacilityFK
							  , @HVCaseFK as HVCaseFK
							  , CommonAttributesPK
					  from		CommonAttributes ca
					  where		HVCaseFK = @HVCaseFK
								and FormType in ('CH', 'TC')
					  order by	FormDate desc
							  , CommonAttributesPK desc
					 )
			select	*
			from	ctePC
			left join cteTC on cteTC.HVCaseFK = ctePC.HVCaseFK
			left join cteTCFU on cteTCFU.HVCaseFK = cteTC.HVCaseFK
			left join cteFUP on cteFUP.HVCaseFK = ctePC.HVCaseFK

	end
GO
