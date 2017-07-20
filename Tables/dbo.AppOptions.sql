CREATE TABLE [dbo].[AppOptions]
(
[AppOptionsPK] [int] NOT NULL IDENTITY(1, 1),
[OptionDataType] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OptionDescription] [char] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OptionEnd] [datetime] NULL,
[OptionItem] [char] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OptionStart] [datetime] NOT NULL,
[OptionValue] [char] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramFK] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AppOptions] ADD CONSTRAINT [PK__AppOptio__6E5B65BC7F60ED59] PRIMARY KEY CLUSTERED  ([AppOptionsPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_AppOptions_ProgramFK] ON [dbo].[AppOptions] ([ProgramFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AppOptions] WITH NOCHECK ADD CONSTRAINT [FK_AppOptions_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
