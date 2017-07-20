SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[spGetScoreASQbyTCAGEVersion]
    @TCAge      char(2)        = null,
    @ASQVersion varchar(10)    = null
as
begin
	set nocount on;

	select ASQVersion
		  ,CommunicationScore
		  ,FineMotorScore
		  ,GrossMotorScore
		  ,PersonalScore
		  ,ProblemSolvingScore
		  ,scoreASQPK
		  ,TCAge
		  ,MaximumASQScore
		from scoreASQ
		where TCAge = @TCAge
			 and ASQVersion = @ASQVersion

end
GO
