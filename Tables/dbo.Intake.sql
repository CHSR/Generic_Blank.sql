CREATE TABLE [dbo].[Intake]
(
[IntakePK] [int] NOT NULL IDENTITY(1, 1),
[FSWFK] [int] NOT NULL,
[HVCaseFK] [int] NOT NULL,
[IntakeCreateDate] [datetime] NOT NULL CONSTRAINT [DF_Intake_IntakeCreateDate] DEFAULT (getdate()),
[IntakeCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IntakeDate] [datetime] NOT NULL,
[IntakeEditdate] [datetime] NULL,
[IntakeEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramFK] [int] NOT NULL,
[MIECHV_Race_AmericanIndian] [bit] NULL,
[MIECHV_Race_Asian] [bit] NULL,
[MIECHV_Race_Black] [bit] NULL,
[MIECHV_Race_Hawaiian] [bit] NULL,
[MIECHV_Race_White] [bit] NULL,
[MIECHV_Hispanic] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OtherChildrenDevelopmentalDelays] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1SelfLowStudentAchievement] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1ChildrenLowStudentAchievement] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1FamilyArmedForces] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create TRIGGER [dbo].[fr_delete_intake]
on [dbo].[Intake]
After DELETE

AS

Declare @PK int

set @PK = (SELECT INTAKEPK from deleted)

BEGIN
	EXEC spDeleteFormReview_Trigger @FormFK=@PK, @FormTypeValue='IN'
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[fr_intake]
on [dbo].[Intake]
After insert

AS

Declare @PK int

set @PK = (SELECT IntakePK from inserted)

BEGIN
	EXEC spAddFormReview_userTrigger @FormFK=@PK, @FormTypeValue='IN'
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 08/18/2010
-- Description:	Updates FormReview Table with form date on Supervisor Review of Form
-- =============================================
CREATE TRIGGER [dbo].[fr_Intake_Edit]
on [dbo].[Intake]
AFTER UPDATE

AS

Declare @PK int
Declare @UpdatedFormDate datetime 
Declare @FormTypeValue varchar(2)

select @PK = IntakePK  FROM inserted
select @UpdatedFormDate = IntakeDate FROM inserted
set @FormTypeValue = 'IN'

BEGIN
	UPDATE FormReview
	SET 
	FormDate=@UpdatedFormDate
	WHERE FormFK=@PK 
	AND FormType=@FormTypeValue

END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_IntakeEditdate ON Intake
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_IntakeEditdate] ON [dbo].[Intake]
For Update 
AS
Update Intake Set Intake.IntakeEditdate= getdate()
From [Intake] INNER JOIN Inserted ON [Intake].[IntakePK]= Inserted.[IntakePK]
GO
ALTER TABLE [dbo].[Intake] ADD CONSTRAINT [PK__Intake__7E1E6135208CD6FA] PRIMARY KEY CLUSTERED  ([IntakePK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_Intake_FSWFK] ON [dbo].[Intake] ([FSWFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_Intake_HVCaseFK] ON [dbo].[Intake] ([HVCaseFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_Intake_ProgramFK] ON [dbo].[Intake] ([ProgramFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Intake] WITH NOCHECK ADD CONSTRAINT [FK_Intake_FSWFK] FOREIGN KEY ([FSWFK]) REFERENCES [dbo].[Worker] ([WorkerPK])
GO
ALTER TABLE [dbo].[Intake] WITH NOCHECK ADD CONSTRAINT [FK_Intake_HVCaseFK] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[Intake] WITH NOCHECK ADD CONSTRAINT [FK_Intake_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Do not accept SVN changes', 'SCHEMA', N'dbo', 'TABLE', N'Intake', 'COLUMN', N'IntakePK'
GO
