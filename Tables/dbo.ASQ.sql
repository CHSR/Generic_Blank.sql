CREATE TABLE [dbo].[ASQ]
(
[ASQPK] [int] NOT NULL IDENTITY(1, 1),
[ASQCreateDate] [datetime] NOT NULL CONSTRAINT [DF_ASQ_ASQCreateDate] DEFAULT (getdate()),
[ASQCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramFK] [int] NOT NULL,
[ASQCommunicationScore] [numeric] (4, 1) NULL,
[ASQEditDate] [datetime] NULL,
[ASQEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ASQFineMotorScore] [numeric] (4, 1) NULL,
[ASQGrossMotorScore] [numeric] (4, 1) NULL,
[ASQInWindow] [bit] NULL,
[ASQPersonalSocialScore] [numeric] (4, 1) NULL,
[ASQProblemSolvingScore] [numeric] (4, 1) NULL,
[ASQTCReceiving] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateCompleted] [datetime] NOT NULL,
[DiscussedWithPC1] [bit] NULL,
[FSWFK] [int] NOT NULL,
[HVCaseFK] [int] NOT NULL,
[ReviewCDS] [bit] NOT NULL,
[TCAge] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TCIDFK] [int] NOT NULL,
[TCReferred] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UnderCommunication] [bit] NULL,
[UnderFineMotor] [bit] NULL,
[UnderGrossMotor] [bit] NULL,
[UnderPersonalSocial] [bit] NULL,
[UnderProblemSolving] [bit] NULL,
[VersionNumber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DevServicesStartDate] [date] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[fr_asq]
on [dbo].[ASQ]
After insert

AS

Declare @PK int

set @PK = (SELECT ASQPK from inserted)

BEGIN
	EXEC spAddFormReview_userTrigger @FormFK=@PK, @FormTypeValue='AQ'
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
CREATE TRIGGER [dbo].[fr_ASQ_Edit]
on [dbo].[ASQ]
AFTER UPDATE

AS

Declare @PK int
Declare @UpdatedFormDate datetime 
Declare @FormTypeValue varchar(2)

select @PK = ASQPK FROM inserted
select @UpdatedFormDate = DateCompleted FROM inserted
set @FormTypeValue = 'AQ'

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
Create TRIGGER [dbo].[fr_delete_asq]
on [dbo].[ASQ]
After DELETE

AS

Declare @PK int

set @PK = (SELECT ASQPK from deleted)

BEGIN
	EXEC spDeleteFormReview_Trigger @FormFK=@PK, @FormTypeValue='AQ'
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_ASQEditDate ON ASQ
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_ASQEditDate] ON [dbo].[ASQ]
For Update 
AS
Update ASQ Set ASQ.ASQEditDate= getdate()
From [ASQ] INNER JOIN Inserted ON [ASQ].[ASQPK]= Inserted.[ASQPK]
GO
ALTER TABLE [dbo].[ASQ] ADD CONSTRAINT [PK__ASQ__DCBAE4B403317E3D] PRIMARY KEY CLUSTERED  ([ASQPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_ASQ_FSWFK] ON [dbo].[ASQ] ([FSWFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_ASQ_HVCaseFK] ON [dbo].[ASQ] ([HVCaseFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_ASQ_ProgramFK] ON [dbo].[ASQ] ([ProgramFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_ASQ_TCIDFK] ON [dbo].[ASQ] ([TCIDFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ASQ] WITH NOCHECK ADD CONSTRAINT [FK_ASQ_FSWFK] FOREIGN KEY ([FSWFK]) REFERENCES [dbo].[Worker] ([WorkerPK])
GO
ALTER TABLE [dbo].[ASQ] WITH NOCHECK ADD CONSTRAINT [FK_ASQ_HVCaseFK] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[ASQ] WITH NOCHECK ADD CONSTRAINT [FK_ASQ_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
ALTER TABLE [dbo].[ASQ] WITH NOCHECK ADD CONSTRAINT [FK_ASQ_TCIDFK] FOREIGN KEY ([TCIDFK]) REFERENCES [dbo].[TCID] ([TCIDPK])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Do not accept SVN change', 'SCHEMA', N'dbo', 'TABLE', N'ASQ', 'COLUMN', N'ASQPK'
GO
