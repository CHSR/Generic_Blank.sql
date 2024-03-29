CREATE TABLE [dbo].[__Temp_RetentionRate_Report]
(
[ProgramFK] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LineDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LineGroupingLevel] [int] NULL,
[DisplayPercentages] [bit] NULL,
[TotalEnrolledParticipants] [int] NULL,
[RetentionRateSixMonths] [decimal] (5, 3) NULL,
[RetentionRateOneYear] [decimal] (5, 3) NULL,
[RetentionRateEighteenMonths] [decimal] (5, 3) NULL,
[RetentionRateTwoYears] [decimal] (5, 3) NULL,
[EnrolledParticipantsSixMonths] [int] NULL,
[EnrolledParticipantsOneYear] [int] NULL,
[EnrolledParticipantsEighteenMonths] [int] NULL,
[EnrolledParticipantsTwoYears] [int] NULL,
[RunningTotalDischargedSixMonths] [int] NULL,
[RunningTotalDischargedOneYear] [int] NULL,
[RunningTotalDischargedEighteenMonths] [int] NULL,
[RunningTotalDischargedTwoYears] [int] NULL,
[TotalNSixMonths] [int] NULL,
[TotalNOneYear] [int] NULL,
[TotalNEighteenMonths] [int] NULL,
[TotalNTwoYears] [int] NULL,
[AllParticipants] [int] NULL,
[SixMonthsIntake] [int] NULL,
[SixMonthsDischarge] [int] NULL,
[OneYearIntake] [int] NULL,
[OneYearDischarge] [int] NULL,
[EighteenMonthsIntake] [int] NULL,
[EighteenMonthsDischarge] [int] NULL,
[TwoYearsIntake] [int] NULL,
[TwoYearsDischarge] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
