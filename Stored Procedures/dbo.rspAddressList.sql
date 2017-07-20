SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Feb 5, 2012>
-- Description:	<report: Address list>
--				Moved from FamSys - 02/05/12 jrobohn
-- exec rspAddressList 1,1,0,0 
--
-- =============================================
CREATE procedure [dbo].[rspAddressList]
(@programfk     varchar(max)    = null,
 @enrolled      bit             = null,
 @preintake     bit             = null,
 @preassessment bit             = null
)

as

	if @programfk is null
	begin
		select @programfk =
			   substring((select ','+ltrim(rtrim(str(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	end

	set @programfk = replace(@programfk,'"','')

	select
		  pcfirstname
		 ,pclastname
		 ,pcstreet
		 ,pcapt
		 ,pccity
		 ,pcstate
		 ,case when len(rtrim(PCZip))=6 then left(PCZip,5) else PCZip end as pczip
		 ,pcdob
		 ,pc1id
		 ,isnull(tcdob,edc) tcdob
		 ,screendate
		 ,kempedate
		 ,intakedate
		 ,levelname current_level
		 ,ltrim(rtrim(worker.firstname))+' '+ltrim(rtrim(worker.lastname)) worker
		from hvcase
			inner join caseprogram on caseprogram.hvcasefk = hvcasepk
			inner join pc on pc1fk = pcpk
			inner join worker on workerpk = isnull(currentfswfk,currentfawfk)
			inner join codelevel on currentlevelfk = codelevelpk
			inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
		where dischargedate is null
			 and casestartdate <= dateadd(dd,1,datediff(dd,0,getdate()))
			 and 1 = case
						 when @enrolled = 1
							 and caseprogress >= 8 then
							 1
						 when @preintake = 1
							 and caseprogress = 6 then
							 1
						 when @preassessment = 1
							 and caseprogress = 2 then
							 1
						 when @enrolled in (null,0)
							 and @preintake in (null,0)
							 and @preassessment in (null,0) then
							 1
						 else
							 0
					 end
		order by pc1id
GO
