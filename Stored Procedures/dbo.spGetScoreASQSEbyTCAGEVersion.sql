SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[spGetScoreASQSEbyTCAGEVersion]
    @TCAge      char(2)        = null,
    @ASQSEVersion varchar(10)    = null
as
begin
	set nocount on;

	select *
		from scoreASQSE
		where TCAge = @TCAge
			 and ASQSEVersion = @ASQSEVersion

end
GO
