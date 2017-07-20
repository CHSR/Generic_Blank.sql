CREATE TABLE [dbo].[codeInterval]
(
[codeIntervalPK] [int] NOT NULL IDENTITY(1, 1),
[IntervalDescription] [char] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IntervalMaxMonth] [int] NOT NULL,
[IntervalName] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[codeInterval] ADD CONSTRAINT [PK__codeInte__EB99856E3F466844] PRIMARY KEY CLUSTERED  ([codeIntervalPK]) ON [PRIMARY]
GO
