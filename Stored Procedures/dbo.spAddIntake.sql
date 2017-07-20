SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddIntake](@FSWFK int=NULL,
@HVCaseFK int=NULL,
@IntakeCreator char(10)=NULL,
@IntakeDate datetime=NULL,
@IntakeEditdate datetime=NULL,
@ProgramFK int=NULL,
@MIECHV_Race_AmericanIndian bit=NULL,
@MIECHV_Race_Asian bit=NULL,
@MIECHV_Race_Black bit=NULL,
@MIECHV_Race_Hawaiian bit=NULL,
@MIECHV_Race_White bit=NULL,
@MIECHV_Hispanic nvarchar(1)=NULL,
@OtherChildrenDevelopmentalDelays char(1)=NULL,
@PC1SelfLowStudentAchievement char(1)=NULL,
@PC1ChildrenLowStudentAchievement char(1)=NULL,
@PC1FamilyArmedForces char(1)=NULL)
AS
INSERT INTO Intake(
FSWFK,
HVCaseFK,
IntakeCreator,
IntakeDate,
IntakeEditdate,
ProgramFK,
MIECHV_Race_AmericanIndian,
MIECHV_Race_Asian,
MIECHV_Race_Black,
MIECHV_Race_Hawaiian,
MIECHV_Race_White,
MIECHV_Hispanic,
OtherChildrenDevelopmentalDelays,
PC1SelfLowStudentAchievement,
PC1ChildrenLowStudentAchievement,
PC1FamilyArmedForces
)
VALUES(
@FSWFK,
@HVCaseFK,
@IntakeCreator,
@IntakeDate,
@IntakeEditdate,
@ProgramFK,
@MIECHV_Race_AmericanIndian,
@MIECHV_Race_Asian,
@MIECHV_Race_Black,
@MIECHV_Race_Hawaiian,
@MIECHV_Race_White,
@MIECHV_Hispanic,
@OtherChildrenDevelopmentalDelays,
@PC1SelfLowStudentAchievement,
@PC1ChildrenLowStudentAchievement,
@PC1FamilyArmedForces
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
