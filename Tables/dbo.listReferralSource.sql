CREATE TABLE [dbo].[listReferralSource]
(
[listReferralSourcePK] [int] NOT NULL IDENTITY(1, 1),
[ProgramFK] [int] NOT NULL,
[ReferralSourceName] [char] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RSIsActive] [bit] NOT NULL,
[listReferralSourcePK_old] [int] NOT NULL,
[IsMICHC] [bit] NULL CONSTRAINT [DF_listReferralSource_IsMICHC] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[listReferralSource] ADD CONSTRAINT [PK__listRefe__0A3058D637703C52] PRIMARY KEY CLUSTERED  ([listReferralSourcePK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_listReferralSource_ProgramFK] ON [dbo].[listReferralSource] ([ProgramFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[listReferralSource] WITH NOCHECK ADD CONSTRAINT [FK_listReferralSource_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
