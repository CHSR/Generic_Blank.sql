SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Dorothy Baum
-- Create date: Jun 28, 2009
-- Description:	ASQSE data by ASQSEPK
--				moved from FamSys Mar 20, 2012 by jrobohn
-- =============================================
CREATE procedure [dbo].[spGetASQSEbyPKWithOutput]
    @ASQSEPK    int,
    @TCIDFK     int            output,
    @TCAGE      char(2)        output,
    @ASQSEVersion varchar(10)    output

as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

	-- Insert statements for procedure here
	select *
		from [dbo].[ASQSE]
		where [ASQSEPK] = @ASQSEPK
	select @tcidfk = [TCIDFK]
		  ,@TCAge = [ASQSETCAge]
		  ,@ASQSEVersion = [ASQSEVersion]
		from [dbo].[ASQSE]
		where [ASQSEPK] = @ASQSEPK
end
GO
