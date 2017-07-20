SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditcodePerformanceTargetTitle](@codePerformanceTargetTitlePK int=NULL,
@PerformanceTargetCode varchar(5)=NULL,
@PerformanceTargetCohortDescription varchar(150)=NULL,
@PerformanceTargetDescription varchar(500)=NULL,
@PerformanceTargetSection varchar(32)=NULL,
@PerformanceTargetTitle varchar(150)=NULL)
AS
UPDATE codePerformanceTargetTitle
SET 
PerformanceTargetCode = @PerformanceTargetCode, 
PerformanceTargetCohortDescription = @PerformanceTargetCohortDescription, 
PerformanceTargetDescription = @PerformanceTargetDescription, 
PerformanceTargetSection = @PerformanceTargetSection, 
PerformanceTargetTitle = @PerformanceTargetTitle
WHERE codePerformanceTargetTitlePK = @codePerformanceTargetTitlePK
GO
