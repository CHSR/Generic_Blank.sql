CREATE TABLE [dbo].[ELMAH_Error]
(
[ErrorId] [uniqueidentifier] NOT NULL CONSTRAINT [DF_ELMAH_Error_ErrorId] DEFAULT (newid()),
[Application] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Host] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Type] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Source] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Message] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[User] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StatusCode] [int] NOT NULL,
[TimeUtc] [datetime] NOT NULL,
[Sequence] [int] NOT NULL IDENTITY(1, 1),
[AllXml] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ELMAH_Error] ADD CONSTRAINT [PK_ELMAH_Error] PRIMARY KEY NONCLUSTERED  ([ErrorId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ELMAH_Error_App_Time_Seq] ON [dbo].[ELMAH_Error] ([Application], [TimeUtc] DESC, [Sequence] DESC) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Sequence] ON [dbo].[ELMAH_Error] ([Sequence]) ON [PRIMARY]
GO
