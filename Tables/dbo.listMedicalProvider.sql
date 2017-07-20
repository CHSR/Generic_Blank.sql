CREATE TABLE [dbo].[listMedicalProvider]
(
[listMedicalProviderPK] [int] NOT NULL IDENTITY(1, 1),
[MedicalProviderCreateDate] [datetime] NOT NULL CONSTRAINT [DF_listMedicalProvider_MedicalProviderCreateDate] DEFAULT (getdate()),
[MedicalProviderCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MedicalProviderEditDate] [datetime] NULL,
[MedicalProviderEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MPAddress] [char] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MPCity] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MPFirstName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MPIsActive] [bit] NOT NULL,
[MPLastName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MPPhone] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MPState] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MPZip] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramFK] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_MedicalProviderEditDate ON listMedicalProvider
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_MedicalProviderEditDate] ON [dbo].[listMedicalProvider]
For Update 
AS
Update listMedicalProvider Set listMedicalProvider.MedicalProviderEditDate= getdate()
From [listMedicalProvider] INNER JOIN Inserted ON [listMedicalProvider].[listMedicalProviderPK]= Inserted.[listMedicalProviderPK]
GO
ALTER TABLE [dbo].[listMedicalProvider] ADD CONSTRAINT [PK__listMedi__EA77966F32AB8735] PRIMARY KEY CLUSTERED  ([listMedicalProviderPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_listMedicalProvider_ProgramFK] ON [dbo].[listMedicalProvider] ([ProgramFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[listMedicalProvider] WITH NOCHECK ADD CONSTRAINT [FK_listMedicalProvider_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
