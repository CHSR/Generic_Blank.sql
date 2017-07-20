CREATE TABLE [dbo].[Kempe]
(
[KempePK] [int] NOT NULL IDENTITY(1, 1),
[DadBondingArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DadChildHistoryArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DadCPSArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DadDisciplineArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DadExpectationArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DadPerceptionArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DadSAMICHArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DadScore] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DadSelfEsteemArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DadStressorArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DadViolentArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FAWFK] [int] NOT NULL,
[FOBPartnerPresent] [bit] NULL,
[FOBPresent] [bit] NULL,
[GrandParentPresent] [bit] NULL,
[HVCaseFK] [int] NOT NULL,
[KempeCreateDate] [datetime] NOT NULL CONSTRAINT [DF_Kempe_KempeCreateDate] DEFAULT (getdate()),
[KempeCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[KempeDate] [datetime] NOT NULL,
[KempeEditDate] [datetime] NULL,
[KempeEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KempeResult] [bit] NOT NULL,
[MOBPartnerPresent] [bit] NULL,
[MOBPresent] [bit] NULL,
[MomBondingArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MomChildHistoryArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MomCPSArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MomDisciplineArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MomExpectationArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MomPerceptionArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MomSAMICHArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MomScore] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MomSelfEsteemArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MomStressorArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MomViolentArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NegativeReferral] [bit] NULL,
[OtherPresent] [bit] NULL,
[PartnerBondingArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartnerChildHistoryArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartnerCPSArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartnerDisciplineArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartnerExpectationArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartnerInHome] [bit] NULL,
[PartnerPerceptionArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartnerSAMICHArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartnerScore] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartnerSelfEsteemArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartnerStressorArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartnerViolentArea] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1ABadChild] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1ADifficultChild] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1AEmotionalNeeds] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1AHarsh] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1ATemper] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1AUnrealistic] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1AUnwanted] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1CANer] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1Criminal] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1FosterChild] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1IssuesFK] [int] NOT NULL,
[PC1MentallyIll] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1Neglected] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1ParentSubAbuse] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1PhysicallyAbused] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1SexuallyAbused] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1SubAbuse] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1SuspectCANer] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PresentSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramFK] [int] NOT NULL,
[SupervisorObservation] [bit] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create TRIGGER [dbo].[fr_delete_kempe]
on [dbo].[Kempe]
After DELETE

AS

Declare @PK int

set @PK = (SELECT KEMPEPK from deleted)

BEGIN
	EXEC spDeleteFormReview_Trigger @FormFK=@PK, @FormTypeValue='KE'
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[fr_kempe]
on [dbo].[Kempe]
After insert

AS

Declare @PK int

set @PK = (SELECT KempePK from inserted)

BEGIN
	EXEC spAddFormReview_userTrigger @FormFK=@PK, @FormTypeValue='KE'
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
CREATE TRIGGER [dbo].[fr_Kempe_Edit]
on [dbo].[Kempe]
AFTER UPDATE

AS

Declare @PK int
Declare @UpdatedFormDate datetime 
Declare @FormTypeValue varchar(2)

select @PK = KempePK   FROM inserted
select @UpdatedFormDate = KempeDate FROM inserted
set @FormTypeValue = 'KE'

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
-- create trigger TR_KempeEditDate ON Kempe
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_KempeEditDate] ON [dbo].[Kempe]
For Update 
AS
Update Kempe Set Kempe.KempeEditDate= getdate()
From [Kempe] INNER JOIN Inserted ON [Kempe].[KempePK]= Inserted.[KempePK]
GO
ALTER TABLE [dbo].[Kempe] ADD CONSTRAINT [PK__Kempe__309BD73525518C17] PRIMARY KEY CLUSTERED  ([KempePK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_Kempe_FAWFK] ON [dbo].[Kempe] ([FAWFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_Kempe_HVCaseFK] ON [dbo].[Kempe] ([HVCaseFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_Kempe_PC1IssuesFK] ON [dbo].[Kempe] ([PC1IssuesFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_Kempe_ProgramFK] ON [dbo].[Kempe] ([ProgramFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Kempe] WITH NOCHECK ADD CONSTRAINT [FK_Kempe_FAWFK] FOREIGN KEY ([FAWFK]) REFERENCES [dbo].[Worker] ([WorkerPK])
GO
ALTER TABLE [dbo].[Kempe] WITH NOCHECK ADD CONSTRAINT [FK_Kempe_HVCaseFK] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[Kempe] WITH NOCHECK ADD CONSTRAINT [FK_Kempe_PC1IssuesFK] FOREIGN KEY ([PC1IssuesFK]) REFERENCES [dbo].[PC1Issues] ([PC1IssuesPK])
GO
ALTER TABLE [dbo].[Kempe] WITH NOCHECK ADD CONSTRAINT [FK_Kempe_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
