SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 4, 2012>
-- Description:	<Report - Screen Referral Source Summary>
-- =============================================
CREATE procedure [dbo].[rspScreenReferralSourceSummary](@programfk varchar(max)    = null,
                                                       @sdate     datetime,
                                                       @edate     datetime
                                                       )
as

--DECLARE @programfk VARCHAR(MAX) = '6'
--DECLARE @sdate DATETIME = '01/01/2012'
--DECLARE @edate DATETIME = '06/01/2012'


begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

	if @programfk is null
	begin
		select @programfk =
			   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','');

	with cteUnduplicatedPC1s
	as 
	(select count(distinct PC1FK) as UnduplicatedCount
		from HVScreen s 
		inner join HVCase c on c.HVCasePK=s.HVCaseFK 
		inner join dbo.SplitString(@programfk, ',') on s.programfk = listitem
		where s.ScreenDate between @sdate and @edate
	)

		select ReferralSourceName
				,UnduplicatedCount=(select UnduplicatedCount from cteUnduplicatedPC1s)
				,screens
				,prenatal
				,prenatal / (screens * 1.0) as pPrenatal
				,post2week
				,post2week / (screens * 1.0) as pPost2Week
				,postafter2week
				,postafter2week / (screens * 1.0) as pPostAfter2Week
				,positivescreen
				,positivescreen / (screens * 1.0) as pPositiveScreen
				,positivescreennotreferred
				,positivescreennotreferred / (screens * 1.0) as pPositiveScreenNotReferred
				,negativescreen
				,negativescreen / (screens * 1.0) as pNegativeScreen
			from (select count(HVCase.PC1FK) screens
					   ,sum(case
							 when isnull(TCDOB, EDC) > HVScreen.ScreenDate then
								 1
							 else
								 0
							 end) as prenatal
					   ,sum(case
							 when HVScreen.ScreenDate between isnull(TCDOB, EDC) and dateadd(d, 14, isnull(TCDOB, EDC)) then
								 1
							 else
								 0
							 end) as post2week
					   ,sum(case
							 when HVScreen.ScreenDate > dateadd(d, 14, isnull(TCDOB, EDC)) then
								 1
							 else
								 0
							 end) as postafter2week
					   ,sum(case
							 when ScreenResult = 1 and ReferralMade = 1 then
								 1
							 else
								 0
							 end) as positivescreen
					   ,sum(case
							 when ScreenResult = 1 and ReferralMade = 0 then
								 1
							 else
								 0
							 end) as positivescreennotreferred
					   ,sum(case
							 when ScreenResult = 0 then
								 1
							 else
								 0
							 end) as negativescreen
					   ,CASE WHEN ReferralSourceName IS NULL THEN 'No Referral Source' ELSE ReferralSourceName END ReferralSourceName
					  from hvscreen
					  inner join HVCase on HVScreen.HVCaseFK = HVCasePK
					  inner join caseprogram on caseprogram.hvcasefk = hvcasepk
					  LEFT OUTER JOIN dbo.listReferralSource on ReferralSourceFK = listReferralSourcePK
					  inner join dbo.SplitString(@programfk, ',') on caseprogram.programfk = listitem
					  where hvscreen.ScreenDate between @sdate and @edate
					  group by CASE WHEN ReferralSourceName IS NULL THEN 'No Referral Source' ELSE ReferralSourceName END) t
					  order by screens DESC

end
GO
