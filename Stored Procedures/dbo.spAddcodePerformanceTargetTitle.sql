SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodePerformanceTargetTitle](@PerformanceTargetCode varchar(5)=NULL,
@PerformanceTargetCohortDescription varchar(150)=NULL,
@PerformanceTargetDescription varchar(500)=NULL,
@PerformanceTargetSection varchar(32)=NULL,
@PerformanceTargetTitle varchar(150)=NULL)
AS
INSERT INTO codePerformanceTargetTitle(
PerformanceTargetCode,
PerformanceTargetCohortDescription,
PerformanceTargetDescription,
PerformanceTargetSection,
PerformanceTargetTitle
)
VALUES(
@PerformanceTargetCode,
@PerformanceTargetCohortDescription,
@PerformanceTargetDescription,
@PerformanceTargetSection,
@PerformanceTargetTitle
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
