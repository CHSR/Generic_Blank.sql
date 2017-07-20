SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE procedure [dbo].[spGetEducationByPCType]
    @PCType as varchar(3),
    @HVCaseFK  int,
    @ProgramFK int = null,
    @FormType varchar(5)
as

	select EducationPK
		  ,EducationCreateDate
		  ,EducationCreator
		  ,EducationEditDate
		  ,EducationEditor
		  ,EducationMonthlyHours
		  ,FormDate
		  ,FormFK
		  ,FormType
		  ,HVCaseFK
		  ,Interval
		  ,PCType
		  ,ProgramFK
		  ,ProgramName
		  ,ProgramType
		  ,ProgramTypeSpecify
		from Education
		where HVCaseFK = @HVCaseFK
			 and ProgramFK = ISNULL(@ProgramFK,ProgramFK)
			 and PCType = @PCType
			 and FormType = @FormType
GO
