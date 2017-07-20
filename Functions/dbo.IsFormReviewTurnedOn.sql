SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Devinder S Khalsa
-- Create date: 12/20/2012
-- Usuage:  select dbo.IsFormReviewTurnedOn('20120716', 'PS',53277)
-- =============================================
CREATE function [dbo].[IsFormReviewTurnedOn] (@DateCheck as datetime --the date of the form in question
												, @FType as char(2) --the Form Type in question
												, @ProgramFK as int  --the specific ProgramFK in question
											)
returns int
as
	begin

-- If we @numOfRecords = 0 then formreview is not turned yet, else yes

		declare	@numOfRecords as int 

		set @numOfRecords = (select	count(FormReviewOptionsPK)
							 from FormReviewOptions fro
							 where fro.ProgramFK = @ProgramFK
									and fro.FormType = @FType
									and @DateCheck between fro.FormReviewStartDate 
															and isnull(fro.FormReviewEndDate, @DateCheck)
							)

		return @numOfRecords
	end
GO
