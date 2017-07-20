CREATE TABLE [dbo].[PC]
(
[PCPK] [int] NOT NULL IDENTITY(1, 1),
[BirthCountry] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BornUSA] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CP] [bit] NULL,
[Ethnicity] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gender] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OBP] [bit] NULL,
[PC1] [bit] NULL,
[PC2] [bit] NULL,
[PCApt] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCCellPhone] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCCity] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCCreateDate] [datetime] NOT NULL CONSTRAINT [DF_PC_PCCreateDate] DEFAULT (getdate()),
[PCCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PCDOB] [datetime] NULL,
[PCDOD] [datetime] NULL,
[PCEditDate] [datetime] NULL,
[PCEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCEmail] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCEmergencyPhone] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCFirstName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PCLastName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PCMiddleInitial] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCNoPhone] [bit] NULL,
[PCOldName] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCOldName2] [varchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCPhone] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCPK_old] [int] NOT NULL,
[PCState] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCStreet] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCZip] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Race] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RaceSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSNo] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimesMoved] [int] NULL,
[YearsInUSA] [numeric] (4, 0) NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_PCEditDate ON PC
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_PCEditDate] ON [dbo].[PC]
For Update 
AS
Update PC Set PC.PCEditDate= getdate()
From [PC] INNER JOIN Inserted ON [PC].[PCPK]= Inserted.[PCPK]
GO
ALTER TABLE [dbo].[PC] ADD CONSTRAINT [PK__PC__5801C57647A6A41B] PRIMARY KEY CLUSTERED  ([PCPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [_dta_index_PC_18_53575229__K14_K1_K21_K20] ON [dbo].[PC] ([PCDOB], [PCPK], [PCLastName], [PCFirstName]) ON [PRIMARY]
GO
