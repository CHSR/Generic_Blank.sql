CREATE TABLE [dbo].[ServiceReferral]
(
[ServiceReferralPK] [int] NOT NULL IDENTITY(1, 1),
[FamilyCode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FamilyCodeSpecify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FSWFK] [int] NOT NULL,
[HVCaseFK] [int] NOT NULL,
[NatureOfReferral] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OtherServiceSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramFK] [int] NOT NULL,
[ProvidingAgencyFK] [int] NULL,
[ReasonNoService] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReasonNoServiceSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReferralDate] [datetime] NOT NULL,
[ServiceCode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ServiceReceived] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServiceReferralCreateDate] [datetime] NOT NULL CONSTRAINT [DF_ServiceReferral_ServiceReferralCreateDate] DEFAULT (getdate()),
[ServiceReferralCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ServiceReferralEditDate] [datetime] NULL,
[ServiceReferralEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create TRIGGER [dbo].[fr_delete_servicereferral]
on [dbo].[ServiceReferral]
After DELETE

AS

Declare @PK int

set @PK = (SELECT ServiceReferralPK from deleted)

BEGIN
	EXEC spDeleteFormReview_Trigger @FormFK=@PK, @FormTypeValue='SR'
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[fr_servicereferral]
on [dbo].[ServiceReferral]
After insert

AS

Declare @PK int

set @PK = (SELECT ServiceReferralPK from inserted)

BEGIN
	EXEC spAddFormReview_userTrigger @FormFK=@PK, @FormTypeValue='SR'
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
CREATE TRIGGER [dbo].[fr_ServiceReferral_Edit]
on [dbo].[ServiceReferral]
AFTER UPDATE

AS

Declare @PK int
Declare @UpdatedFormDate datetime 
Declare @FormTypeValue varchar(2)

select @PK = ServiceReferralPK  FROM inserted
select @UpdatedFormDate = ReferralDate FROM inserted
set @FormTypeValue = 'SR'

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
-- create trigger TR_ServiceReferralEditDate ON ServiceReferral
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_ServiceReferralEditDate] ON [dbo].[ServiceReferral]
For Update 
AS
Update ServiceReferral Set ServiceReferral.ServiceReferralEditDate= getdate()
From [ServiceReferral] INNER JOIN Inserted ON [ServiceReferral].[ServiceReferralPK]= Inserted.[ServiceReferralPK]
GO
ALTER TABLE [dbo].[ServiceReferral] ADD CONSTRAINT [PK__ServiceR__9084E71E73852659] PRIMARY KEY CLUSTERED  ([ServiceReferralPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_ServiceReferral_FSWFK] ON [dbo].[ServiceReferral] ([FSWFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_ServiceReferral_HVCaseFK] ON [dbo].[ServiceReferral] ([HVCaseFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_ServiceReferral_ProgramFK] ON [dbo].[ServiceReferral] ([ProgramFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_ServiceReferral_ProvidingAgencyFK] ON [dbo].[ServiceReferral] ([ProvidingAgencyFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ServiceReferral] WITH NOCHECK ADD CONSTRAINT [FK_ServiceReferral_FSWFK] FOREIGN KEY ([FSWFK]) REFERENCES [dbo].[Worker] ([WorkerPK])
GO
ALTER TABLE [dbo].[ServiceReferral] WITH NOCHECK ADD CONSTRAINT [FK_ServiceReferral_HVCaseFK] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[ServiceReferral] WITH NOCHECK ADD CONSTRAINT [FK_ServiceReferral_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
ALTER TABLE [dbo].[ServiceReferral] WITH NOCHECK ADD CONSTRAINT [FK_ServiceReferral_ProvidingAgencyFK] FOREIGN KEY ([ProvidingAgencyFK]) REFERENCES [dbo].[listServiceReferralAgency] ([listServiceReferralAgencyPK])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Do not accept SVN changes', 'SCHEMA', N'dbo', 'TABLE', N'ServiceReferral', 'COLUMN', N'ServiceReferralPK'
GO
