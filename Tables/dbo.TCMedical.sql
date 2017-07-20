CREATE TABLE [dbo].[TCMedical]
(
[TCMedicalPK] [int] NOT NULL IDENTITY(1, 1),
[ChildType] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HospitalNights] [int] NULL,
[HVCaseFK] [int] NOT NULL,
[IsDelayed] [bit] NULL,
[LeadLevelCode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicalReason1] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicalReason2] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicalReason3] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicalReason4] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicalReason5] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramFK] [int] NOT NULL,
[TCIDFK] [int] NULL,
[TCItemDate] [datetime] NOT NULL,
[TCMedicalCreateDate] [datetime] NOT NULL CONSTRAINT [DF_TCMedical_TCMedicalCreateDate] DEFAULT (getdate()),
[TCMedicalCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TCMedicalEditDate] [datetime] NULL,
[TCMedicalEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TCMedicalItem] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create TRIGGER [dbo].[fr_delete_tcmedical]
on [dbo].[TCMedical]
After DELETE

AS

Declare @PK int

set @PK = (SELECT TCMEDICALPK from deleted)

BEGIN
	EXEC spDeleteFormReview_Trigger @FormFK=@PK, @FormTypeValue='TM'
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[fr_tcmedical]
on [dbo].[TCMedical]
After insert

AS

Declare @PK int

set @PK = (SELECT TCMedicalPK from inserted)

BEGIN
	EXEC spAddFormReview_userTrigger @FormFK=@PK, @FormTypeValue='TM'
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
CREATE TRIGGER [dbo].[fr_TCMedical_Edit]
on [dbo].[TCMedical]
AFTER UPDATE

AS

Declare @PK int
Declare @UpdatedFormDate datetime 
Declare @FormTypeValue varchar(2)

select @PK = TCMedicalPK FROM inserted
select @UpdatedFormDate = TCItemDate FROM inserted
set @FormTypeValue = 'TM'

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
-- create trigger TR_TCMedicalEditDate ON TCMedical
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_TCMedicalEditDate] ON [dbo].[TCMedical]
For Update 
AS
Update TCMedical Set TCMedical.TCMedicalEditDate= getdate()
From [TCMedical] INNER JOIN Inserted ON [TCMedical].[TCMedicalPK]= Inserted.[TCMedicalPK]
GO
ALTER TABLE [dbo].[TCMedical] ADD CONSTRAINT [PK__TCMedica__17C4102305A3D694] PRIMARY KEY CLUSTERED  ([TCMedicalPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_TCMedical_HVCaseFK] ON [dbo].[TCMedical] ([HVCaseFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_TCMedical_ProgramFK] ON [dbo].[TCMedical] ([ProgramFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_TCMedical_TCIDFK] ON [dbo].[TCMedical] ([TCIDFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_TCMedical_TCMedicalItem] ON [dbo].[TCMedical] ([TCMedicalItem]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TCMedical] WITH NOCHECK ADD CONSTRAINT [FK_TCMedical_HVCaseFK] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[TCMedical] WITH NOCHECK ADD CONSTRAINT [FK_TCMedical_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
ALTER TABLE [dbo].[TCMedical] WITH NOCHECK ADD CONSTRAINT [FK_TCMedical_TCIDFK] FOREIGN KEY ([TCIDFK]) REFERENCES [dbo].[TCID] ([TCIDPK])
GO
