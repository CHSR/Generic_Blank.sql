SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <copied from FamSys - see header below>
-- =============================================
create procedure [dbo].[rspPC1History]
(
    @programfk varchar(max)    = null,
    @sdate     datetime,
    @edate     datetime
)
as
	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

	select *
		  ,PC1PhysicallyAbused_Y/kempes PC1PhysicallyAbused_Y_Percent
		  ,PC1PhysicallyAbused_N/kempes PC1PhysicallyAbused_N_Percent
		  ,PC1PhysicallyAbused_Unknown/kempes PC1PhysicallyAbused_Unknown_Percent
		  ,PC1PhysicallyAbused_Mising/kempes PC1PhysicallyAbused_Mising_Percent
		  ,PC1Neglected_Y/kempes PC1Neglected_Y_Percent
		  ,PC1Neglected_N/kempes PC1Neglected_N_Percent
		  ,PC1Neglected_Unknown/kempes PC1Neglected_Unknown_Percent
		  ,PC1Neglected_Mising/kempes PC1Neglected_Mising_Percent
		  ,PC1SexuallyAbused_Y/kempes PC1SexuallyAbused_Y_Percent
		  ,PC1SexuallyAbused_N/kempes PC1SexuallyAbused_N_Percent
		  ,PC1SexuallyAbused_Unknown/kempes PC1SexuallyAbused_Unknown_Percent
		  ,PC1SexuallyAbused_Mising/kempes PC1SexuallyAbused_Mising_Percent
		  ,PC1FosterChild_Y/kempes PC1FosterChild_Y_Percent
		  ,PC1FosterChild_N/kempes PC1FosterChild_N_Percent
		  ,PC1FosterChild_Unknown/kempes PC1FosterChild_Unknown_Percent
		  ,PC1FosterChild_Mising/kempes PC1FosterChild_Mising_Percent
		  ,PC1ParentSubAbuse_Y/kempes PC1ParentSubAbuse_Y_Percent
		  ,PC1ParentSubAbuse_N/kempes PC1ParentSubAbuse_N_Percent
		  ,PC1ParentSubAbuse_Unknown/kempes PC1ParentSubAbuse_Unknown_Percent
		  ,PC1ParentSubAbuse_Mising/kempes PC1ParentSubAbuse_Mising_Percent
		  ,PC1MentallyIll_Y/kempes PC1MentallyIll_Y_Percent
		  ,PC1MentallyIll_N/kempes PC1MentallyIll_N_Percent
		  ,PC1MentallyIll_Unknown/kempes PC1MentallyIll_Unknown_Percent
		  ,PC1MentallyIll_Mising/kempes PC1MentallyIll_Mising_Percent
		  ,PC1SubAbuse_Y/kempes PC1SubAbuse_Y_Percent
		  ,PC1SubAbuse_N/kempes PC1SubAbuse_N_Percent
		  ,PC1SubAbuse_Unknown/kempes PC1SubAbuse_Unknown_Percent
		  ,PC1SubAbuse_Mising/kempes PC1SubAbuse_Mising_Percent
		  ,PC1Criminal_Y/kempes PC1Criminal_Y_Percent
		  ,PC1Criminal_N/kempes PC1Criminal_N_Percent
		  ,PC1Criminal_Unknown/kempes PC1Criminal_Unknown_Percent
		  ,PC1Criminal_Mising/kempes PC1Criminal_Mising_Percent
		  ,PC1SuspectCANer_Y/kempes PC1SuspectCANer_Y_Percent
		  ,PC1SuspectCANer_N/kempes PC1SuspectCANer_N_Percent
		  ,PC1SuspectCANer_Unknown/kempes PC1SuspectCANer_Unknown_Percent
		  ,PC1SuspectCANer_Mising/kempes PC1SuspectCANer_Mising_Percent
		  ,PC1CANer_Y/kempes PC1CANer_Y_Percent
		  ,PC1CANer_N/kempes PC1CANer_N_Percent
		  ,PC1CANer_Unknown/kempes PC1CANer_Unknown_Percent
		  ,PC1CANer_Mising/kempes PC1CANer_Mising_Percent
		  ,AtLeastOne/kempes AtLeastOne_Percent
		from (select cast(count(*) as float) kempes
					,sum(case PC1PhysicallyAbused
							 when 1 then
								 1
							 else
								 0
						 end) PC1PhysicallyAbused_Y
					,sum(case PC1PhysicallyAbused
							 when 0 then
								 1
							 else
								 0
						 end) PC1PhysicallyAbused_N
					,sum(case PC1PhysicallyAbused
							 when 9 then
								 1
							 else
								 0
						 end) PC1PhysicallyAbused_Unknown
					,sum(case PC1PhysicallyAbused
							 when null then
								 1
							 else
								 0
						 end) PC1PhysicallyAbused_Mising
					,sum(case PC1Neglected
							 when 1 then
								 1
							 else
								 0
						 end) PC1Neglected_Y
					,sum(case PC1Neglected
							 when 0 then
								 1
							 else
								 0
						 end) PC1Neglected_N
					,sum(case PC1Neglected
							 when 9 then
								 1
							 else
								 0
						 end) PC1Neglected_Unknown
					,sum(case PC1Neglected
							 when null then
								 1
							 else
								 0
						 end) PC1Neglected_Mising
					,sum(case PC1SexuallyAbused
							 when 1 then
								 1
							 else
								 0
						 end) PC1SexuallyAbused_Y
					,sum(case PC1SexuallyAbused
							 when 0 then
								 1
							 else
								 0
						 end) PC1SexuallyAbused_N
					,sum(case PC1SexuallyAbused
							 when 9 then
								 1
							 else
								 0
						 end) PC1SexuallyAbused_Unknown
					,sum(case PC1SexuallyAbused
							 when null then
								 1
							 else
								 0
						 end) PC1SexuallyAbused_Mising
					,sum(case PC1FosterChild
							 when 1 then
								 1
							 else
								 0
						 end) PC1FosterChild_Y
					,sum(case PC1FosterChild
							 when 0 then
								 1
							 else
								 0
						 end) PC1FosterChild_N
					,sum(case PC1FosterChild
							 when 9 then
								 1
							 else
								 0
						 end) PC1FosterChild_Unknown
					,sum(case PC1FosterChild
							 when null then
								 1
							 else
								 0
						 end) PC1FosterChild_Mising
					,sum(case PC1ParentSubAbuse
							 when 1 then
								 1
							 else
								 0
						 end) PC1ParentSubAbuse_Y
					,sum(case PC1ParentSubAbuse
							 when 0 then
								 1
							 else
								 0
						 end) PC1ParentSubAbuse_N
					,sum(case PC1ParentSubAbuse
							 when 9 then
								 1
							 else
								 0
						 end) PC1ParentSubAbuse_Unknown
					,sum(case PC1ParentSubAbuse
							 when null then
								 1
							 else
								 0
						 end) PC1ParentSubAbuse_Mising
					,sum(case PC1MentallyIll
							 when 1 then
								 1
							 else
								 0
						 end) PC1MentallyIll_Y
					,sum(case PC1MentallyIll
							 when 0 then
								 1
							 else
								 0
						 end) PC1MentallyIll_N
					,sum(case PC1MentallyIll
							 when 9 then
								 1
							 else
								 0
						 end) PC1MentallyIll_Unknown
					,sum(case PC1MentallyIll
							 when null then
								 1
							 else
								 0
						 end) PC1MentallyIll_Mising
					,sum(case PC1SubAbuse
							 when 1 then
								 1
							 else
								 0
						 end) PC1SubAbuse_Y
					,sum(case PC1SubAbuse
							 when 0 then
								 1
							 else
								 0
						 end) PC1SubAbuse_N
					,sum(case PC1SubAbuse
							 when 9 then
								 1
							 else
								 0
						 end) PC1SubAbuse_Unknown
					,sum(case PC1SubAbuse
							 when null then
								 1
							 else
								 0
						 end) PC1SubAbuse_Mising
					,sum(case PC1Criminal
							 when 1 then
								 1
							 else
								 0
						 end) PC1Criminal_Y
					,sum(case PC1Criminal
							 when 0 then
								 1
							 else
								 0
						 end) PC1Criminal_N
					,sum(case PC1Criminal
							 when 9 then
								 1
							 else
								 0
						 end) PC1Criminal_Unknown
					,sum(case PC1Criminal
							 when null then
								 1
							 else
								 0
						 end) PC1Criminal_Mising
					,sum(case PC1SuspectCANer
							 when 1 then
								 1
							 else
								 0
						 end) PC1SuspectCANer_Y
					,sum(case PC1SuspectCANer
							 when 0 then
								 1
							 else
								 0
						 end) PC1SuspectCANer_N
					,sum(case PC1SuspectCANer
							 when 9 then
								 1
							 else
								 0
						 end) PC1SuspectCANer_Unknown
					,sum(case PC1SuspectCANer
							 when null then
								 1
							 else
								 0
						 end) PC1SuspectCANer_Mising
					,sum(case PC1CANer
							 when 1 then
								 1
							 else
								 0
						 end) PC1CANer_Y
					,sum(case PC1CANer
							 when 0 then
								 1
							 else
								 0
						 end) PC1CANer_N
					,sum(case PC1CANer
							 when 9 then
								 1
							 else
								 0
						 end) PC1CANer_Unknown
					,sum(case PC1CANer
							 when null then
								 1
							 else
								 0
						 end) PC1CANer_Mising
					,sum(case
							 when PC1PhysicallyAbused = 1 or PC1Neglected = 1 or PC1SexuallyAbused = 1 or PC1FosterChild = 1 or PC1ParentSubAbuse = 1 or PC1MentallyIll = 1 or PC1SubAbuse = 1 or PC1Criminal = 1 or PC1SuspectCANer = 1 or PC1CANer = 1 then
								 1
							 else
								 0
						 end) AtLeastOne
				  from caseprogram
					  inner join kempe on kempe.hvcasefk = caseprogram.hvcasefk and kempe.programfk = caseprogram.programfk
					  inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
				  where kempedate between @sdate and @edate) t
GO
