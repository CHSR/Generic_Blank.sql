SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Devinder S Khalsa
-- Create date: 11/05/2012
-- Description:	Got it from FamSys
-- =============================================
CREATE function [dbo].[IsFormReviewed] (@DateCheck as datetime --the date of the form in question
										, @FType as char(2)	--the Form Type in question
										, @FormFK as int  --the specific FormFK in question
									  )
returns bit
as
	begin
		-- Declare the return variable here
		declare	@IsReviewed as bit
		set @IsReviewed = 1
	
		declare @ProgramFK int
		set @ProgramFK = (select ProgramFK 
							from FormReview fr
							where fr.FormFK = @FormFK
									and fr.FormType = @FType
									and fr.FormDate = @DateCheck
						 )
									
		if dbo.IsFormReviewTurnedOn(@DateCheck, @FType, @ProgramFK) > 0
			begin 
			
				select	@IsReviewed = case when ReviewedBy is not null then 1 else 0 end
				from	FormReview fr
				where	fr.FormFK = @FormFK
						and fr.FormType = @FType
						and fr.FormDate = @DateCheck
			end 
	
		return @IsReviewed
	end
GO
