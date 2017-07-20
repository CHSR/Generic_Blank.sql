SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[CalculateReportDefaults] (@DefaultCode varchar(20))

RETURNS varchar(50)
AS
BEGIN
-- DefaultCode passed in as <StartPointCode>,<ReturnTypeCode>,<ReturnVal1Code>,<ReturnVal2Code>
-- StartPointCode NOW = Today's date
--				  SLY = Start of Last Year
--				  SCY = Start of Current Year
--				  SLM = Start of Last Month
--				  SCM = Start of Current Month
--				  ELY = End of Last Year
--				  ELM = End of Last Month
-- ReturnTypeCode SED = Start and End Dates
--				  QTR = Last Full Quarter
--				  OTH = Other
-- ReturnVal1Code SDn = StartPoint Date where n = number of months to subtract
-- ReturnVal2Code same as 1

	if @DefaultCode is null or @DefaultCode='' 
		return ''
		
	-- Declare the return variable here
	declare @Return varchar(50)
	declare @Now datetime
	declare @StartPointCode char(3)
	declare @ReturnTypeCode char(3)
	declare @ReturnVal1Code char(3)
	declare @ReturnVal2Code char(3)
	declare @StartPoint datetime
	declare @ReturnVal1 datetime
	declare @ReturnVal2 datetime
	
	set @Now=current_timestamp
	set @StartPointCode=substring(@DefaultCode,1,3)
	set @ReturnTypeCode=substring(@DefaultCode,5,3)
	set @ReturnVal1Code=substring(@DefaultCode,9,3)
	set @ReturnVal2Code=substring(@DefaultCode,13,3)
	
	set @StartPoint = 
		case when @StartPointCode='NOW' 
				then @Now
			when @StartPointCode='SLY' 
				then convert(datetime,convert(char(4),datepart(yy,@Now)-1)+'0101',112)
			when @StartPointCode='SCY' 
				then convert(datetime,convert(char(4),datepart(yy,@Now))+'0101',112)
			when @StartPointCode='SLM' 
				then dateadd(mm,-1,convert(datetime,convert(char(4),datepart(yy,@Now))+
						convert(char(2),datepart(mm,@Now))+'01',112))
			when @StartPointCode='SCM' 
				then convert(datetime,convert(char(4),datepart(yy,@Now))+
						convert(char(2),datepart(mm,@Now))+'01',112)
			when @StartPointCode='ELY' 
				then convert(datetime,convert(char(4),datepart(yy,@Now)-1)+'1231',112)
			when @StartPointCode='ELM' 
				then convert(datetime,convert(char(4),datepart(yy,@Now))+
						convert(char(2),datepart(mm,@Now))+'01',112)-1
		end
	
	set @ReturnVal1=dateadd(mm,convert(int,substring(@ReturnVal1Code,3,1)),@StartPoint)
	set @ReturnVal2=dateadd(mm,convert(int,substring(@ReturnVal2Code,3,1)),@StartPoint)
	
	-- Return the result of the function
	RETURN 'SD:'+convert(varchar(8),@ReturnVal1)+',ED:'+convert(varchar(8),@ReturnVal2)

END
GO
