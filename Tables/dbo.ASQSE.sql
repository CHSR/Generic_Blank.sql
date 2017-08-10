CREATE TABLE [dbo].[ASQSE]
(
[ASQSEPK] [int] NOT NULL IDENTITY(1, 1),
[ASQSECreateDate] [datetime] NOT NULL CONSTRAINT [DF_ASQSE_ASQSECreateDate] DEFAULT (getdate()),
[ASQSECreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ASQSEDateCompleted] [datetime] NOT NULL,
[ASQSEEditDate] [datetime] NULL,
[ASQSEEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ASQSEInWindow] [bit] NOT NULL,
[ASQSEOverCutOff] [bit] NOT NULL,
[ASQSEReceiving] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ASQSEReferred] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ASQSETCAge] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ASQSETotalScore] [numeric] (4, 1) NOT NULL,
[ASQSEVersion] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DiscussedWithPC1] [bit] NULL,
[FSWFK] [int] NOT NULL,
[ReviewCDS] [bit] NOT NULL CONSTRAINT [DF_ASQSE_ReviewCDS] DEFAULT ((0)),
[HVCaseFK] [int] NOT NULL,
[ProgramFK] [int] NOT NULL,
[TCIDFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[fr_asqse]
on [dbo].[ASQSE]
After insert

AS

Declare @PK int

set @PK = (SELECT ASQSEPK from inserted)

BEGIN
	EXEC spAddFormReview_userTrigger @FormFK=@PK, @FormTypeValue='AS'
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
CREATE TRIGGER [dbo].[fr_ASQSE_Edit]
on [dbo].[ASQSE]
AFTER UPDATE

AS

Declare @PK int
Declare @UpdatedFormDate datetime 
Declare @FormTypeValue varchar(2)

select @PK = ASQSEPK FROM inserted
select @UpdatedFormDate = ASQSEDateCompleted FROM inserted
set @FormTypeValue = 'AS'

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
Create TRIGGER [dbo].[fr_delete_asqse]
on [dbo].[ASQSE]
After DELETE

AS

Declare @PK int

set @PK = (SELECT ASQSEPK from deleted)

BEGIN
	EXEC spDeleteFormReview_Trigger @FormFK=@PK, @FormTypeValue='AS'
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_ASQSEEditDate ON ASQSE
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_ASQSEEditDate] ON [dbo].[ASQSE]
For Update 
AS
Update ASQSE Set ASQSE.ASQSEEditDate= getdate()
From [ASQSE] INNER JOIN Inserted ON [ASQSE].[ASQSEPK]= Inserted.[ASQSEPK]
GO
ALTER TABLE [dbo].[ASQSE] ADD CONSTRAINT [PK__ASQSE__CEF50C3C07F6335A] PRIMARY KEY CLUSTERED  ([ASQSEPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_ASQSE_FSWFK] ON [dbo].[ASQSE] ([FSWFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_ASQSE_HVCaseFK] ON [dbo].[ASQSE] ([HVCaseFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_ASQSE_ProgramFK] ON [dbo].[ASQSE] ([ProgramFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_ASQSE_TCIDFK] ON [dbo].[ASQSE] ([TCIDFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ASQSE] WITH NOCHECK ADD CONSTRAINT [FK_ASQSE_FSWFK] FOREIGN KEY ([FSWFK]) REFERENCES [dbo].[Worker] ([WorkerPK])
GO
ALTER TABLE [dbo].[ASQSE] WITH NOCHECK ADD CONSTRAINT [FK_ASQSE_HVCaseFK] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[ASQSE] WITH NOCHECK ADD CONSTRAINT [FK_ASQSE_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
ALTER TABLE [dbo].[ASQSE] WITH NOCHECK ADD CONSTRAINT [FK_ASQSE_TCIDFK] FOREIGN KEY ([TCIDFK]) REFERENCES [dbo].[TCID] ([TCIDPK])
GO
