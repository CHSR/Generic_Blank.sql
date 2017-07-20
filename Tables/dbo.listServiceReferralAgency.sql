CREATE TABLE [dbo].[listServiceReferralAgency]
(
[listServiceReferralAgencyPK] [int] NOT NULL IDENTITY(1, 1),
[AgencyIsActive] [bit] NOT NULL,
[AgencyName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramFK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[listServiceReferralAgency] ADD CONSTRAINT [PK__listServ__2B4AD1FA3B40CD36] PRIMARY KEY CLUSTERED  ([listServiceReferralAgencyPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_listServiceReferralAgency_ProgramFK] ON [dbo].[listServiceReferralAgency] ([ProgramFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[listServiceReferralAgency] WITH NOCHECK ADD CONSTRAINT [FK_listServiceReferralAgency_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
