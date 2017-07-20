SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE procedure [dbo].[spGetEmploymentByPCType]
    @PCType as varchar(3),
    @HVCaseFK  int,
    @ProgramFK int = null,
    @FormType  varchar(5)
as

	select EmploymentPK
		  ,EmploymentCreateDate
		  ,EmploymentCreator
		  ,EmploymentEditDate
		  ,EmploymentEditor
		  ,EmploymentEndDate
		  ,EmploymentMonthlyHours
		  ,EmploymentStartDate
		  ,FormDate
		  ,FormFK
		  ,FormType
		  ,HVCaseFK
		  ,Interval
		  ,EmploymentMonthlyWages
		  ,PCType
		  ,ProgramFK
		  ,StillWorking
		from Employment
		where HVCaseFK = @HVCaseFK
			 and ProgramFK = isnull(@ProgramFK,ProgramFK)
			 and PCType = @PCType
			 and FormType = @FormType
GO
