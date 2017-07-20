SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn - original unknown>
-- Create date: <Jan 6, 2012>
-- Description:	<Reporting stored proc for FAW tickler>
--				<Note: does not currently support multiple programfks>
-- Edit date: 10/11/2013 CP - workerprogram fix NOT NEEDED.  Already had in "and workerprogram.programfk = caseprogram.programfk"
-- =============================================
CREATE procedure [dbo].[rspFAWTickler]
(
    @programfk varchar(max)    = null,
    @workerpk  int             = null,
    @sortorder int             = 1
)
as

--DECLARE @programfk varchar(max)    = '1'
--DECLARE @workerpk  int             = null
--DECLARE @sortorder int             = 1

	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

	--declare @sortdir varchar(4)
	--set @sortdir = case when @sortorder = 1 then "desc"
	--					else "asc"
	--				end

	declare @tickler table(
		pc1id varchar(13),
		pcfirstname varchar(200),
		pclastname varchar(200),
		PCAddress varchar(200),
		pcphone varchar(200),
		screendate datetime,
		tcdob datetime,
		natal varchar(200),
		worker varchar(200),
		ReferralSourceName varchar(200),
		padate varchar(12)
	)

	insert into @tickler
		select pc1id
			  ,LTRIM(RTRIM(pc.pcfirstname))
			  ,LTRIM(RTRIM(pc.pclastname))
			  ,rtrim(PCStreet)+case
								   when PCApt is null or PCApt = '' then
									   ''
								   else
									   ' (Apt. ' + rtrim(PCApt) + ')'
							   end + ', ' + rtrim(PCCity) + ', ' + PCState + '  ' + rtrim(PCZip) as PCAddress
			  ,pc.pcphone + CASE when pc.PCEmergencyPhone is not null and pc.PCEmergencyPhone <> '' then
							+ CHAR(13) + 'Emr: ' + pc.PCEmergencyPhone ELSE '' END
				    	   + CASE when pc.PCCellPhone is not null and pc.PCCellPhone <> '' then
							+ CHAR(13) + 'Cell: ' + pc.PCCellPhone ELSE '' END
							 as pcphone
			  ,hvcase.ScreenDate
			  ,case
				   when hvcase.tcdob is not null then
					   hvcase.tcdob
				   else
					   hvcase.edc
			   end as tcdob
			  ,case
				   when hvcase.tcdob is not null then
					   'Post-Natal'
				   else
					   'Pre-Natal'
			   end as natal
			  ,LTRIM(RTRIM(faw.firstname))+' '+LTRIM(RTRIM(faw.lastname)) as worker
			  ,ReferralSourceName
			  ,padate
			from hvcase
				inner join caseprogram on caseprogram.hvcasefk = hvcasepk
				inner join hvscreen on hvscreen.hvcasefk = caseprogram.hvcasefk and hvscreen.programfk = caseprogram.programfk
				inner join listReferralSource on ReferralSourceFK = listreferralsourcepk
				left join preassessment on preassessment.hvcasefk = caseprogram.hvcasefk and preassessment.programfk = caseprogram.programfk and padate in (select max(padate)
																																								from preassessment
																																								where hvcasefk = caseprogram.hvcasefk
																																									 and programfk = caseprogram.programfk)
				left join kempe on kempe.hvcasefk = caseprogram.hvcasefk and kempe.programfk = caseprogram.programfk
				inner join pc on pc.pcpk = pc1fk
				inner join worker faw on CurrentFAWFK = faw.workerpk
				inner join workerprogram on workerfk = faw.workerpk and workerprogram.programfk = caseprogram.programfk
			--INNER JOIN dbo.SplitString(@programfk,',') ON caseprogram.programfk  = listitem
			where workerfk = isnull(@workerpk,workerfk)
				 and dischargedate is null
				 --and HVCase.KempeDate is null -- This is the way it should be once fixed (don't look at kempe.kempedate) ... John and Devinder
				 and kempe.kempedate is null
				 and hvcase.ScreenDate is not null
				 and casestartdate <= dateadd(dd,1,datediff(dd,0,GETDATE()))
				 and CaseProgram.ProgramFK = @programfk

	--select *
	--	from @tickler

	-- Final Query
	select (select count(*)
				from @tickler t2
				where t2.worker = tickler.worker
				group by t2.worker) as ttl
		  ,pc1id
		  ,pcfirstname+' '+pclastname pc1
		  ,PCAddress
		  ,pcphone
		  ,screendate
		  ,tcdob
		  ,natal
		  ,worker
		  ,ReferralSourceName
		  ,dateadd(dd,14,tcdob) TargetDate
		  ,dateadd(dd,91,tcdob) AgeOutDate
		  ,case
			   when padate is not null then
				   right('0'+RTRIM(month(padate)),2)+'/'+RTRIM(year(padate))
			   else
				   'NONE'
		   end PADate
		from @tickler tickler
		order by worker
				,case when @sortorder = 1 then screendate 
					when @sortorder = 2 then dateadd(dd,14,tcdob)
				end
				,pclastname
GO
