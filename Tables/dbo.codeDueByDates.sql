CREATE TABLE [dbo].[codeDueByDates]
(
[codeDueByDatesPK] [int] NOT NULL IDENTITY(1, 1),
[DueBy] [int] NOT NULL,
[EventDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Interval] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MaximumDue] [int] NOT NULL,
[MinimumDue] [int] NOT NULL,
[ScheduledEvent] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Frequency] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[codeDueByDates] ADD CONSTRAINT [PK__codeDueB__C38D5ED933D4B598] PRIMARY KEY CLUSTERED  ([codeDueByDatesPK]) ON [PRIMARY]
GO
