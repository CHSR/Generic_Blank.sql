SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <copied from FamSys - see header below>
-- =============================================
-- =============================================
-- Author:		<Dorothy Baum>
-- Create date: <Sept 8, 2010>
-- Description:	<dataset for Kempe List report>
-- =============================================
create procedure [dbo].[rspKempeList]
(
    @programfks varchar(3),
    @startdate  datetime,
    @enddate    datetime
)
-- Add the parameters for the stored procedure here

as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

	-- Insert statements for procedure here
	select rtrim(worker.FirstName)+' '+rtrim(worker.LastName) as faw_name
		  ,worker.FirstName as faw_firstName
		  ,worker.LastName as faw_lastname
		  ,hvcasepk
		  ,pc1_firstName
		  ,pc1_lastName
		  ,pc1id
		  ,w_name
		  ,w_firstName
		  ,w_LastName
		  ,screenDate
		  ,Kempe.KempeDate
		  ,codeDischarge.DischargeReason
		from kempe
			inner join casedetail on kempe.hvcasefk = casedetail.hvcasepk
			inner join worker on kempe.FAWFK = workerPK
			inner join (select *
							from preassessment
							where casestatus = '02'
								 or casestatus = '03') pa on kempe.hvcasefk = pa.hvcasefk
			left join codeDischarge on pa.dischargereason = codeDischarge.DischargeCode
			left join WorkerDetail on pa.pafswfk = w_workerpk
			inner join splitString(@programfks,',') on kempe.programfk = listitem
		where kempe.kempedate between @startdate and @enddate
		order by pc1id

end





GO
