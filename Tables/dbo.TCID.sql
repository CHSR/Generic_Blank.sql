CREATE TABLE [dbo].[TCID]
(
[TCIDPK] [int] NOT NULL IDENTITY(1, 1),
[BirthTerm] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BirthWtLbs] [int] NULL,
[BirthWtOz] [int] NULL,
[DeliveryType] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ethnicity] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FedBreastMilk] [bit] NULL,
[FSWFK] [int] NOT NULL,
[GestationalAge] [int] NULL,
[HVCaseFK] [int] NOT NULL,
[IntensiveCare] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MultipleBirth] [bit] NOT NULL,
[NoImmunization] [bit] NULL,
[NumberofChildren] [int] NOT NULL,
[ProgramFK] [int] NOT NULL,
[Race] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RaceSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SmokedPregnant] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TCDOB] [datetime] NOT NULL,
[TCDOD] [datetime] NULL,
[TCFirstName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TCGender] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TCIDCreateDate] [datetime] NOT NULL CONSTRAINT [DF_TCID_TCIDCreateDate] DEFAULT (getdate()),
[TCIDCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TCIDEditDate] [datetime] NULL,
[TCIDEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TCIDFormCompleteDate] [datetime] NOT NULL,
[TCIDPK_old] [int] NOT NULL,
[TCLastName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VaricellaZoster] [bit] NULL,
[NoImmunizationsReason] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MIECHV_Race_AmericanIndian] [bit] NULL,
[MIECHV_Race_Asian] [bit] NULL,
[MIECHV_Race_Black] [bit] NULL,
[MIECHV_Race_Hawaiian] [bit] NULL,
[MIECHV_Race_White] [bit] NULL,
[MIECHV_Hispanic] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create TRIGGER [dbo].[fr_delete_tcid]
on [dbo].[TCID]
After DELETE

AS

Declare @PK int

set @PK = (SELECT TCIDPK from deleted)

BEGIN
	EXEC spDeleteFormReview_Trigger @FormFK=@PK, @FormTypeValue='TC'
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[fr_tcid]
on [dbo].[TCID]
After insert

AS

Declare @PK int

set @PK = (SELECT TCIDPK from inserted)

BEGIN
	EXEC spAddFormReview_userTrigger @FormFK=@PK, @FormTypeValue='TC'
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
CREATE TRIGGER [dbo].[fr_TCID_Edit]
on [dbo].[TCID]
AFTER UPDATE

AS

Declare @PK int
Declare @UpdatedFormDate datetime 
Declare @FormTypeValue varchar(2)

select @PK = TCIDPK   FROM inserted
select @UpdatedFormDate = TCIDFormCompleteDate FROM inserted
set @FormTypeValue = 'TC'

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
-- create trigger TR_TCIDEditDate ON TCID
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_TCIDEditDate] ON [dbo].[TCID]
For Update 
AS
Update TCID Set TCID.TCIDEditDate= getdate()
From [TCID] INNER JOIN Inserted ON [TCID].[TCIDPK]= Inserted.[TCIDPK]
GO
ALTER TABLE [dbo].[TCID] ADD CONSTRAINT [PK__TCID__05FAD12F00DF2177] PRIMARY KEY CLUSTERED  ([TCIDPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TCID_HVCaseFK] ON [dbo].[TCID] ([HVCaseFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TCID_HVCaseFK_TCDOB_TCFname_TCLName] ON [dbo].[TCID] ([HVCaseFK], [TCDOB], [TCFirstName], [TCLastName]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uix_HVCaseName] ON [dbo].[TCID] ([HVCaseFK], [TCFirstName], [TCLastName]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TCID_TCDOB_TCFname_TCLName] ON [dbo].[TCID] ([TCDOB], [TCFirstName], [TCLastName]) ON [PRIMARY]
GO
CREATE STATISTICS [_dta_stat_197575742_10_21] ON [dbo].[TCID] ([HVCaseFK], [TCFirstName])
GO
CREATE STATISTICS [_dta_stat_197575742_21_29_10] ON [dbo].[TCID] ([TCFirstName], [TCLastName], [HVCaseFK])
GO
CREATE STATISTICS [_dta_stat_197575742_29_10] ON [dbo].[TCID] ([TCLastName], [HVCaseFK])
GO
ALTER TABLE [dbo].[TCID] WITH NOCHECK ADD CONSTRAINT [FK_TCID_HVCase] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
