SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditTopic](@TopicPK int=NULL,
@ProgramFK int=NULL,
@TopicName char(150)=NULL,
@TopicCode numeric(4, 1)=NULL,
@TopicPK_old int=NULL)
AS
UPDATE Topic
SET 
ProgramFK = @ProgramFK, 
TopicName = @TopicName, 
TopicCode = @TopicCode, 
TopicPK_old = @TopicPK_old
WHERE TopicPK = @TopicPK
GO
