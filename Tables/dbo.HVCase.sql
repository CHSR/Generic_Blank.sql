CREATE TABLE [dbo].[HVCase]
(
[HVCasePK] [int] NOT NULL IDENTITY(1, 1),
[CaseProgress] [numeric] (3, 1) NULL,
[Confidentiality] [bit] NULL,
[CPFK] [int] NULL,
[DateOBPAdded] [datetime] NULL,
[EDC] [datetime] NULL,
[FFFK] [int] NULL,
[FirstChildDOB] [datetime] NULL,
[FirstPrenatalCareVisit] [datetime] NULL,
[FirstPrenatalCareVisitUnknown] [bit] NULL,
[HVCaseCreateDate] [datetime] NOT NULL CONSTRAINT [DF_HVCase_HVCaseCreateDate] DEFAULT (getdate()),
[HVCaseCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HVCaseEditDate] [datetime] NULL,
[HVCaseEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InitialZip] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntakeDate] [datetime] NULL,
[IntakeLevel] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntakeWorkerFK] [int] NULL,
[KempeDate] [datetime] NULL,
[OBPInformationAvailable] [bit] NULL,
[OBPFK] [int] NULL,
[OBPinHomeIntake] [bit] NULL,
[OBPRelation2TC] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1FK] [int] NOT NULL,
[PC1Relation2TC] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1Relation2TCSpecify] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC2FK] [int] NULL,
[PC2inHomeIntake] [bit] NULL,
[PC2Relation2TC] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC2Relation2TCSpecify] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrenatalCheckupsB4] [int] NULL,
[ScreenDate] [datetime] NOT NULL,
[TCDOB] [datetime] NULL,
[TCDOD] [datetime] NULL,
[TCNumber] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[fr_IDContact]
on [dbo].[HVCase]
After UPDATE

AS

Declare @PK int, @oldConfidentiality bit, @newConfidentiality bit ;

Select @oldConfidentiality = d.Confidentiality,
	   @newConfidentiality = i.Confidentiality,
	   @PK = i.HVCasePK
From inserted i
Inner Join deleted d On i.HVCasePK=d.HVCasePK

IF @oldConfidentiality IS NULL and @newConfidentiality IS NOT NULL
	BEGIN
		EXEC spAddFormReview_userTrigger @FormFK=@PK, @FormTypeValue='ID'
	END
ELSE IF @oldConfidentiality IS NOT NULL and @newConfidentiality IS NULL
	BEGIN
		EXEC spDeleteFormReview_Trigger @FormFK=@PK, @FormTypeValue='ID'
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
CREATE TRIGGER [dbo].[fr_IDContact_Edit]
on [dbo].[HVCase]
AFTER UPDATE

AS

Declare @PK int
Declare @UpdatedFormDate datetime 
Declare @FormTypeValue varchar(2)

begin try

select @PK = HVCasePK FROM inserted
select @UpdatedFormDate = IntakeDate FROM inserted
set @FormTypeValue = 'ID'

BEGIN
	UPDATE FormReview
	SET 
	FormDate=@UpdatedFormDate
	WHERE FormFK=@PK 
	AND FormType=@FormTypeValue

END
end try
begin catch

	DECLARE @StringVariable NVARCHAR(50);
	SET @StringVariable = N'This is the PK: ' + str(@PK);

	RAISERROR (@StringVariable, -- Message text.
			   10, -- Severity,
			   1, -- State,
			   N'abcde');

end catch
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_HVCaseEditDate ON HVCase
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_HVCaseEditDate] ON [dbo].[HVCase]
For Update 
AS
Update HVCase Set HVCase.HVCaseEditDate= getdate()
From [HVCase] INNER JOIN Inserted ON [HVCase].[HVCasePK]= Inserted.[HVCasePK]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author: Bill O'Brien
-- Create date: 06/13/2016
-- Description: Automatically Update Common Attributes Intake Rows when Intake Date Changed
-- =============================================
create TRIGGER [dbo].[TR_HVCaseIntakeDate] ON [dbo].[HVCase]


For Update 
AS
Update CommonAttributes Set FormDate= inserted.IntakeDate
From CommonAttributes
INNER JOIN Inserted ON CommonAttributes.HVCaseFK= Inserted.[HVCasePK]
where FormType like 'IN%'
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bill O'Brien
-- Create date: 06/13/16
-- Description:	Update Common Attributes Form Date with new TCDOB
-- =============================================
CREATE TRIGGER [dbo].[TR_HVCaseKempe] ON [dbo].[HVCase] 
For Update 
AS
Update CommonAttributes Set FormDate= inserted.KempeDate
From CommonAttributes
INNER JOIN Inserted ON CommonAttributes.HVCaseFK= Inserted.[HVCasePK]
where FormType = 'KE'
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bill O'Brien
-- Create date: 06/13/16
-- Description:	Update Common Attributes Form Date with new Screen Date
-- =============================================
CREATE TRIGGER [dbo].[TR_HVCaseScreenDate] ON [dbo].[HVCase]
For Update 
AS
Update CommonAttributes Set FormDate= inserted.ScreenDate
From CommonAttributes
INNER JOIN Inserted ON CommonAttributes.HVCaseFK= Inserted.[HVCasePK]
where FormType like 'SC'
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bill O'Brien
-- Create date: 06/13/16
-- Description:	Update Common Attributes Form Date with new TCDOB
-- =============================================
CREATE TRIGGER [dbo].[TR_HVCaseTCDOB] ON [dbo].[HVCase]
For Update 
AS
Update CommonAttributes Set FormDate= inserted.TCDOB
From CommonAttributes
INNER JOIN Inserted ON CommonAttributes.HVCaseFK= Inserted.[HVCasePK]
where FormType = 'TC'
GO
ALTER TABLE [dbo].[HVCase] ADD CONSTRAINT [PK__HVCase__A36F84D600200768] PRIMARY KEY CLUSTERED  ([HVCasePK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_HVCase_CaseProgress] ON [dbo].[HVCase] ([CaseProgress]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_HVCase_CPFK] ON [dbo].[HVCase] ([CPFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_HVCase_FFFK] ON [dbo].[HVCase] ([FFFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_HVCase_IntakeDate] ON [dbo].[HVCase] ([IntakeDate]) INCLUDE ([CaseProgress], [EDC], [HVCasePK], [TCDOB], [TCNumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_HVCase_OBPFK] ON [dbo].[HVCase] ([OBPFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_HVCase_PC1FK] ON [dbo].[HVCase] ([PC1FK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_HVCase_PC1FK] ON [dbo].[HVCase] ([PC1FK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_HVCase_PC2FK] ON [dbo].[HVCase] ([PC2FK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ixHVCaseScreenDate] ON [dbo].[HVCase] ([ScreenDate]) INCLUDE ([CaseProgress], [EDC], [HVCasePK], [IntakeDate], [KempeDate], [PC1FK], [TCDOB]) ON [PRIMARY]
GO
CREATE STATISTICS [_dta_stat_165575628_2_33] ON [dbo].[HVCase] ([CaseProgress], [TCDOB])
GO
CREATE STATISTICS [_dta_stat_165575628_1_2_24] ON [dbo].[HVCase] ([HVCasePK], [CaseProgress], [PC1FK])
GO
CREATE STATISTICS [_dta_stat_165575628_33_1_2_24] ON [dbo].[HVCase] ([TCDOB], [HVCasePK], [CaseProgress], [PC1FK])
GO
CREATE STATISTICS [_dta_stat_165575628_33_24_1] ON [dbo].[HVCase] ([TCDOB], [PC1FK], [HVCasePK])
GO
ALTER TABLE [dbo].[HVCase] WITH NOCHECK ADD CONSTRAINT [FK_HVCase_CPFK] FOREIGN KEY ([CPFK]) REFERENCES [dbo].[PC] ([PCPK])
GO
ALTER TABLE [dbo].[HVCase] WITH NOCHECK ADD CONSTRAINT [FK_HVCase_FFFK] FOREIGN KEY ([FFFK]) REFERENCES [dbo].[PC] ([PCPK])
GO
ALTER TABLE [dbo].[HVCase] WITH NOCHECK ADD CONSTRAINT [FK_HVCase_OBPFK] FOREIGN KEY ([OBPFK]) REFERENCES [dbo].[PC] ([PCPK])
GO
ALTER TABLE [dbo].[HVCase] WITH NOCHECK ADD CONSTRAINT [FK_HVCase_PC1FK] FOREIGN KEY ([PC1FK]) REFERENCES [dbo].[PC] ([PCPK])
GO
ALTER TABLE [dbo].[HVCase] WITH NOCHECK ADD CONSTRAINT [FK_HVCase_PC2FK] FOREIGN KEY ([PC2FK]) REFERENCES [dbo].[PC] ([PCPK])
GO
