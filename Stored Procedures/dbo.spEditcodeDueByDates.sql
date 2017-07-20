SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditcodeDueByDates](@codeDueByDatesPK int=NULL,
@DueBy int=NULL,
@EventDescription varchar(50)=NULL,
@Interval char(2)=NULL,
@MaximumDue int=NULL,
@MinimumDue int=NULL,
@ScheduledEvent varchar(20)=NULL,
@Frequency int=NULL)
AS
UPDATE codeDueByDates
SET 
DueBy = @DueBy, 
EventDescription = @EventDescription, 
Interval = @Interval, 
MaximumDue = @MaximumDue, 
MinimumDue = @MinimumDue, 
ScheduledEvent = @ScheduledEvent, 
Frequency = @Frequency
WHERE codeDueByDatesPK = @codeDueByDatesPK
GO
