CREATE TABLE [dbo].[PC1Medical]
(
[PC1MedicalPK] [int] NOT NULL IDENTITY(1, 1),
[HospitalNights] [int] NULL,
[HVCaseFK] [int] NOT NULL,
[MedicalIssue] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1ItemDate] [datetime] NOT NULL,
[PC1MedicalCreateDate] [datetime] NOT NULL CONSTRAINT [DF_PC1Medical_PC1MedicalCreateDate] DEFAULT (getdate()),
[PC1MedicalCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PC1MedicalEditDate] [datetime] NULL,
[PC1MedicalEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1MedicalItem] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create TRIGGER [dbo].[fr_delete_PC1Medical]
on [dbo].[PC1Medical]
After DELETE

AS

Declare @PK int

set @PK = (SELECT PC1MedicalPK from deleted)

BEGIN
	EXEC spDeleteFormReview_Trigger @FormFK=@PK, @FormTypeValue='PM'
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[fr_PC1Medical]
on [dbo].[PC1Medical]
After insert

AS

Declare @PK int

set @PK = (SELECT PC1MedicalPK from inserted)

BEGIN
	EXEC spAddFormReview_userTrigger @FormFK=@PK, @FormTypeValue='PM'
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
CREATE TRIGGER [dbo].[fr_PC1Medical_Edit]
on [dbo].[PC1Medical]
AFTER UPDATE

AS

Declare @PK int
Declare @UpdatedFormDate datetime 
Declare @FormTypeValue varchar(2)

select @PK = PC1MedicalPK FROM inserted
select @UpdatedFormDate = PC1ItemDate FROM inserted
set @FormTypeValue = 'PM'

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
-- create trigger TR_PC1MedicalEditDate ON PC1Medical
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_PC1MedicalEditDate] ON [dbo].[PC1Medical]
For Update 
AS
Update PC1Medical Set PC1Medical.PC1MedicalEditDate= getdate()
From [PC1Medical] INNER JOIN Inserted ON [PC1Medical].[PC1MedicalPK]= Inserted.[PC1MedicalPK]
GO
ALTER TABLE [dbo].[PC1Medical] ADD CONSTRAINT [PK__PC1Medic__337ABEE255009F39] PRIMARY KEY CLUSTERED  ([PC1MedicalPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_PC1Medical_HVCaseFK] ON [dbo].[PC1Medical] ([HVCaseFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_PC1Medical_ProgramFK] ON [dbo].[PC1Medical] ([ProgramFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PC1Medical] WITH NOCHECK ADD CONSTRAINT [FK_PC1Medical_HVCaseFK] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[PC1Medical] WITH NOCHECK ADD CONSTRAINT [FK_PC1Medical_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
