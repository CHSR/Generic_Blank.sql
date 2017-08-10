CREATE TABLE [dbo].[PSI]
(
[PSIPK] [int] NOT NULL IDENTITY(1, 1),
[DefensiveRespondingScore] [numeric] (4, 0) NULL,
[DifficultChildScore] [numeric] (4, 0) NULL,
[DifficultChildScoreMValid] [numeric] (2, 0) NULL,
[DifficultChildValid] [bit] NULL,
[FSWFK] [int] NOT NULL,
[HVCaseFK] [int] NOT NULL,
[ParentalDistressScore] [numeric] (4, 0) NULL,
[ParentalDistressScoreMValid] [numeric] (2, 0) NULL,
[ParentalDistressValid] [bit] NULL,
[ParentChildDisfunctionalInteractionScore] [numeric] (4, 0) NULL,
[ParentChildDysfunctionalInteractionScoreMValid] [numeric] (2, 0) NULL,
[ParentChildDysfunctionalInteractionValid] [bit] NULL,
[ProgramFK] [int] NOT NULL,
[PSICreateDate] [datetime] NOT NULL CONSTRAINT [DF_PSI_PSICreateDate] DEFAULT (getdate()),
[PSICreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PSIDateComplete] [datetime] NOT NULL,
[PSIEditDate] [datetime] NULL,
[PSIEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSIInterval] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSIInWindow] [bit] NULL,
[PSILanguage] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PSIQ1] [int] NULL,
[PSIQ2] [int] NULL,
[PSIQ3] [int] NULL,
[PSIQ4] [int] NULL,
[PSIQ5] [int] NULL,
[PSIQ6] [int] NULL,
[PSIQ7] [int] NULL,
[PSIQ8] [int] NULL,
[PSIQ9] [int] NULL,
[PSIQ10] [int] NULL,
[PSIQ11] [int] NULL,
[PSIQ12] [int] NULL,
[PSIQ13] [int] NULL,
[PSIQ14] [int] NULL,
[PSIQ15] [int] NULL,
[PSIQ16] [int] NULL,
[PSIQ17] [int] NULL,
[PSIQ18] [int] NULL,
[PSIQ19] [int] NULL,
[PSIQ20] [int] NULL,
[PSIQ21] [int] NULL,
[PSIQ22] [int] NULL,
[PSIQ23] [int] NULL,
[PSIQ24] [int] NULL,
[PSIQ25] [int] NULL,
[PSIQ26] [int] NULL,
[PSIQ27] [int] NULL,
[PSIQ28] [int] NULL,
[PSIQ29] [int] NULL,
[PSIQ30] [int] NULL,
[PSIQ31] [int] NULL,
[PSIQ32] [int] NULL,
[PSIQ33] [int] NULL,
[PSIQ34] [int] NULL,
[PSIQ35] [int] NULL,
[PSIQ36] [int] NULL,
[PSITotalScore] [numeric] (4, 0) NULL,
[PSITotalScoreValid] [bit] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[fr_delete_PSI]
on [dbo].[PSI]
After DELETE

AS

Declare @PK int

set @PK = (SELECT PSIPK from deleted)

BEGIN
	EXEC spDeleteFormReview_Trigger @FormFK=@PK, @FormTypeValue='PS'
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[fr_PSI]
on [dbo].[PSI]
After insert

AS

Declare @PK int

set @PK = (SELECT PSIPK from inserted)

BEGIN
	EXEC spAddFormReview_userTrigger @FormFK=@PK, @FormTypeValue='PS'
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
CREATE trigger [dbo].[fr_PSI_Edit]
on [dbo].[PSI]
AFTER UPDATE

AS

Declare @PK int
Declare @UpdatedFormDate datetime 
Declare @FormTypeValue varchar(2)

select @PK = PSIPK FROM inserted
select @UpdatedFormDate = PSIDateComplete FROM inserted
set @FormTypeValue = 'PS'

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
-- create trigger TR_PSIEditDate ON PSI
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_PSIEditDate] ON [dbo].[PSI]
For Update 
AS
Update PSI Set PSI.PSIEditDate= getdate()
From [PSI] INNER JOIN Inserted ON [PSI].[PSIPK]= Inserted.[PSIPK]
GO
ALTER TABLE [dbo].[PSI] ADD CONSTRAINT [PK__PSI__134D0373671F4F74] PRIMARY KEY CLUSTERED  ([PSIPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_PSI_FSWFK] ON [dbo].[PSI] ([FSWFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_PSI_HVCaseFK] ON [dbo].[PSI] ([HVCaseFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_PSI_ProgramFK] ON [dbo].[PSI] ([ProgramFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PSIInterval] ON [dbo].[PSI] ([PSIInterval]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSI] WITH NOCHECK ADD CONSTRAINT [FK_PSI_FSWFK] FOREIGN KEY ([FSWFK]) REFERENCES [dbo].[Worker] ([WorkerPK])
GO
ALTER TABLE [dbo].[PSI] WITH NOCHECK ADD CONSTRAINT [FK_PSI_HVCaseFK] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[PSI] WITH NOCHECK ADD CONSTRAINT [FK_PSI_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Do not accept SVN changes', 'SCHEMA', N'dbo', 'TABLE', N'PSI', 'COLUMN', N'PSIPK'
GO
